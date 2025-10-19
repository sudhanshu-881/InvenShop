# InvenShop API Documentation

## 🚀 Overview

This document provides comprehensive API documentation for the InvenShop backend services. The API follows RESTful principles and uses JSON for data exchange.

## 🔗 Base URL

```
Production: https://api.invenshop.com/v1
Staging: https://staging-api.invenshop.com/v1
Development: http://localhost:3000/v1
```

## 🔐 Authentication

### OTP-based Authentication

All API endpoints require authentication except for OTP generation and verification.

#### Generate OTP
```http
POST /auth/otp/generate
Content-Type: application/json

{
  "phone": "9876543210",
  "country_code": "+91"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "otp_id": "otp_123456789",
    "expires_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Verify OTP
```http
POST /auth/otp/verify
Content-Type: application/json

{
  "phone": "9876543210",
  "otp": "123456",
  "otp_id": "otp_123456789"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP verified successfully",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 3600,
    "user": {
      "id": "user_123",
      "phone": "9876543210",
      "is_verified": true,
      "created_at": "2024-01-01T10:00:00Z"
    }
  }
}
```

#### Refresh Token
```http
POST /auth/refresh
Content-Type: application/json
Authorization: Bearer <refresh_token>

{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## 👤 User Management

### Get User Profile
```http
GET /users/profile
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user_123",
    "phone": "9876543210",
    "name": "Rajesh Kumar",
    "email": "rajesh@example.com",
    "is_verified": true,
    "created_at": "2024-01-01T10:00:00Z",
    "updated_at": "2024-01-01T10:00:00Z"
  }
}
```

### Update User Profile
```http
PUT /users/profile
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Rajesh Kumar",
  "email": "rajesh@example.com"
}
```

## 🏪 Business Management

### Create Business Profile
```http
POST /business
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Rajesh Kumar General Store",
  "type": "Kirana Store",
  "address": "123 Main Street, Sector 5, Noida",
  "gst_number": "27ABCDE1234F1Z5",
  "phone": "9876543210",
  "email": "store@example.com",
  "description": "General store selling daily essentials"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Business profile created successfully",
  "data": {
    "id": "business_123",
    "name": "Rajesh Kumar General Store",
    "type": "Kirana Store",
    "address": "123 Main Street, Sector 5, Noida",
    "gst_number": "27ABCDE1234F1Z5",
    "phone": "9876543210",
    "email": "store@example.com",
    "description": "General store selling daily essentials",
    "status": "active",
    "created_at": "2024-01-01T10:00:00Z",
    "updated_at": "2024-01-01T10:00:00Z"
  }
}
```

### Get Business Profile
```http
GET /business
Authorization: Bearer <access_token>
```

### Update Business Profile
```http
PUT /business
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Updated Store Name",
  "description": "Updated description"
}
```

## 📦 Product Management

### Create Product
```http
POST /products
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Tata Salt 1kg",
  "description": "Iodized salt",
  "category": "Groceries",
  "brand": "Tata",
  "price": 25.0,
  "cost_price": 20.0,
  "sku": "TATA_SALT_1KG",
  "barcode": "8901234567890",
  "unit": "kg",
  "current_stock": 100,
  "min_stock": 10,
  "max_stock": 500,
  "supplier": "Tata Chemicals",
  "expiry_date": "2025-12-31",
  "images": [
    "https://example.com/image1.jpg",
    "https://example.com/image2.jpg"
  ],
  "is_active": true,
  "is_marketplace_visible": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Product created successfully",
  "data": {
    "id": "product_123",
    "name": "Tata Salt 1kg",
    "description": "Iodized salt",
    "category": "Groceries",
    "brand": "Tata",
    "price": 25.0,
    "cost_price": 20.0,
    "sku": "TATA_SALT_1KG",
    "barcode": "8901234567890",
    "unit": "kg",
    "current_stock": 100,
    "min_stock": 10,
    "max_stock": 500,
    "supplier": "Tata Chemicals",
    "expiry_date": "2025-12-31",
    "images": [
      "https://example.com/image1.jpg",
      "https://example.com/image2.jpg"
    ],
    "is_active": true,
    "is_marketplace_visible": true,
    "created_at": "2024-01-01T10:00:00Z",
    "updated_at": "2024-01-01T10:00:00Z"
  }
}
```

### Get Products
```http
GET /products?page=1&limit=20&category=Groceries&search=tata
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 100)
- `category`: Filter by category
- `search`: Search term
- `sort`: Sort field (name, price, created_at)
- `order`: Sort order (asc, desc)
- `is_active`: Filter by active status
- `low_stock`: Filter low stock items

**Response:**
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "product_123",
        "name": "Tata Salt 1kg",
        "category": "Groceries",
        "price": 25.0,
        "current_stock": 100,
        "is_active": true,
        "created_at": "2024-01-01T10:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "pages": 5
    }
  }
}
```

### Get Product by ID
```http
GET /products/{product_id}
Authorization: Bearer <access_token>
```

### Update Product
```http
PUT /products/{product_id}
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Updated Product Name",
  "price": 30.0,
  "current_stock": 150
}
```

### Delete Product
```http
DELETE /products/{product_id}
Authorization: Bearer <access_token>
```

### Bulk Import Products
```http
POST /products/bulk-import
Authorization: Bearer <access_token>
Content-Type: multipart/form-data

{
  "file": <csv_file>,
  "format": "csv"
}
```

## 👥 Customer Management

### Create Customer
```http
POST /customers
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Amit Kumar",
  "phone": "9876543210",
  "email": "amit@example.com",
  "address": "456 Sector 5, Noida",
  "credit_limit": 5000.0,
  "notes": "Regular customer"
}
```

### Get Customers
```http
GET /customers?page=1&limit=20&search=amit
Authorization: Bearer <access_token>
```

### Update Customer
```http
PUT /customers/{customer_id}
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Updated Name",
  "credit_limit": 10000.0
}
```

### Record Payment
```http
POST /customers/{customer_id}/payments
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "amount": 1000.0,
  "payment_method": "Cash",
  "notes": "Payment received"
}
```

## 💰 Billing & POS

### Create Bill
```http
POST /bills
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "customer_id": "customer_123",
  "items": [
    {
      "product_id": "product_123",
      "quantity": 2,
      "price": 25.0,
      "discount": 0.0
    }
  ],
  "subtotal": 50.0,
  "discount_amount": 0.0,
  "gst_amount": 9.0,
  "total_amount": 59.0,
  "payment_method": "Cash",
  "notes": "Thank you for shopping"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Bill created successfully",
  "data": {
    "id": "bill_123",
    "bill_number": "INV-2024-001",
    "customer_id": "customer_123",
    "items": [
      {
        "product_id": "product_123",
        "product_name": "Tata Salt 1kg",
        "quantity": 2,
        "price": 25.0,
        "discount": 0.0,
        "total": 50.0
      }
    ],
    "subtotal": 50.0,
    "discount_amount": 0.0,
    "gst_amount": 9.0,
    "total_amount": 59.0,
    "payment_method": "Cash",
    "notes": "Thank you for shopping",
    "created_at": "2024-01-01T10:00:00Z"
  }
}
```

### Get Bills
```http
GET /bills?page=1&limit=20&start_date=2024-01-01&end_date=2024-01-31
Authorization: Bearer <access_token>
```

### Get Bill by ID
```http
GET /bills/{bill_id}
Authorization: Bearer <access_token>
```

## 📊 Analytics & Reports

### Get Dashboard Data
```http
GET /analytics/dashboard
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "sales": {
      "today": 2500.0,
      "yesterday": 2000.0,
      "this_week": 15000.0,
      "this_month": 60000.0,
      "growth_percentage": 25.0
    },
    "inventory": {
      "total_products": 150,
      "low_stock": 5,
      "out_of_stock": 2,
      "total_value": 50000.0
    },
    "customers": {
      "total": 200,
      "active": 150,
      "new_this_month": 25,
      "credit_due": 5000.0
    },
    "top_products": [
      {
        "product_id": "product_123",
        "name": "Tata Salt 1kg",
        "sales": 100,
        "revenue": 2500.0
      }
    ]
  }
}
```

### Get Sales Report
```http
GET /analytics/sales?start_date=2024-01-01&end_date=2024-01-31&group_by=day
Authorization: Bearer <access_token>
```

### Get Inventory Report
```http
GET /analytics/inventory?category=Groceries&low_stock=true
Authorization: Bearer <access_token>
```

### Get Customer Report
```http
GET /analytics/customers?start_date=2024-01-01&end_date=2024-01-31
Authorization: Bearer <access_token>
```

## 🛒 Marketplace

### Get Marketplace Products
```http
GET /marketplace/products?page=1&limit=20&category=Groceries&location=lat,lng&radius=5
Authorization: Bearer <access_token>
```

### Create Marketplace Listing
```http
POST /marketplace/listings
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "product_id": "product_123",
  "price": 25.0,
  "is_active": true,
  "delivery_available": true,
  "delivery_radius": 5.0
}
```

### Update Marketplace Listing
```http
PUT /marketplace/listings/{listing_id}
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "price": 30.0,
  "is_active": false
}
```

## 📱 Notifications

### Get Notifications
```http
GET /notifications?page=1&limit=20&unread_only=true
Authorization: Bearer <access_token>
```

### Mark Notification as Read
```http
PUT /notifications/{notification_id}/read
Authorization: Bearer <access_token>
```

### Mark All Notifications as Read
```http
PUT /notifications/read-all
Authorization: Bearer <access_token>
```

## 🔍 Search

### Global Search
```http
GET /search?q=tata&type=products,customers&limit=10
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "product_123",
        "name": "Tata Salt 1kg",
        "category": "Groceries",
        "price": 25.0
      }
    ],
    "customers": [
      {
        "id": "customer_123",
        "name": "Amit Kumar",
        "phone": "9876543210"
      }
    ]
  }
}
```

## 📁 File Upload

### Upload Image
```http
POST /upload/image
Authorization: Bearer <access_token>
Content-Type: multipart/form-data

{
  "file": <image_file>,
  "type": "product"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "url": "https://cdn.invenshop.com/images/product_123.jpg",
    "filename": "product_123.jpg",
    "size": 1024000,
    "type": "image/jpeg"
  }
}
```

## 🔧 System

### Health Check
```http
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T10:00:00Z",
  "version": "1.0.0",
  "services": {
    "database": "healthy",
    "redis": "healthy",
    "storage": "healthy"
  }
}
```

### Get App Version
```http
GET /version
```

**Response:**
```json
{
  "version": "1.0.0",
  "build_number": "1",
  "min_android_version": "21",
  "min_ios_version": "12.0",
  "force_update": false
}
```

## ❌ Error Handling

### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "phone",
      "reason": "Invalid phone number format"
    }
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### Common Error Codes
- `VALIDATION_ERROR`: Input validation failed
- `AUTHENTICATION_ERROR`: Invalid or expired token
- `AUTHORIZATION_ERROR`: Insufficient permissions
- `NOT_FOUND`: Resource not found
- `DUPLICATE_ERROR`: Resource already exists
- `RATE_LIMIT_ERROR`: Too many requests
- `SERVER_ERROR`: Internal server error

