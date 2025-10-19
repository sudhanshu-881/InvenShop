#!/bin/bash

# InvenShop Release Preparation Script
# This script prepares the app for store submission

set -e

echo "🚀 Starting InvenShop Release Preparation..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1 | cut -d ' ' -f 2)
print_status "Flutter version: $FLUTTER_VERSION"

# Clean and get dependencies
print_status "Cleaning project and getting dependencies..."
flutter clean
flutter pub get

# Run tests
print_status "Running tests..."
flutter test

# Check for any issues
print_status "Running flutter analyze..."
flutter analyze

# Update version number
print_status "Updating version number..."
VERSION=$(grep version: pubspec.yaml | cut -d ' ' -f 2)
print_status "Current version: $VERSION"

# Build for Android
print_status "Building Android APK..."
flutter build apk --release

# Build Android App Bundle (recommended for Play Store)
print_status "Building Android App Bundle..."
flutter build appbundle --release

# Build for iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_status "Building iOS app..."
    flutter build ios --release
    
    print_status "Building iOS archive..."
    flutter build ipa --release
else
    print_warning "Skipping iOS build (not on macOS)"
fi

# Build for Web
print_status "Building Web app..."
flutter build web --release

# Create release directory
RELEASE_DIR="release_$(date +%Y%m%d_%H%M%S)"
mkdir -p $RELEASE_DIR

# Copy builds to release directory
print_status "Copying builds to release directory..."

# Android builds
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    cp build/app/outputs/flutter-apk/app-release.apk $RELEASE_DIR/invenshop-v$VERSION.apk
    print_status "Android APK copied to $RELEASE_DIR/invenshop-v$VERSION.apk"
fi

if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    cp build/app/outputs/bundle/release/app-release.aab $RELEASE_DIR/invenshop-v$VERSION.aab
    print_status "Android AAB copied to $RELEASE_DIR/invenshop-v$VERSION.aab"
fi

# iOS builds
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -f "build/ios/ipa/invenshop.ipa" ]; then
        cp build/ios/ipa/invenshop.ipa $RELEASE_DIR/invenshop-v$VERSION.ipa
        print_status "iOS IPA copied to $RELEASE_DIR/invenshop-v$VERSION.ipa"
    fi
fi

# Web build
if [ -d "build/web" ]; then
    cp -r build/web $RELEASE_DIR/web
    print_status "Web build copied to $RELEASE_DIR/web"
fi

# Create release notes
print_status "Creating release notes..."
cat > $RELEASE_DIR/RELEASE_NOTES.md << EOF
# InvenShop v$VERSION Release Notes

## 🚀 New Features
- Digital inventory management for local retailers
- Billing and POS system with GST compliance
- Customer management with credit tracking
- Analytics and reporting dashboard
- Multi-language support (Hindi, English, Regional)
- Offline-first architecture
- Barcode scanning and product management

## 📱 Platform Support
- Android 5.0+ (API 21+)
- iOS 12.0+
- Web (Progressive Web App)

## 🔧 Technical Improvements
- Performance optimizations
- Enhanced error handling
- Improved offline capabilities
- Better user experience
- Security enhancements

## 📦 Installation
- **Android**: Install the APK file or upload AAB to Play Store
- **iOS**: Install the IPA file or upload to App Store Connect
- **Web**: Deploy the web folder to your hosting service

## 🐛 Bug Fixes
- Fixed various UI/UX issues
- Improved stability and performance
- Enhanced error handling

## 📞 Support
- Email: support@invenshop.com
- Website: https://invenshop.com
- Documentation: https://docs.invenshop.com

---
Generated on: $(date)
Flutter Version: $FLUTTER_VERSION
EOF

# Create deployment checklist
print_status "Creating deployment checklist..."
cat > $RELEASE_DIR/DEPLOYMENT_CHECKLIST.md << EOF
# InvenShop Deployment Checklist

## Pre-Deployment
- [ ] All tests passing
- [ ] Code review completed
- [ ] Version number updated
- [ ] Release notes prepared
- [ ] Backend API deployed
- [ ] Database migrations run
- [ ] Environment variables configured

## Android Play Store
- [ ] AAB file uploaded to Play Console
- [ ] Store listing completed
- [ ] Screenshots uploaded
- [ ] App description written
- [ ] Privacy policy URL added
- [ ] Content rating completed
- [ ] Pricing and distribution set
- [ ] App submitted for review

## iOS App Store
- [ ] IPA file uploaded to App Store Connect
- [ ] App information completed
- [ ] Screenshots uploaded
- [ ] App description written
- [ ] Privacy policy URL added
- [ ] Age rating completed
- [ ] Pricing and availability set
- [ ] App submitted for review

## Web Deployment
- [ ] Web build deployed to hosting service
- [ ] Domain configured
- [ ] SSL certificate installed
- [ ] CDN configured (if applicable)
- [ ] Analytics tracking set up

## Post-Deployment
- [ ] Monitor app performance
- [ ] Check crash reports
- [ ] Monitor user feedback
- [ ] Update documentation
- [ ] Notify users of update

## Marketing
- [ ] Social media posts
- [ ] Press release
- [ ] User onboarding materials
- [ ] Support documentation
- [ ] Training materials

---
Generated on: $(date)
EOF

# Generate app signing info (Android)
print_status "Generating Android signing information..."
if [ -f "android/key.properties" ]; then
    print_status "Android signing configured"
    print_warning "Make sure to backup your keystore file securely"
else
    print_warning "Android signing not configured. Please set up key.properties"
fi

# Check for required files
print_status "Checking for required files..."

# Android
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    print_status "✓ Android manifest found"
else
    print_error "✗ Android manifest not found"
fi

# iOS
if [ -f "ios/Runner/Info.plist" ]; then
    print_status "✓ iOS Info.plist found"
else
    print_error "✗ iOS Info.plist not found"
fi

# Web
if [ -f "web/index.html" ]; then
    print_status "✓ Web index.html found"
else
    print_error "✗ Web index.html not found"
fi

# Create summary
print_status "Release preparation completed!"
echo ""
echo "📁 Release files created in: $RELEASE_DIR"
echo "📱 Android APK: invenshop-v$VERSION.apk"
echo "📱 Android AAB: invenshop-v$VERSION.aab"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 iOS IPA: invenshop-v$VERSION.ipa"
fi
echo "🌐 Web build: web/"
echo "📝 Release notes: RELEASE_NOTES.md"
echo "✅ Deployment checklist: DEPLOYMENT_CHECKLIST.md"
echo ""
echo "Next steps:"
echo "1. Review the deployment checklist"
echo "2. Upload builds to respective app stores"
echo "3. Deploy web version to hosting service"
echo "4. Monitor app performance and user feedback"
echo ""
print_status "Happy releasing! 🎉"