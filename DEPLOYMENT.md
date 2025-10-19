# InvenShop - Production Deployment Guide

## 🚀 Overview

This guide provides comprehensive instructions for deploying InvenShop to production environments across Android, iOS, and Web platforms.

## 📋 Prerequisites

### Development Environment
- Flutter SDK 3.13.0 or higher
- Dart SDK 3.6.0 or higher
- Android Studio / VS Code with Flutter extensions
- Xcode (for iOS deployment)
- Git

### Production Requirements
- Google Play Console account (Android)
- Apple Developer account (iOS)
- Web hosting service (Web deployment)
- Backend API server
- Database server
- File storage service (AWS S3, Cloudinary, etc.)

## 🔧 Environment Setup

### 1. Clone Repository
```bash
git clone https://github.com/your-org/invenshop.git
cd invenshop
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Environment Variables
```bash
# Copy environment template
cp env.example.json env.json

# Update with production values
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your-production-anon-key",
  "OPENAI_API_KEY": "your-openai-api-key",
  "GEMINI_API_KEY": "your-gemini-api-key",
  "ANTHROPIC_API_KEY": "your-anthropic-api-key",
  "PERPLEXITY_API_KEY": "your-perplexity-api-key",
  "GOOGLE_WEB_CLIENT_ID": "your-google-web-client-id"
}
```

### 4. Update App Configuration
Edit `lib/core/app_config.dart`:
```dart
// Update for production
static const bool isProduction = true;
static const bool isDebugMode = false;
static const String baseUrl = 'https://api.invenshop.com';
```

## 📱 Android Deployment

### 1. Generate Signing Key
```bash
# Create keystore
keytool -genkey -v -keystore ~/invenshop-release-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias invenshop

# Note: Save the keystore password and key alias
```

### 2. Configure Android Signing
Create `android/key.properties`:
```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=invenshop
storeFile=../invenshop-release-key.keystore
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 3. Build Release APK
```bash
# Build APK
flutter build apk --release

# Build App Bundle (Recommended)
flutter build appbundle --release
```

