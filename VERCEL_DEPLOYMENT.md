# InvenShop Vercel Deployment Guide

## 🚀 **Fix 404 Error and Deploy Flutter Web to Vercel**

This guide will help you fix the 404 error and properly deploy your InvenShop Flutter web app to Vercel.

## 🔍 **Why You're Getting 404 Error**

The 404 error occurs because:
1. **Vercel doesn't know how to handle Flutter web builds** by default
2. **Missing proper routing configuration** for SPA (Single Page Application)
3. **Incorrect build output directory** structure
4. **Missing Vercel configuration** files

## ✅ **Solution: Complete Vercel Configuration**

### **1. Files Created/Updated**

#### **vercel.json** - Vercel Configuration
```json
{
  "version": 2,
  "builds": [
    {
      "src": "build/web/**",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/build/web/$1"
    }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-XSS-Protection",
          "value": "1; mode=block"
        }
      ]
    },
    {
      "source": "/(.*\\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot))",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    }
  ],
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/build/web/$1"
    }
  ]
}
```

#### **package.json** - Build Scripts
```json
{
  "name": "invenshop-web",
  "version": "1.0.0",
  "description": "InvenShop - Digital Shop Assistant",
  "scripts": {
    "build": "flutter build web --release --web-renderer html --dart-define=FLUTTER_WEB_USE_SKIA=false",
    "dev": "flutter run -d web-server --web-port 3000",
    "clean": "flutter clean",
    "get": "flutter pub get"
  },
  "engines": {
    "node": ">=16.0.0"
  },
  "devDependencies": {
    "@vercel/static": "^6.0.0"
  }
}
```

#### **.vercelignore** - Ignore Unnecessary Files
```
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
ios/
android/
linux/
macos/
windows/

# IDE
.vscode/
.idea/
*.iml
*.ipr
*.iws

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Environment
.env
.env.local
.env.production

# Dependencies
node_modules/

# Git
.git/
.gitignore

# Documentation
*.md
!README.md

# Scripts
scripts/

# Backend
backend/

# Test
test/
```

## 🔧 **Step-by-Step Deployment Fix**

### **Step 1: Install Vercel CLI (if not already installed)**
```bash
npm install -g vercel
```

### **Step 2: Build Flutter Web App**
```bash
# Navigate to your project directory
cd /workspace

# Clean and build
flutter clean
flutter pub get
flutter build web --release --web-renderer html --dart-define=FLUTTER_WEB_USE_SKIA=false
```

### **Step 3: Deploy to Vercel**
```bash
# Deploy to Vercel
vercel --prod

# Or if you want to deploy to a specific project
vercel --prod --name invenshop
```

### **Step 4: Alternative - GitHub Integration**
1. **Push to GitHub** (if not already done)
2. **Connect to Vercel**:
   - Go to [vercel.com](https://vercel.com)
   - Click "New Project"
   - Import your GitHub repository
   - Vercel will automatically detect the configuration

## 🎯 **Build Script for Easy Deployment**

### **Use the Build Script**
```bash
# Make script executable (already done)
chmod +x scripts/build-vercel.sh

# Run build script
./scripts/build-vercel.sh
```

### **Manual Build Commands**
```bash
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
```

## 🔍 **Troubleshooting Common Issues**

### **1. Still Getting 404 Error**
**Check:**
- Ensure `vercel.json` is in the root directory
- Verify `build/web` directory exists after build
- Check Vercel deployment logs

**Fix:**
```bash
# Rebuild with proper settings
flutter clean
flutter build web --release --web-renderer html --dart-define=FLUTTER_WEB_USE_SKIA=false
vercel --prod
```

### **2. Assets Not Loading**
**Check:**
- Verify base href in `web/index.html` is set to `/`
- Check if assets are in `build/web` directory
- Verify Vercel routing configuration

**Fix:**
```html
<!-- In web/index.html -->
<base href="/" />
```

### **3. Routing Issues (SPA)**
**Check:**
- Verify `vercel.json` has proper rewrites
- Check if all routes redirect to `index.html`

**Fix:**
```json
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/build/web/$1"
    }
  ]
}
```

### **4. Build Fails**
**Check:**
- Flutter version compatibility
- Missing dependencies
- Web renderer issues

**Fix:**
```bash
# Update Flutter
flutter upgrade

# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

## 📊 **Verification Steps**

### **1. Local Testing**
```bash
# Test locally
flutter run -d web-server --web-port 3000

# Open http://localhost:3000
```

### **2. Build Verification**
```bash
# Check build output
ls -la build/web/

# Should see:
# - index.html
# - main.dart.js
# - flutter.js
# - assets/
# - icons/
```

### **3. Vercel Deployment Check**
```bash
# Check deployment status
vercel ls

# Check logs
vercel logs [deployment-url]
```

## 🚀 **Production Optimization**

### **1. Performance Optimizations**
```dart
// In main.dart - enable web optimizations
void main() {
  // Enable web optimizations
  if (kIsWeb) {
    // Configure web-specific settings
  }
  
  runApp(MyApp());
}
```

### **2. Caching Headers**
The `vercel.json` already includes proper caching headers for static assets.

### **3. Security Headers**
The `vercel.json` includes security headers:
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`

## 📱 **Environment Variables**

### **1. Create .env.local for Vercel**
```env
# Supabase Configuration
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret
CLOUDINARY_UPLOAD_PRESET=your_upload_preset

# Firebase Configuration (if using)
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY=your_firebase_private_key
FIREBASE_CLIENT_EMAIL=your_firebase_client_email
```

### **2. Add to Vercel Dashboard**
1. Go to your Vercel project dashboard
2. Go to Settings → Environment Variables
3. Add all required environment variables
4. Redeploy

## 🎯 **Expected Results**

After following this guide, you should have:

✅ **Working Vercel deployment** without 404 errors
✅ **Proper routing** for Flutter web SPA
✅ **Optimized build** for production
✅ **Security headers** configured
✅ **Caching** for static assets
✅ **Environment variables** properly set

## 🔄 **Deployment Workflow**

### **For Future Updates:**
1. **Make changes** to your Flutter code
2. **Test locally**: `flutter run -d web-server`
3. **Build for production**: `./scripts/build-vercel.sh`
4. **Deploy**: `vercel --prod`
5. **Verify**: Check your Vercel URL

### **Automated Deployment (GitHub Integration):**
1. **Push to GitHub** - Vercel automatically deploys
2. **Check deployment status** in Vercel dashboard
3. **Monitor logs** for any issues

## 📚 **Additional Resources**

- [Vercel Documentation](https://vercel.com/docs)
- [Flutter Web Deployment](https://flutter.dev/docs/deployment/web)
- [Vercel Flutter Guide](https://vercel.com/guides/deploying-flutter-with-vercel)

---

**Your InvenShop app should now deploy successfully to Vercel without 404 errors!** 🎉

**Next step:** Run `./scripts/build-vercel.sh` and then `vercel --prod` to deploy your fixed app!