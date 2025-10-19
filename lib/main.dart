import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/app_export.dart';
import 'core/app_config.dart';
import 'core/error_handler.dart';
import 'core/offline_manager.dart';
import 'widgets/custom_error_widget.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize Supabase
  await SupabaseService.initialize();

  // Initialize error handling
  _initializeErrorHandling();

  // Initialize offline manager
  await OfflineManager().initialize();

  // Set device orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize app
  runApp(MyApp());
}

void _initializeErrorHandling() {
  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    
    // Log error for debugging
    if (AppConfig.enableLogging) {
      print('Flutter Error: ${details.exception}');
      print('Stack trace: ${details.stack}');
    }
  };

  // Set up error widget builder
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(
      errorDetails: details,
    );
  };

  // Set up platform error handling
  PlatformDispatcher.instance.onError = (error, stack) {
    if (AppConfig.enableLogging) {
      print('Platform Error: $error');
      print('Stack trace: $stack');
    }
    return true;
  };
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        // 🚨 END CRITICAL SECTION
        debugShowCheckedModeBanner: AppConfig.isDebugMode,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.initial,
        // Global error handling
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => _buildErrorPage(settings.name ?? ''),
          );
        },
      );
    });
  }

  Widget _buildErrorPage(String routeName) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error',
              size: 80,
              color: AppTheme.errorLight,
            ),
            SizedBox(height: 2.h),
            Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'The page "$routeName" could not be found.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () {
                // Navigate to home
              },
              child: Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