### 4. Upload to Google Play Console
1. Go to [Google Play Console](https://play.google.com/console)
2. Create new application
3. Upload the `.aab` file
4. Fill in store listing details
5. Configure pricing and distribution
6. Submit for review

## 🍎 iOS Deployment

### 1. Configure iOS Project
Update `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>InvenShop</string>
<key>CFBundleIdentifier</key>
<string>com.invenshop.app</string>
<key>CFBundleVersion</key>
<string>1.0.0</string>
```

### 2. Configure Signing
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project
3. Go to Signing & Capabilities
4. Select your development team
5. Enable Automatically manage signing

### 3. Build for iOS
```bash
# Build for iOS
flutter build ios --release

# Archive for App Store
flutter build ipa --release
```

### 4. Upload to App Store Connect
1. Open Xcode
2. Go to Window > Organizer
3. Select your archive
4. Click "Distribute App"
5. Choose "App Store Connect"
6. Follow the upload process

### 5. Submit for Review
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to TestFlight or App Store
4. Submit for review

## 🌐 Web Deployment

### 1. Build for Web
```bash
# Build web version
flutter build web --release

# The build output will be in build/web/
```

### 2. Deploy to Hosting Service

#### Option A: Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase project
firebase init hosting

# Deploy
firebase deploy
```

#### Option B: Netlify
1. Connect your GitHub repository
2. Set build command: `flutter build web --release`
3. Set publish directory: `build/web`
4. Deploy

#### Option C: Vercel
1. Install Vercel CLI
```bash
npm install -g vercel
```

2. Deploy
```bash
vercel --prod
```

### 3. Configure Web App
Update `web/index.html`:
```html
<meta name="description" content="InvenShop - Digital Inventory Management for Local Retailers">
<meta name="theme-color" content="#2E7D32">
<link rel="manifest" href="manifest.json">
```

## 🔧 Backend Deployment

### 1. API Server Setup
```bash
# Example with Node.js/Express
cd backend
npm install
npm run build
npm start
```

### 2. Database Setup
```sql
-- PostgreSQL example
CREATE DATABASE invenshop;
CREATE USER invenshop_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE invenshop TO invenshop_user;
```

### 3. Environment Variables
```bash
# Backend .env
DATABASE_URL=postgresql://user:password@localhost:5432/invenshop
JWT_SECRET=your-jwt-secret
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-supabase-anon-key
```

## 📊 Monitoring & Analytics

### 1. Firebase Analytics
```dart
// Already configured in the app
// No additional setup required
```

### 2. Crash Reporting
```dart
// Sentry integration
// Configure in main.dart
```

### 3. Performance Monitoring
```dart
// Firebase Performance
// Already integrated
```

## 🔒 Security Configuration

### 1. API Security
- Enable HTTPS
- Implement rate limiting
- Use JWT authentication
- Validate all inputs
- Implement CORS properly

### 2. Data Encryption
- Encrypt sensitive data at rest
- Use HTTPS for all communications
- Implement proper key management

### 3. Privacy Compliance
- GDPR compliance
- India Data Protection Bill compliance
- User consent management
- Data retention policies

## 📈 Performance Optimization

### 1. App Performance
- Enable R8/ProGuard for Android
- Use release builds
- Optimize images
- Implement lazy loading
- Use efficient data structures

### 2. Backend Performance
- Database indexing
- Caching strategies
- CDN for static assets
- Load balancing
- Database connection pooling

## 🧪 Testing

### 1. Unit Tests
```bash
flutter test
```

### 2. Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

### 3. Widget Tests
```bash
flutter test test/widget_test.dart
```

## 📋 Pre-Launch Checklist

### App Store Requirements
- [ ] App icon (1024x1024 for iOS, 512x512 for Android)
- [ ] Screenshots for all supported devices
- [ ] App description and keywords
- [ ] Privacy policy URL
- [ ] Terms of service URL
- [ ] Support URL
- [ ] Age rating compliance

### Technical Requirements
- [ ] All features working in release mode
- [ ] No debug prints or logs
- [ ] Proper error handling
- [ ] Offline functionality tested
- [ ] Performance optimized
- [ ] Security audit completed
- [ ] Accessibility compliance
- [ ] Multi-language support tested

### Business Requirements
- [ ] Payment integration tested
- [ ] GST compliance verified
- [ ] Data backup working
- [ ] User onboarding flow tested
- [ ] Analytics tracking verified
- [ ] Push notifications working

## 🚀 Launch Strategy

### 1. Soft Launch
- Deploy to limited regions
- Monitor performance and crashes
- Gather user feedback
- Fix critical issues

### 2. Full Launch
- Deploy to all regions
- Marketing campaign
- User acquisition
- Monitor metrics

### 3. Post-Launch
- Regular updates
- Feature enhancements
- Bug fixes
- Performance improvements

## 📞 Support & Maintenance

### 1. Monitoring
- Set up alerts for crashes
- Monitor performance metrics
- Track user engagement
- Monitor server health

### 2. Updates
- Regular app updates
- Security patches
- Feature releases
- Bug fixes

### 3. User Support
- Help documentation
- FAQ section
- Contact support
- Community forum

## 🔄 CI/CD Pipeline

### 1. GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --release
      - run: flutter build ios --release
      - run: flutter build web --release
```

### 2. Automated Testing
- Unit tests on every commit
- Integration tests on PR
- Performance tests on release
- Security scans

## 📚 Documentation

### 1. API Documentation
- Swagger/OpenAPI specs
- Postman collections
- Code examples

### 2. User Documentation
- User manual
- Video tutorials
- FAQ
- Troubleshooting guide

### 3. Developer Documentation
- Architecture overview
- Code documentation
- Deployment guide
- Contributing guidelines

## 🎯 Success Metrics

### 1. Technical Metrics
- App crash rate < 1%
- API response time < 500ms
- App launch time < 2 seconds
- 99.9% uptime

### 2. Business Metrics
- User acquisition rate
- Daily/Monthly active users
- User retention rate
- Revenue metrics

### 3. User Experience Metrics
- App store rating > 4.0
- User satisfaction score
- Support ticket volume
- Feature adoption rate

---

**Note**: This deployment guide should be customized based on your specific infrastructure and requirements. Always test thoroughly in staging environments before deploying to production.