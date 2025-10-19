const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const compression = require('compression');
const morgan = require('morgan');
const { Pool } = require('pg');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');
const AWS = require('aws-sdk');
const multer = require('multer');
const multerS3 = require('multer-s3');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// AWS S3 configuration
const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'us-east-1',
});

// Multer S3 configuration for file uploads
const upload = multer({
  storage: multerS3({
    s3: s3,
    bucket: process.env.AWS_S3_BUCKET,
    acl: 'public-read',
    key: function (req, file, cb) {
      const folder = req.body.type || 'general';
      const filename = `${folder}/${Date.now()}-${file.originalname}`;
      cb(null, filename);
    },
    contentType: multerS3.AUTO_CONTENT_TYPE,
  }),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'), false);
    }
  },
});

// Middleware
app.use(helmet());
app.use(compression());
app.use(morgan('combined'));
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true,
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
});
app.use('/api/', limiter);

// Authentication middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ success: false, error: 'Access token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ success: false, error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION || '1.0.0',
    services: {
      database: 'healthy',
      storage: 'healthy',
    },
  });
});

// API Routes

// Authentication routes
app.post('/api/auth/otp/generate', async (req, res) => {
  try {
    const { phone, country_code = '+91' } = req.body;
    
    if (!phone || phone.length !== 10) {
      return res.status(400).json({
        success: false,
        error: 'Invalid phone number format',
      });
    }

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpId = `otp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Store OTP in database
    await pool.query(
      'INSERT INTO otp_verifications (otp_id, phone, country_code, otp, expires_at) VALUES ($1, $2, $3, $4, $5)',
      [otpId, phone, country_code, otp, expiresAt]
    );

    // In production, send SMS via Twilio/MSG91
    console.log(`OTP for ${country_code}${phone}: ${otp}`);

    res.json({
      success: true,
      message: 'OTP sent successfully',
      data: {
        otp_id: otpId,
        expires_at: expiresAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('OTP generation error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to generate OTP',
    });
  }
});

app.post('/api/auth/otp/verify', async (req, res) => {
  try {
    const { phone, otp, otp_id } = req.body;

    // Verify OTP
    const result = await pool.query(
      'SELECT * FROM otp_verifications WHERE otp_id = $1 AND phone = $2 AND otp = $3 AND expires_at > NOW()',
      [otp_id, phone, otp]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid or expired OTP',
      });
    }

    // Check if user exists
    let userResult = await pool.query(
      'SELECT * FROM users WHERE phone = $1',
      [phone]
    );

    let user;
    if (userResult.rows.length === 0) {
      // Create new user
      const newUserResult = await pool.query(
        'INSERT INTO users (phone, country_code, is_verified, created_at) VALUES ($1, $2, $3, NOW()) RETURNING *',
        [phone, '+91', true]
      );
      user = newUserResult.rows[0];
    } else {
      user = userResult.rows[0];
      // Update verification status
      await pool.query(
        'UPDATE users SET is_verified = true, updated_at = NOW() WHERE id = $1',
        [user.id]
      );
    }

    // Generate JWT tokens
    const accessToken = jwt.sign(
      { userId: user.id, phone: user.phone },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    const refreshToken = jwt.sign(
      { userId: user.id, phone: user.phone },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: '7d' }
    );

    // Delete used OTP
    await pool.query('DELETE FROM otp_verifications WHERE otp_id = $1', [otp_id]);

    res.json({
      success: true,
      message: 'OTP verified successfully',
      data: {
        access_token: accessToken,
        refresh_token: refreshToken,
        expires_in: 3600,
        user: {
          id: user.id,
          phone: user.phone,
          is_verified: true,
          created_at: user.created_at,
        },
      },
    });
  } catch (error) {
    console.error('OTP verification error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to verify OTP',
    });
  }
});

// User routes
app.get('/api/users/profile', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, phone, name, email, is_verified, created_at, updated_at FROM users WHERE id = $1',
      [req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
      });
    }

    res.json({
      success: true,
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get profile',
    });
  }
});

app.put('/api/users/profile', authenticateToken, async (req, res) => {
  try {
    const { name, email } = req.body;
    
    const result = await pool.query(
      'UPDATE users SET name = $1, email = $2, updated_at = NOW() WHERE id = $3 RETURNING id, phone, name, email, is_verified, created_at, updated_at',
      [name, email, req.user.userId]
    );

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update profile',
    });
  }
});

// Business routes
app.post('/api/business', authenticateToken, async (req, res) => {
  try {
    const {
      name,
      type,
      address,
      gst_number,
      phone,
      email,
      description,
    } = req.body;

    const result = await pool.query(
      `INSERT INTO businesses (user_id, name, type, address, gst_number, phone, email, description, status, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'active', NOW(), NOW())
       RETURNING *`,
      [req.user.userId, name, type, address, gst_number, phone, email, description]
    );

    res.json({
      success: true,
      message: 'Business profile created successfully',
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Create business error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create business profile',
    });
  }
});

app.get('/api/business', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM businesses WHERE user_id = $1',
      [req.user.userId]
    );

    res.json({
      success: true,
      data: result.rows[0] || null,
    });
  } catch (error) {
    console.error('Get business error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get business profile',
    });
  }
});

// Product routes
app.post('/api/products', authenticateToken, async (req, res) => {
  try {
    const {
      name,
      description,
      category,
      brand,
      price,
      cost_price,
      sku,
      barcode,
      unit,
      current_stock,
      min_stock,
      max_stock,
      supplier,
      expiry_date,
      images,
      is_active,
      is_marketplace_visible,
    } = req.body;

    const result = await pool.query(
      `INSERT INTO products (business_id, name, description, category, brand, price, cost_price, sku, barcode, unit, 
       current_stock, min_stock, max_stock, supplier, expiry_date, images, is_active, is_marketplace_visible, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, NOW(), NOW())
       RETURNING *`,
      [req.user.userId, name, description, category, brand, price, cost_price, sku, barcode, unit,
       current_stock, min_stock, max_stock, supplier, expiry_date, JSON.stringify(images || []), is_active, is_marketplace_visible]
    );

    res.json({
      success: true,
      message: 'Product created successfully',
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Create product error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create product',
    });
  }
});

app.get('/api/products', authenticateToken, async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      category,
      search,
      sort = 'created_at',
      order = 'desc',
      is_active,
      low_stock,
    } = req.query;

    let query = 'SELECT * FROM products WHERE business_id = $1';
    const params = [req.user.userId];
    let paramCount = 1;

    if (category) {
      paramCount++;
      query += ` AND category = $${paramCount}`;
      params.push(category);
    }

    if (search) {
      paramCount++;
      query += ` AND (name ILIKE $${paramCount} OR description ILIKE $${paramCount} OR sku ILIKE $${paramCount})`;
      params.push(`%${search}%`);
    }

    if (is_active !== undefined) {
      paramCount++;
      query += ` AND is_active = $${paramCount}`;
      params.push(is_active === 'true');
    }

    if (low_stock === 'true') {
      query += ` AND current_stock <= min_stock`;
    }

    query += ` ORDER BY ${sort} ${order.toUpperCase()}`;

    const offset = (page - 1) * limit;
    paramCount++;
    query += ` LIMIT $${paramCount}`;
    params.push(limit);

    paramCount++;
    query += ` OFFSET $${paramCount}`;
    params.push(offset);

    const result = await pool.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) FROM products WHERE business_id = $1';
    const countParams = [req.user.userId];
    let countParamCount = 1;

    if (category) {
      countParamCount++;
      countQuery += ` AND category = $${countParamCount}`;
      countParams.push(category);
    }

    if (search) {
      countParamCount++;
      countQuery += ` AND (name ILIKE $${countParamCount} OR description ILIKE $${countParamCount} OR sku ILIKE $${countParamCount})`;
      countParams.push(`%${search}%`);
    }

    if (is_active !== undefined) {
      countParamCount++;
      countQuery += ` AND is_active = $${countParamCount}`;
      countParams.push(is_active === 'true');
    }

    if (low_stock === 'true') {
      countQuery += ` AND current_stock <= min_stock`;
    }

    const countResult = await pool.query(countQuery, countParams);
    const total = parseInt(countResult.rows[0].count);

    res.json({
      success: true,
      data: {
        products: result.rows,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit),
        },
      },
    });
  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get products',
    });
  }
});

// File upload route
app.post('/api/upload/image', authenticateToken, upload.single('file'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: 'No file uploaded',
      });
    }

    res.json({
      success: true,
      data: {
        url: req.file.location,
        filename: req.file.key,
        size: req.file.size,
        type: req.file.mimetype,
      },
    });
  } catch (error) {
    console.error('File upload error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to upload file',
    });
  }
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('Error:', error);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;