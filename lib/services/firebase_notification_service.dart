import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'supabase_service.dart';

class FirebaseNotificationService {
  static FirebaseMessaging? _messaging;
  static FlutterLocalNotificationsPlugin? _localNotifications;
  static String? _fcmToken;
  
  // Initialize Firebase and FCM
  static Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      
      // Initialize FCM
      _messaging = FirebaseMessaging.instance;
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Request permission
      await _requestPermission();
      
      // Get FCM token
      await _getFCMToken();
      
      // Set up message handlers
      _setupMessageHandlers();
      
      print('Firebase FCM initialized successfully');
    } catch (e) {
      print('Error initializing Firebase FCM: $e');
    }
  }
  
  // Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications!.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }
  
  // Create notification channel for Android
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'invenshop_notifications',
      'InvenShop Notifications',
      description: 'Notifications for InvenShop app',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    
    await _localNotifications!
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  // Request notification permission
  static Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      print('Notification permission status: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('User denied notification permission');
      }
    } catch (e) {
      print('Error requesting notification permission: $e');
    }
  }
  
  // Get FCM token
  static Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _messaging!.getToken();
      print('FCM Token: $_fcmToken');
      
      // Save token to local storage
      if (_fcmToken != null) {
        await _saveFCMToken(_fcmToken!);
        await _sendTokenToServer(_fcmToken!);
      }
      
      return _fcmToken;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }
  
  // Save FCM token to local storage
  static Future<void> _saveFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }
  
  // Send FCM token to server
  static Future<void> _sendTokenToServer(String token) async {
    try {
      final client = SupabaseService.client;
      final user = client.auth.currentUser;
      
      if (user != null) {
        await client.from('user_tokens').upsert({
          'user_id': user.id,
          'fcm_token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error sending FCM token to server: $e');
    }
  }
  
  // Set up message handlers
  static void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    // Handle notification tap when app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessage(message);
      }
    });
  }
  
  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');
    
    // Show local notification
    await _showLocalNotification(message);
    
    // Handle custom data
    if (message.data.isNotEmpty) {
      _handleCustomData(message.data);
    }
  }
  
  // Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Received background message: ${message.messageId}');
    
    // Navigate to appropriate screen based on data
    _handleCustomData(message.data);
  }
  
  // Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'invenshop_notifications',
        'InvenShop Notifications',
        channelDescription: 'Notifications for InvenShop app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );
      
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications!.show(
        message.hashCode,
        message.notification?.title ?? 'InvenShop',
        message.notification?.body ?? 'You have a new notification',
        notificationDetails,
        payload: message.data.toString(),
      );
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }
  
  // Handle custom data from notifications
  static void _handleCustomData(Map<String, dynamic> data) {
    try {
      final String type = data['type'] ?? '';
      final String? id = data['id'];
      
      switch (type) {
        case 'low_stock':
          _handleLowStockNotification(id);
          break;
        case 'new_order':
          _handleNewOrderNotification(id);
          break;
        case 'payment_received':
          _handlePaymentReceivedNotification(id);
          break;
        case 'customer_credit':
          _handleCustomerCreditNotification(id);
          break;
        case 'promotion':
          _handlePromotionNotification(data);
          break;
        default:
          print('Unknown notification type: $type');
      }
    } catch (e) {
      print('Error handling custom data: $e');
    }
  }
  
  // Handle low stock notification
  static void _handleLowStockNotification(String? productId) {
    // Navigate to product management screen
    print('Low stock notification for product: $productId');
  }
  
  // Handle new order notification
  static void _handleNewOrderNotification(String? orderId) {
    // Navigate to orders screen
    print('New order notification: $orderId');
  }
  
  // Handle payment received notification
  static void _handlePaymentReceivedNotification(String? paymentId) {
    // Navigate to payments screen
    print('Payment received notification: $paymentId');
  }
  
  // Handle customer credit notification
  static void _handleCustomerCreditNotification(String? customerId) {
    // Navigate to customer management screen
    print('Customer credit notification: $customerId');
  }
  
  // Handle promotion notification
  static void _handlePromotionNotification(Map<String, dynamic> data) {
    // Show promotion details
    print('Promotion notification: ${data['title']}');
  }
  
  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    try {
      final String? payload = response.payload;
      if (payload != null) {
        // Parse payload and navigate accordingly
        print('Notification tapped with payload: $payload');
      }
    } catch (e) {
      print('Error handling notification tap: $e');
    }
  }
  
  // Get current FCM token
  static String? getFCMToken() {
    return _fcmToken;
  }
  
  // Refresh FCM token
  static Future<String?> refreshFCMToken() async {
    try {
      await _messaging!.deleteToken();
      return await _getFCMToken();
    } catch (e) {
      print('Error refreshing FCM token: $e');
      return null;
    }
  }
  
  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging!.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }
  
  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging!.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
    }
  }
  
  // Send local notification
  static Future<void> sendLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'invenshop_notifications',
        'InvenShop Notifications',
        channelDescription: 'Notifications for InvenShop app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );
      
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications!.show(
        id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      print('Error sending local notification: $e');
    }
  }
  
  // Schedule notification
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    int? id,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'invenshop_notifications',
        'InvenShop Notifications',
        channelDescription: 'Notifications for InvenShop app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );
      
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications!.zonedSchedule(
        id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        scheduledDate,
        notificationDetails,
        payload: payload,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
  
  // Cancel notification
  static Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications!.cancel(id);
    } catch (e) {
      print('Error canceling notification: $e');
    }
  }
  
  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications!.cancelAll();
    } catch (e) {
      print('Error canceling all notifications: $e');
    }
  }
  
  // Get notification settings
  static Future<NotificationSettings> getNotificationSettings() async {
    try {
      return await _messaging!.getNotificationSettings();
    } catch (e) {
      print('Error getting notification settings: $e');
      return const NotificationSettings(
        authorizationStatus: AuthorizationStatus.notDetermined,
        alert: AppleNotificationSetting.notSupported,
        announcement: AppleNotificationSetting.notSupported,
        badge: AppleNotificationSetting.notSupported,
        carPlay: AppleNotificationSetting.notSupported,
        criticalAlert: AppleNotificationSetting.notSupported,
        lockScreen: AppleNotificationSetting.notSupported,
        notificationCenter: AppleNotificationSetting.notSupported,
        showPreviews: AppleShowPreviewSetting.notSupported,
        sound: AppleNotificationSetting.notSupported,
      );
    }
  }
  
  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('Error checking notification status: $e');
      return false;
    }
  }
  
  // Request notification permission with custom message
  static Future<bool> requestNotificationPermission({
    String? title,
    String? message,
  }) async {
    try {
      final settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}