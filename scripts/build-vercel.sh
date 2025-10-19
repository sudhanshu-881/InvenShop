#!/bin/bash

# InvenShop Vercel Build Script
# This script builds the Flutter web app for Vercel deployment

set -e

echo "🚀 Building InvenShop for Vercel deployment..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build for web with Vercel-optimized settings
echo "🔨 Building Flutter web app..."
flutter build web \
  --release \
  --web-renderer html \
  --dart-define=FLUTTER_WEB_USE_SKIA=false \
  --dart-define=FLUTTER_WEB_AUTO_DETECT=true \
  --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://unpkg.com/canvaskit-wasm@0.33.0/bin/ \
  --base-href /

# Verify build output
if [ -d "build/web" ]; then
    echo "✅ Build completed successfully!"
    echo "📁 Build output: build/web/"
    echo "📊 Build size: $(du -sh build/web | cut -f1)"
    
    # List important files
    echo "📋 Important files:"
    ls -la build/web/ | grep -E "\.(html|js|css|json)$"
    
    echo ""
    echo "🎯 Next steps:"
    echo "1. Deploy to Vercel: vercel --prod"
    echo "2. Or push to GitHub and connect to Vercel"
    echo "3. Check deployment at your Vercel URL"
    
else
    echo "❌ Build failed! build/web directory not found."
    exit 1
fi