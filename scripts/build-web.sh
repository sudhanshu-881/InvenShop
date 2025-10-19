#!/bin/bash

# InvenShop Flutter Web Build Script
# This script builds the Flutter web app with optimal settings for production

set -e  # Exit on any error

echo "🚀 Building InvenShop Flutter Web App..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
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
    print_status "Please install Flutter SDK 3.6.0 or higher"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1 | cut -d ' ' -f 2)
print_status "Flutter version: $FLUTTER_VERSION"

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get

# Check for web support
print_status "Checking Flutter web support..."
if ! flutter config --list | grep -q "enable-web: true"; then
    print_status "Enabling Flutter web support..."
    flutter config --enable-web
fi

# Build for web with optimized settings
print_status "Building Flutter web app..."
flutter build web \
    --release \
    --web-renderer html \
    --dart-define=FLUTTER_WEB_USE_SKIA=false \
    --dart-define=FLUTTER_WEB_AUTO_DETECT=true \
    --base-href / \
    --source-maps \
    --verbose

# Check if build was successful
if [ -d "build/web" ]; then
    print_success "Build completed successfully!"
    
    # List build output
    print_status "Build output:"
    ls -la build/web/
    
    # Check for main files
    if [ -f "build/web/index.html" ] && [ -f "build/web/main.dart.js" ]; then
        print_success "✅ index.html and main.dart.js found"
    else
        print_warning "⚠️  Some expected files are missing"
    fi
    
    # Get build size
    BUILD_SIZE=$(du -sh build/web | cut -f1)
    print_status "Build size: $BUILD_SIZE"
    
    print_success "🎉 InvenShop web app is ready for deployment!"
    print_status "📁 Build files are in: build/web/"
    print_status "🌐 You can test locally with: flutter run -d web-server"
    
else
    print_error "Build failed - build/web directory not found"
    exit 1
fi

print_status "Build script completed successfully! 🚀"