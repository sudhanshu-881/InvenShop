#!/bin/bash

# InvenShop Web Deployment Script
# This script builds and deploys the Flutter web app to Vercel

set -e  # Exit on any error

echo "🚀 Deploying InvenShop Web App..."

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

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Not in Flutter project directory"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    print_status "Please install Flutter SDK 3.6.0 or higher"
    exit 1
fi

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    print_warning "Vercel CLI not found. Installing..."
    npm install -g vercel
fi

# Build the Flutter web app
print_status "Building Flutter web app..."
./scripts/build-web.sh

# Check if build was successful
if [ ! -d "build/web" ]; then
    print_error "Build failed - build/web directory not found"
    exit 1
fi

print_success "Flutter web build completed!"

# Deploy to Vercel
print_status "Deploying to Vercel..."

# Check if already logged in to Vercel
if ! vercel whoami &> /dev/null; then
    print_status "Please log in to Vercel..."
    vercel login
fi

# Deploy
vercel --prod

print_success "🎉 Deployment completed successfully!"
print_status "Your InvenShop web app is now live!"

# Get deployment URL
DEPLOYMENT_URL=$(vercel ls --json | jq -r '.[0].url' 2>/dev/null || echo "Check Vercel dashboard")
print_status "Deployment URL: https://$DEPLOYMENT_URL"

print_status "Deployment script completed! 🚀"