## 📊 Rate Limiting

- **Authentication endpoints**: 5 requests per minute
- **General API endpoints**: 100 requests per minute
- **File upload endpoints**: 10 requests per minute
- **Search endpoints**: 50 requests per minute

## 🔒 Security

### Headers Required
```
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

### HTTPS Only
All API endpoints require HTTPS in production.

### CORS
CORS is configured for the following origins:
- `https://invenshop.com`
- `https://app.invenshop.com`
- `https://admin.invenshop.com`

## 📝 Pagination

All list endpoints support pagination:

```
GET /endpoint?page=1&limit=20
```

**Response:**
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "pages": 5,
    "has_next": true,
    "has_prev": false
  }
}
```

## 🔄 Webhooks

### Order Created
```json
{
  "event": "order.created",
  "data": {
    "order_id": "order_123",
    "customer_id": "customer_123",
    "total_amount": 100.0,
    "created_at": "2024-01-01T10:00:00Z"
  }
}
```

### Low Stock Alert
```json
{
  "event": "inventory.low_stock",
  "data": {
    "product_id": "product_123",
    "product_name": "Tata Salt 1kg",
    "current_stock": 5,
    "min_stock": 10
  }
}
```

## 📚 SDKs

### Flutter SDK
```dart
// Install
dependencies:
  invenshop_sdk: ^1.0.0

// Usage
import 'package:invenshop_sdk/invenshop_sdk.dart';

final client = InvenShopClient(
  baseUrl: 'https://api.invenshop.com/v1',
  apiKey: 'your-api-key',
);
```

### JavaScript SDK
```javascript
// Install
npm install invenshop-sdk

// Usage
import InvenShop from 'invenshop-sdk';

const client = new InvenShop({
  baseUrl: 'https://api.invenshop.com/v1',
  apiKey: 'your-api-key'
});
```

## 🧪 Testing

### Postman Collection
Download the Postman collection: [InvenShop API.postman_collection.json](https://api.invenshop.com/docs/postman-collection.json)

### API Documentation
Interactive API documentation: [https://api.invenshop.com/docs](https://api.invenshop.com/docs)

## 📞 Support

- **API Support**: api-support@invenshop.com
- **Documentation**: [https://docs.invenshop.com](https://docs.invenshop.com)
- **Status Page**: [https://status.invenshop.com](https://status.invenshop.com)

---

**Note**: This API documentation is version 1.0.0. For the latest updates, please refer to the [changelog](https://api.invenshop.com/docs/changelog).