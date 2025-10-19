const AWS = require('aws-sdk');
require('dotenv').config();

// Configure AWS
AWS.config.update({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'us-east-1',
});

const s3 = new AWS.S3();

async function setupS3Bucket() {
  const bucketName = process.env.AWS_S3_BUCKET;
  
  try {
    console.log('Setting up S3 bucket...');

    // Check if bucket exists
    try {
      await s3.headBucket({ Bucket: bucketName }).promise();
      console.log(`Bucket ${bucketName} already exists`);
    } catch (error) {
      if (error.statusCode === 404) {
        // Create bucket
        console.log(`Creating bucket ${bucketName}...`);
        await s3.createBucket({ Bucket: bucketName }).promise();
        console.log(`Bucket ${bucketName} created successfully`);
      } else {
        throw error;
      }
    }

    // Configure CORS
    const corsConfig = {
      Bucket: bucketName,
      CORSConfiguration: {
        CORSRules: [
          {
            AllowedHeaders: ['*'],
            AllowedMethods: ['GET', 'PUT', 'POST', 'DELETE', 'HEAD'],
            AllowedOrigins: [
              'https://invenshop.com',
              'https://app.invenshop.com',
              'https://admin.invenshop.com',
              'http://localhost:3000',
              'http://localhost:3001'
            ],
            ExposeHeaders: ['ETag'],
            MaxAgeSeconds: 3000
          }
        ]
      }
    };

    await s3.putBucketCors(corsConfig).promise();
    console.log('CORS configuration applied');

    // Configure bucket policy for public read access to uploaded files
    const bucketPolicy = {
      Bucket: bucketName,
      Policy: JSON.stringify({
        Version: '2012-10-17',
        Statement: [
          {
            Sid: 'PublicReadGetObject',
            Effect: 'Allow',
            Principal: '*',
            Action: 's3:GetObject',
            Resource: `arn:aws:s3:::${bucketName}/*`
          }
        ]
      })
    };

    await s3.putBucketPolicy(bucketPolicy).promise();
    console.log('Bucket policy applied');

    // Create folder structure
    const folders = [
      'products/',
      'customers/',
      'bills/',
      'categories/',
      'suppliers/',
      'general/',
      'temp/'
    ];

    for (const folder of folders) {
      await s3.putObject({
        Bucket: bucketName,
        Key: folder,
        Body: '',
      }).promise();
      console.log(`Created folder: ${folder}`);
    }

    console.log('S3 setup completed successfully!');
    console.log(`Bucket URL: https://${bucketName}.s3.${process.env.AWS_REGION || 'us-east-1'}.amazonaws.com/`);

  } catch (error) {
    console.error('S3 setup failed:', error);
    throw error;
  }
}

// Run setup
setupS3Bucket().catch(console.error);