# InvenShop Web Deployment Guide

This guide explains how to deploy InvenShop as a fully functional web application.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.6.0 or higher
- Node.js 16+ (for Vercel CLI)
- Git repository with InvenShop code

### 1. Build Flutter Web App
```bash
# Run the build script
./scripts/build-web.sh

# Or manually build
flutter build web --release --web-renderer html --dart-define=FLUTTER_WEB_USE_SKIA=false --base-href /
```

### 2. Deploy to Vercel
```bash
# Install Vercel CLI (if not already installed)
npm install -g vercel

# Login to Vercel
vercel login

# Deploy
vercel --prod

# Or use the deployment script
./scripts/deploy-web.sh
```

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the project root:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret
CLOUDINARY_UPLOAD_PRESET=your_cloudinary_upload_preset
```

### Vercel Configuration
The `vercel.json` file is already configured for Flutter web:
```json
{
  "version": 2,
  "buildCommand": "flutter build web --release --web-renderer html --dart-define=FLUTTER_WEB_USE_SKIA=false --base-href /",
  "outputDirectory": "build/web",
  "installCommand": "flutter pub get",
  "rewrites": [
    {
      "source": "/((?!api/).*)",
      "destination": "/index.html"
    }
  ]
}
```

## 🌐 Web-Specific Features

### PWA Support
- Service worker for offline functionality
- App manifest for installability
- Responsive design for mobile and desktop

### Performance Optimizations
- HTML renderer for better compatibility
- Preloading of critical resources
- Optimized asset delivery

### Web Adaptations
- Browser-specific error handling
- Web notifications
- File download functionality
- Responsive viewport configuration

## 📱 Browser Support

### Supported Browsers
- Chrome 80+
- Firefox 75+
- Safari 13+
- Edge 80+

### Mobile Browsers
- Chrome Mobile 80+
- Safari Mobile 13+
- Samsung Internet 12+

## 🔍 Troubleshooting

### Common Issues

#### 1. Build Fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

#### 2. 404 Errors
- Check `vercel.json` configuration
- Ensure `rewrites` are properly configured
- Verify build output in `build/web/`

#### 3. Assets Not Loading
- Check base href configuration
- Verify asset paths in `web/index.html`
- Ensure proper MIME types

#### 4. Firebase Issues on Web
- Check Firebase configuration
- Verify web app settings in Firebase console
- Ensure proper CORS configuration

### Debug Mode
```bash
# Run in debug mode
flutter run -d web-server --web-port 3000

# Check browser console for errors
# Open DevTools for debugging
```

## 📊 Performance Monitoring

### Web Vitals
The app includes built-in performance monitoring:
- First Contentful Paint (FCP)
- Largest Contentful Paint (LCP)
- Cumulative Layout Shift (CLS)

### Optimization Tips
1. **Enable compression** in Vercel settings
2. **Use CDN** for static assets
3. **Optimize images** before upload
4. **Minimize JavaScript** bundle size

## 🔐 Security

### Headers
Security headers are automatically configured:
- X-Content-Type-Options: nosniff
- X-Frame-Options: DENY
- X-XSS-Protection: 1; mode=block

### HTTPS
Vercel automatically provides HTTPS certificates.

## 📈 Analytics

### Built-in Analytics
- Page load times
- Error tracking
- User interactions

### Integration
- Google Analytics (optional)
- Custom event tracking
- Performance metrics

## 🚀 Production Checklist

- [ ] Environment variables configured
- [ ] Build successful without errors
- [ ] All features working in browser
- [ ] Mobile responsive design tested
- [ ] PWA features working
- [ ] Performance optimized
- [ ] Security headers configured
- [ ] Analytics tracking enabled

## 📞 Support

For deployment issues:
1. Check the build logs in Vercel dashboard
2. Verify Flutter web compatibility
3. Test locally with `flutter run -d web-server`
4. Check browser console for errors

## 🎯 Next Steps

After successful deployment:
1. Set up custom domain (optional)
2. Configure analytics
3. Set up monitoring
4. Plan for scaling
5. Implement CI/CD pipeline