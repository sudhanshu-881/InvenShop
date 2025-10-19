import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

/// Web-specific adaptations and utilities for InvenShop
class WebAdaptations {
  static bool get isWeb => kIsWeb;
  
  /// Initialize web-specific features
  static void initialize() {
    if (!isWeb) return;
    
    // Set up web-specific configurations
    _setupWebViewport();
    _setupWebSecurity();
    _setupWebPerformance();
  }
  
  /// Configure viewport for better mobile experience on web
  static void _setupWebViewport() {
    html.document.querySelector('meta[name="viewport"]')?.setAttribute(
      'content',
      'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'
    );
  }
  
  /// Set up web security headers
  static void _setupWebSecurity() {
    // Add security headers via meta tags
    final securityMeta = html.document.createElement('meta');
    securityMeta.setAttribute('http-equiv', 'Content-Security-Policy');
    securityMeta.setAttribute('content', "default-src 'self' 'unsafe-inline' 'unsafe-eval' data: blob: https:;");
    html.document.head?.append(securityMeta);
  }
  
  /// Optimize web performance
  static void _setupWebPerformance() {
    // Preload critical resources
    _preloadCriticalResources();
    
    // Set up performance monitoring
    _setupPerformanceMonitoring();
  }
  
  /// Preload critical resources for faster loading
  static void _preloadCriticalResources() {
    // Preload main.dart.js
    final preloadScript = html.document.createElement('link');
    preloadScript.setAttribute('rel', 'preload');
    preloadScript.setAttribute('href', 'main.dart.js');
    preloadScript.setAttribute('as', 'script');
    html.document.head?.append(preloadScript);
    
    // Preload flutter.js
    final preloadFlutter = html.document.createElement('link');
    preloadFlutter.setAttribute('rel', 'preload');
    preloadFlutter.setAttribute('href', 'flutter.js');
    preloadFlutter.setAttribute('as', 'script');
    html.document.head?.append(preloadFlutter);
  }
  
  /// Set up performance monitoring
  static void _setupPerformanceMonitoring() {
    // Monitor web vitals
    html.window.addEventListener('load', (event) {
      _measureWebVitals();
    });
  }
  
  /// Measure web vitals for performance monitoring
  static void _measureWebVitals() {
    // Measure First Contentful Paint
    final observer = html.PerformanceObserver((entries) {
      for (final entry in entries) {
        if (entry.entryType == 'paint' && entry.name == 'first-contentful-paint') {
          print('First Contentful Paint: ${entry.startTime}ms');
        }
      }
    });
    
    observer.observe({'entryTypes': ['paint']});
  }
  
  /// Show web-specific notifications
  static void showWebNotification(String title, String body) {
    if (!isWeb) return;
    
    // Use browser notifications if available
    if (html.Notification.supported) {
      html.Notification.requestPermission().then((permission) {
        if (permission == 'granted') {
          html.Notification(title, body: body);
        }
      });
    }
  }
  
  /// Handle web-specific navigation
  static void handleWebNavigation(String route) {
    if (!isWeb) return;
    
    // Update browser URL without page reload
    html.window.history.pushState(null, '', route);
  }
  
  /// Get web-specific device info
  static Map<String, dynamic> getWebDeviceInfo() {
    if (!isWeb) return {};
    
    return {
      'userAgent': html.window.navigator.userAgent,
      'platform': html.window.navigator.platform,
      'language': html.window.navigator.language,
      'screenWidth': html.window.screen?.width,
      'screenHeight': html.window.screen?.height,
      'devicePixelRatio': html.window.devicePixelRatio,
    };
  }
  
  /// Handle web-specific file operations
  static Future<void> downloadFile(String fileName, List<int> bytes) async {
    if (!isWeb) return;
    
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrl(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
  
  /// Show web-specific loading indicator
  static Widget buildWebLoadingIndicator() {
    if (!isWeb) return const SizedBox.shrink();
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🏪 InvenShop',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Loading your digital shop assistant...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Handle web-specific errors
  static Widget buildWebErrorWidget(String error) {
    if (!isWeb) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Web App Error',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              html.window.location.reload();
            },
            child: const Text('Reload Page'),
          ),
        ],
      ),
    );
  }
}