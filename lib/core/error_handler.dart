import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'app_config.dart';
import 'app_export.dart';

class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Handle different types of errors and show appropriate messages
  static void handleError(dynamic error, {BuildContext? context}) {
    String message = _getErrorMessage(error);
    String title = _getErrorTitle(error);
    
    if (context != null) {
      _showErrorDialog(context, title, message);
    } else {
      _logError(error);
    }
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Show warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.warningLight,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryLight,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Show error dialog
  static void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: AppTheme.errorLight,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Get error message based on error type
  static String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is PlatformException) {
      return _handlePlatformError(error);
    } else if (error is FormatException) {
      return AppConfig.errorMessages['validation_error'] ?? 'Invalid data format';
    } else if (error is ArgumentError) {
      return AppConfig.errorMessages['validation_error'] ?? 'Invalid argument';
    } else if (error is StateError) {
      return AppConfig.errorMessages['validation_error'] ?? 'Invalid state';
    } else if (error is RangeError) {
      return AppConfig.errorMessages['validation_error'] ?? 'Value out of range';
    } else if (error is TypeError) {
      return AppConfig.errorMessages['validation_error'] ?? 'Type error';
    } else if (error is NoSuchMethodError) {
      return AppConfig.errorMessages['unknown_error'] ?? 'Method not found';
    } else if (error is UnimplementedError) {
      return 'This feature is not implemented yet';
    } else if (error is UnsupportedError) {
      return 'This operation is not supported';
    } else if (error is ConcurrentModificationError) {
      return 'Data was modified during operation';
    } else if (error is OutOfMemoryError) {
      return 'Insufficient memory. Please free up some space.';
    } else if (error is StackOverflowError) {
      return 'Operation caused stack overflow';
    } else if (error is TimeoutException) {
      return AppConfig.errorMessages['timeout_error'] ?? 'Request timeout';
    } else if (error is SocketException) {
      return AppConfig.errorMessages['network_error'] ?? 'Network connection error';
    } else if (error is HttpException) {
      return 'HTTP error occurred';
    } else if (error is FormatException) {
      return 'Data format error';
    } else if (error is Exception) {
      return error.toString();
    } else {
      return AppConfig.errorMessages['unknown_error'] ?? 'An unexpected error occurred';
    }
  }

  /// Get error title based on error type
  static String _getErrorTitle(dynamic error) {
    if (error is DioException) {
      return 'Network Error';
    } else if (error is PlatformException) {
      return 'Platform Error';
    } else if (error is TimeoutException) {
      return 'Timeout Error';
    } else if (error is SocketException) {
      return 'Connection Error';
    } else if (error is HttpException) {
      return 'HTTP Error';
    } else if (error is FormatException) {
      return 'Format Error';
    } else if (error is ArgumentError) {
      return 'Argument Error';
    } else if (error is StateError) {
      return 'State Error';
    } else if (error is RangeError) {
      return 'Range Error';
    } else if (error is TypeError) {
      return 'Type Error';
    } else if (error is NoSuchMethodError) {
      return 'Method Error';
    } else if (error is UnimplementedError) {
      return 'Not Implemented';
    } else if (error is UnsupportedError) {
      return 'Not Supported';
    } else if (error is ConcurrentModificationError) {
      return 'Concurrent Modification';
    } else if (error is OutOfMemoryError) {
      return 'Memory Error';
    } else if (error is StackOverflowError) {
      return 'Stack Overflow';
    } else {
      return 'Error';
    }
  }

  /// Handle Dio network errors
  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return AppConfig.errorMessages['timeout_error'] ?? 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return AppConfig.errorMessages['timeout_error'] ?? 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return AppConfig.errorMessages['timeout_error'] ?? 'Receive timeout';
      case DioExceptionType.badResponse:
        return _handleHttpError(error.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return AppConfig.errorMessages['network_error'] ?? 'Connection error';
      case DioExceptionType.badCertificate:
        return 'Certificate error';
      case DioExceptionType.unknown:
        return AppConfig.errorMessages['unknown_error'] ?? 'Unknown network error';
    }
  }

  /// Handle HTTP status codes
  static String _handleHttpError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return AppConfig.errorMessages['auth_error'] ?? 'Authentication failed';
      case 403:
        return 'Access denied. You don\'t have permission.';
      case 404:
        return 'Resource not found';
      case 408:
        return AppConfig.errorMessages['timeout_error'] ?? 'Request timeout';
      case 409:
        return 'Conflict. Resource already exists.';
      case 422:
        return AppConfig.errorMessages['validation_error'] ?? 'Validation failed';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return AppConfig.errorMessages['server_error'] ?? 'Internal server error';
      case 502:
        return 'Bad gateway';
      case 503:
        return 'Service unavailable';
      case 504:
        return 'Gateway timeout';
      default:
        return AppConfig.errorMessages['server_error'] ?? 'Server error';
    }
  }

  /// Handle platform-specific errors
  static String _handlePlatformError(PlatformException error) {
    switch (error.code) {
      case 'PERMISSION_DENIED':
        return AppConfig.errorMessages['permission_error'] ?? 'Permission denied';
      case 'PERMISSION_PERMANENTLY_DENIED':
        return 'Permission permanently denied. Please enable in settings.';
      case 'SERVICE_DISABLED':
        return 'Service is disabled';
      case 'SERVICE_MISSING':
        return 'Service is not available';
      case 'SERVICE_VERSION_UPDATE_REQUIRED':
        return 'Service version update required';
      case 'SERVICE_INVALID':
        return 'Invalid service';
      case 'STORAGE_ERROR':
        return AppConfig.errorMessages['storage_error'] ?? 'Storage error';
      case 'NETWORK_ERROR':
        return AppConfig.errorMessages['network_error'] ?? 'Network error';
      case 'CANCELLED':
        return 'Operation was cancelled';
      case 'INVALID_ACTIVITY':
        return 'Invalid activity';
      case 'INVALID_ARGUMENT':
        return AppConfig.errorMessages['validation_error'] ?? 'Invalid argument';
      case 'INVALID_OPERATION':
        return 'Invalid operation';
      case 'INVALID_STATE':
        return 'Invalid state';
      case 'INVALID_TYPE':
        return 'Invalid type';
      case 'INVALID_VALUE':
        return 'Invalid value';
      case 'INVALID_FORMAT':
        return 'Invalid format';
      case 'INVALID_DATA':
        return 'Invalid data';
      case 'INVALID_RESPONSE':
        return 'Invalid response';
      case 'INVALID_REQUEST':
        return 'Invalid request';
      case 'INVALID_CONFIGURATION':
        return 'Invalid configuration';
      case 'INVALID_CREDENTIALS':
        return 'Invalid credentials';
      case 'INVALID_TOKEN':
        return 'Invalid token';
      case 'INVALID_SESSION':
        return 'Invalid session';
      case 'INVALID_USER':
        return 'Invalid user';
      case 'INVALID_ACCOUNT':
        return 'Invalid account';
      case 'INVALID_PASSWORD':
        return 'Invalid password';
      case 'INVALID_EMAIL':
        return 'Invalid email';
      case 'INVALID_PHONE':
        return 'Invalid phone number';
      case 'INVALID_ADDRESS':
        return 'Invalid address';
      case 'INVALID_CARD':
        return 'Invalid card';
      case 'INVALID_PAYMENT':
        return 'Invalid payment';
      case 'INVALID_ORDER':
        return 'Invalid order';
      case 'INVALID_PRODUCT':
        return 'Invalid product';
      case 'INVALID_CUSTOMER':
        return 'Invalid customer';
      case 'INVALID_INVENTORY':
        return 'Invalid inventory';
      case 'INVALID_BILL':
        return 'Invalid bill';
      case 'INVALID_REPORT':
        return 'Invalid report';
      case 'INVALID_ANALYTICS':
        return 'Invalid analytics';
      case 'INVALID_SETTINGS':
        return 'Invalid settings';
      case 'INVALID_PROFILE':
        return 'Invalid profile';
      case 'INVALID_BUSINESS':
        return 'Invalid business';
      case 'INVALID_STORE':
        return 'Invalid store';
      case 'INVALID_MARKETPLACE':
        return 'Invalid marketplace';
      case 'INVALID_ONLINE_STORE':
        return 'Invalid online store';
      case 'INVALID_ORDER_MANAGEMENT':
        return 'Invalid order management';
      case 'INVALID_CUSTOMER_MANAGEMENT':
        return 'Invalid customer management';
      case 'INVALID_INVENTORY_MANAGEMENT':
        return 'Invalid inventory management';
      case 'INVALID_BILLING':
        return 'Invalid billing';
      case 'INVALID_ANALYTICS_DASHBOARD':
        return 'Invalid analytics dashboard';
      case 'INVALID_REPORTS':
        return 'Invalid reports';
      case 'INVALID_SETTINGS_SCREEN':
        return 'Invalid settings screen';
      case 'INVALID_PROFILE_SCREEN':
        return 'Invalid profile screen';
      case 'INVALID_BUSINESS_REGISTRATION':
        return 'Invalid business registration';
      case 'INVALID_AUTH_SCREEN':
        return 'Invalid authentication screen';
      case 'INVALID_DASHBOARD':
        return 'Invalid dashboard';
      case 'INVALID_ADD_EDIT_PRODUCT':
        return 'Invalid add/edit product screen';
      case 'INVALID_MARKETPLACE_BROWSE':
        return 'Invalid marketplace browse screen';
      case 'INVALID_BILLING_SCREEN':
        return 'Invalid billing screen';
      case 'INVALID_CUSTOMER_MANAGEMENT_SCREEN':
        return 'Invalid customer management screen';
      case 'INVALID_ANALYTICS_DASHBOARD_SCREEN':
        return 'Invalid analytics dashboard screen';
      case 'INVALID_PROFILE_SETTINGS_SCREEN':
        return 'Invalid profile settings screen';
      case 'INVALID_BUSINESS_REGISTRATION_SCREEN':
        return 'Invalid business registration screen';
      case 'INVALID_AUTH_SCREEN_ERROR':
        return 'Invalid authentication screen error';
      case 'INVALID_DASHBOARD_ERROR':
        return 'Invalid dashboard error';
      case 'INVALID_ADD_EDIT_PRODUCT_ERROR':
        return 'Invalid add/edit product screen error';
      case 'INVALID_MARKETPLACE_BROWSE_ERROR':
        return 'Invalid marketplace browse screen error';
      case 'INVALID_BILLING_SCREEN_ERROR':
        return 'Invalid billing screen error';
      case 'INVALID_CUSTOMER_MANAGEMENT_SCREEN_ERROR':
        return 'Invalid customer management screen error';
      case 'INVALID_ANALYTICS_DASHBOARD_SCREEN_ERROR':
        return 'Invalid analytics dashboard screen error';
      case 'INVALID_PROFILE_SETTINGS_SCREEN_ERROR':
        return 'Invalid profile settings screen error';
      case 'INVALID_BUSINESS_REGISTRATION_SCREEN_ERROR':
        return 'Invalid business registration screen error';
      default:
        return error.message ?? AppConfig.errorMessages['unknown_error'] ?? 'Unknown error';
    }
  }

  /// Log error for debugging
  static void _logError(dynamic error) {
    if (AppConfig.enableLogging) {
      print('Error: $error');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  /// Check network connectivity
  static Future<bool> isNetworkAvailable() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  /// Handle network errors with retry mechanism
  static Future<T> handleNetworkError<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        
        if (e is DioException && e.type == DioExceptionType.connectionError) {
          if (attempts < maxRetries) {
            await Future.delayed(delay * attempts);
            continue;
          }
        }
        
        rethrow;
      }
    }
    
    throw Exception('Max retries exceeded');
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            if (message != null) ...[
              SizedBox(height: 2.h),
              Text(message),
            ],
          ],
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  /// Show info dialog
  static void showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show bottom sheet with error details
  static void showErrorBottomSheet(BuildContext context, String title, String message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            CustomIconWidget(
              iconName: 'error',
              color: AppTheme.errorLight,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}