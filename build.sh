#!/bin/bash

# InvenShop Vercel Build Script
echo "🚀 Building InvenShop for Vercel..."

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for web with Vercel-optimized settings
flutter build web \
  --release \
  --web-renderer html \
  --dart-define=FLUTTER_WEB_USE_SKIA=false \
  --dart-define=FLUTTER_WEB_AUTO_DETECT=true \
  --base-href /

echo "✅ Build completed! Files are in build/web/"