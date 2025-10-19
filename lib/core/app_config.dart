class AppConfig {
  // App Information
  static const String appName = 'InvenShop';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // API Configuration
  static const String baseUrl = 'https://api.invenshop.com';
  static const String apiVersion = 'v1';
  static const int apiTimeout = 30000; // 30 seconds
  
  // Database Configuration
  static const String databaseName = 'invenshop.db';
  static const int databaseVersion = 1;
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableWhatsAppIntegration = true;
  static const bool enableGSTCompliance = true;
  static const bool enableMultiLanguage = true;
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 2.0;
  
  // Business Configuration
  static const double defaultGSTRate = 0.18; // 18%
  static const int maxCreditLimit = 50000; // ₹50,000
  static const int maxProductImages = 5;
  static const int maxBulkUploadSize = 1000;
  
  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int phoneNumberLength = 10;
  static const int otpLength = 6;
  
  // Cache Configuration
  static const int imageCacheMaxSize = 100; // MB
  static const int dataCacheMaxSize = 50; // MB
  static const Duration cacheExpiry = Duration(days: 7);
  
  // Sync Configuration
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 5);
  
  // Notification Configuration
  static const String lowStockThreshold = '5';
  static const String expiryWarningDays = '7';
  static const Duration notificationCheckInterval = Duration(hours: 6);
  
  // Supported Languages
  static const List<String> supportedLanguages = [
    'en', // English
    'hi', // Hindi
    'ta', // Tamil
    'te', // Telugu
    'bn', // Bengali
    'gu', // Gujarati
    'mr', // Marathi
    'pa', // Punjabi
    'kn', // Kannada
    'ml', // Malayalam
  ];
  
  // Default Language
  static const String defaultLanguage = 'en';
  
  // Payment Methods
  static const List<String> supportedPaymentMethods = [
    'Cash',
    'Card',
    'UPI',
    'Credit',
    'Wallet',
  ];
  
  // Product Categories
  static const List<String> defaultCategories = [
    'Groceries',
    'Food & Beverages',
    'Snacks',
    'Beverages',
    'Health & Wellness',
    'Household',
    'Personal Care',
    'Electronics',
    'Clothing',
    'Home & Garden',
    'Books',
    'Sports',
    'Toys',
    'Stationery',
    'Other',
  ];
  
  // Business Types
  static const List<String> businessTypes = [
    'Kirana Store',
    'General Store',
    'Medical Store',
    'Electronics Store',
    'Clothing Store',
    'Jewelry Store',
    'Cosmetics Store',
    'Stationery Store',
    'Book Store',
    'Restaurant',
    'Cafe',
    'Other',
  ];
  
  // Error Messages
  static const Map<String, String> errorMessages = {
    'network_error': 'No internet connection. Please check your network.',
    'server_error': 'Server error. Please try again later.',
    'timeout_error': 'Request timeout. Please try again.',
    'validation_error': 'Please check your input and try again.',
    'auth_error': 'Authentication failed. Please login again.',
    'permission_error': 'Permission denied. Please grant required permissions.',
    'storage_error': 'Storage error. Please free up some space.',
    'unknown_error': 'An unexpected error occurred. Please try again.',
  };
  
  // Success Messages
  static const Map<String, String> successMessages = {
    'product_added': 'Product added successfully',
    'product_updated': 'Product updated successfully',
    'product_deleted': 'Product deleted successfully',
    'customer_added': 'Customer added successfully',
    'customer_updated': 'Customer updated successfully',
    'payment_recorded': 'Payment recorded successfully',
    'bill_generated': 'Bill generated successfully',
    'data_synced': 'Data synced successfully',
    'settings_saved': 'Settings saved successfully',
  };
  
  // URLs
  static const String privacyPolicyUrl = 'https://invenshop.com/privacy';
  static const String termsOfServiceUrl = 'https://invenshop.com/terms';
  static const String supportUrl = 'https://invenshop.com/support';
  static const String feedbackUrl = 'https://invenshop.com/feedback';
  
  // Social Media
  static const String facebookUrl = 'https://facebook.com/invenshop';
  static const String twitterUrl = 'https://twitter.com/invenshop';
  static const String instagramUrl = 'https://instagram.com/invenshop';
  static const String linkedinUrl = 'https://linkedin.com/company/invenshop';
  
  // Contact Information
  static const String supportEmail = 'support@invenshop.com';
  static const String supportPhone = '+91 9876543210';
  static const String whatsappNumber = '+91 9876543210';
  
  // Development Configuration
  static const bool isDebugMode = false;
  static const bool enableLogging = true;
  static const bool enablePerformanceMonitoring = true;
  
  // Production Configuration
  static const bool isProduction = true;
  static const bool enableCrashlytics = true;
  static const bool enableFirebaseAnalytics = true;
  
  // App Store Information
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.invenshop.app';
  static const String appStoreUrl = 'https://apps.apple.com/app/invenshop/id1234567890';
  
  // Minimum Requirements
  static const int minAndroidVersion = 21; // Android 5.0
  static const double minIOSVersion = 12.0;
  static const int minRAM = 2; // GB
  static const int minStorage = 100; // MB
  
  // Rate Limiting
  static const int maxApiCallsPerMinute = 60;
  static const int maxLoginAttempts = 5;
  static const Duration loginLockoutDuration = Duration(minutes: 15);
  
  // Data Retention
  static const Duration dataRetentionPeriod = Duration(days: 365);
  static const Duration logRetentionPeriod = Duration(days: 30);
  static const Duration cacheRetentionPeriod = Duration(days: 7);
  
  // Backup Configuration
  static const bool enableAutoBackup = true;
  static const Duration backupInterval = Duration(hours: 24);
  static const int maxBackupFiles = 7;
  
  // Security Configuration
  static const int maxPasswordAttempts = 5;
  static const Duration passwordLockoutDuration = Duration(minutes: 30);
  static const bool enableBiometricAuth = true;
  static const bool enableDataEncryption = true;
  
  // Performance Configuration
  static const int maxConcurrentRequests = 5;
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxImageSize = 5; // MB
  static const int maxFileSize = 10; // MB
  
  // Analytics Configuration
  static const bool enableUserTracking = true;
  static const bool enableCrashTracking = true;
  static const bool enablePerformanceTracking = true;
  static const bool enableCustomEvents = true;
  
  // Notification Configuration
  static const bool enablePushNotifications = true;
  static const bool enableEmailNotifications = true;
  static const bool enableSMSNotifications = true;
  static const bool enableWhatsAppNotifications = true;
  
  // Localization Configuration
  static const bool enableRTLSupport = false;
  static const bool enableNumberFormatting = true;
  static const bool enableDateFormatting = true;
  static const bool enableCurrencyFormatting = true;
  
  // Accessibility Configuration
  static const bool enableScreenReader = true;
  static const bool enableHighContrast = true;
  static const bool enableLargeText = true;
  static const bool enableVoiceOver = true;
  
  // Testing Configuration
  static const bool enableTestMode = false;
  static const bool enableMockData = false;
  static const bool enableDebugLogs = false;
  static const bool enablePerformanceLogs = false;
}