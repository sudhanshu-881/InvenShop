# InvenShop Firebase Setup Guide

## 🔥 **Complete Firebase FCM Integration for Push Notifications**

This guide will help you set up Firebase Cloud Messaging (FCM) for push notifications in InvenShop.

## 📋 **Prerequisites**

- Firebase account (free tier available)
- Flutter development environment
- Node.js installed
- Basic knowledge of Firebase services

## 🔧 **Step 1: Create Firebase Project**

### **1.1 Sign Up for Firebase**
1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click "Get started" or "Create a project"
3. Sign in with your Google account
4. Click "Create a project"

### **1.2 Configure Project**
1. **Project name**: `invenshop` (or your preferred name)
2. **Google Analytics**: Enable (recommended)
3. **Analytics account**: Create new or use existing
4. Click "Create project"
5. Wait for project to be ready (1-2 minutes)

### **1.3 Add Apps to Project**
1. Click "Add app" and select the platform:
   - **Android**: Add your Android app
   - **iOS**: Add your iOS app
   - **Web**: Add your web app (optional)

## 📱 **Step 2: Configure Flutter App**

### **2.1 Install Firebase CLI**
```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Login to Firebase
firebase login
```

### **2.2 Install FlutterFire CLI**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Verify installation
flutterfire --version
```

### **2.3 Configure FlutterFire**
```bash
# Navigate to your Flutter project
cd /workspace

# Configure Firebase for your project
flutterfire configure
```

This will:
- Create `firebase_options.dart` file
- Update `android/app/google-services.json`
- Update `ios/Runner/GoogleService-Info.plist`
- Update `web/index.html` (if web support enabled)

## 🔑 **Step 3: Enable Firebase Services**

### **3.1 Enable Cloud Messaging**
1. In Firebase Console, go to "Messaging"
2. Click "Get started"
3. Review the setup steps

### **3.2 Enable Firestore (Optional)**
1. Go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users

### **3.3 Enable Storage (Optional)**
1. Go to "Storage"
2. Click "Get started"
3. Review security rules
4. Choose a location

## 📦 **Step 4: Dependencies Already Added**

The following dependencies are already in `pubspec.yaml`:
```yaml
dependencies:
  # Firebase Integration
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  flutter_local_notifications: ^16.3.2
```

## 🚀 **Step 5: Firebase Services Available**

### **5.1 Firebase Notification Service**
Created `lib/services/firebase_notification_service.dart` with:
- **FCM Initialization** - Automatic setup and configuration
- **Permission Handling** - Request and manage notification permissions
- **Token Management** - Get, refresh, and manage FCM tokens
- **Message Handling** - Foreground and background message processing
- **Local Notifications** - Show notifications when app is in foreground
- **Topic Subscriptions** - Subscribe/unsubscribe from topics

### **5.2 Notification Manager**
Created `lib/services/notification_manager.dart` with:
- **User Notifications** - Send notifications to specific users
- **Shop Notifications** - Send notifications to all shop staff
- **Business Notifications** - Low stock, new orders, payments, etc.
- **Notification History** - Store and retrieve notification history
- **Scheduled Notifications** - Schedule notifications for later delivery

### **5.3 Notification Settings Screen**
Created `lib/presentation/notification_settings_screen/notification_settings_screen.dart` with:
- **Permission Management** - Enable/disable notifications
- **Category Settings** - Configure different notification types
- **Test Notifications** - Send test notifications
- **Notification History** - View and manage notifications

## 🔧 **Step 6: Firebase Configuration**

### **6.1 Update main.dart**
Firebase is already initialized in `main.dart`:
```dart
import 'services/firebase_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase FCM
  await FirebaseNotificationService.initialize();
  
  // ... rest of your app initialization
}
```

### **6.2 Background Message Handler**
Add to `main.dart`:
```dart
import 'package:firebase_messaging/firebase_messaging.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  // ... existing code ...
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  runApp(MyApp());
}
```

## 📊 **Step 7: Database Schema Updates**

### **7.1 Notification Tables**
Updated `supabase_schema.sql` with:
- **`notifications`** - Store notification history
- **`user_tokens`** - Store FCM tokens for users
- **`scheduled_notifications`** - Store scheduled notifications

### **7.2 Row Level Security**
- Users can only access their own notifications
- Shop staff can access shop notifications
- Secure multi-tenant architecture

## 🎯 **Step 8: Notification Types**

### **8.1 Business Notifications**
- **Low Stock Alerts** - When products are running low
- **New Order Alerts** - When new orders are received
- **Payment Alerts** - When payments are received
- **Credit Alerts** - When credit sales are made
- **Promotion Alerts** - Marketing and promotional messages

### **8.2 System Notifications**
- **App Updates** - New features and improvements
- **Maintenance** - Scheduled maintenance notifications
- **Security** - Security alerts and updates

## 🔧 **Step 9: Testing Notifications**

### **9.1 Test Local Notifications**
```dart
// Send test notification
await FirebaseNotificationService.sendLocalNotification(
  title: 'Test Notification',
  body: 'This is a test notification',
);
```

### **9.2 Test Push Notifications**
1. Use Firebase Console → Messaging
2. Click "Send your first message"
3. Enter title and message
4. Select target (all users or specific users)
5. Click "Send"

### **9.3 Test in App**
1. Open notification settings screen
2. Enable notifications
3. Send test notification
4. Verify notification appears

## 🚀 **Step 10: Production Deployment**

### **10.1 Firebase Console Setup**
1. **Project Settings** → **General**
   - Add your app's SHA-1 fingerprint (Android)
   - Configure OAuth redirect URLs (Web)

2. **Authentication** → **Sign-in method**
   - Enable Phone authentication
   - Configure OAuth providers

3. **Messaging** → **Settings**
   - Configure FCM server key
   - Set up notification channels

### **10.2 Security Rules**
```javascript
// Firestore Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

### **10.3 Environment Configuration**
Update `.env` file:
```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your-project.iam.gserviceaccount.com
```

## 📱 **Step 11: Platform-Specific Setup**

### **11.1 Android Setup**
1. **google-services.json** - Already configured by FlutterFire
2. **Notification Channels** - Created automatically
3. **Permissions** - Handled by the service

### **11.2 iOS Setup**
1. **GoogleService-Info.plist** - Already configured by FlutterFire
2. **Push Notifications** - Enable in Xcode
3. **Background Modes** - Configure for background processing

### **11.3 Web Setup**
1. **Firebase SDK** - Added to index.html
2. **Service Worker** - Created for background messages
3. **CORS** - Configure for your domain

## 🔍 **Step 12: Troubleshooting**

### **Common Issues**

#### **1. Notifications Not Received**
- Check FCM token generation
- Verify notification permissions
- Check device network connectivity
- Review Firebase Console logs

#### **2. Permission Denied**
- Request permission explicitly
- Check device notification settings
- Verify app is not in battery optimization

#### **3. Background Messages Not Working**
- Ensure background handler is registered
- Check app state when message is sent
- Verify message payload format

### **Debug Mode**
```dart
// Enable debug logging
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Received message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
});
```

## 📊 **Step 13: Analytics and Monitoring**

### **13.1 Firebase Analytics**
- Track notification open rates
- Monitor user engagement
- Analyze notification effectiveness

### **13.2 Performance Monitoring**
- Monitor notification delivery rates
- Track app performance impact
- Monitor battery usage

## 💰 **Step 14: Pricing and Limits**

### **14.1 Firebase Pricing**
- **Cloud Messaging**: Free (unlimited messages)
- **Firestore**: Free tier available
- **Storage**: Free tier available
- **Functions**: Free tier available

### **14.2 FCM Limits**
- **Message size**: 4KB payload
- **Topics**: Unlimited subscriptions
- **Sending rate**: 600 messages/minute per project

## 🎯 **Step 15: Advanced Features**

### **15.1 Topic Subscriptions**
```dart
// Subscribe to topic
await FirebaseNotificationService.subscribeToTopic('low_stock');

// Unsubscribe from topic
await FirebaseNotificationService.unsubscribeFromTopic('low_stock');
```

### **15.2 Scheduled Notifications**
```dart
// Schedule notification
await NotificationManager.scheduleNotification(
  userId: userId,
  title: 'Reminder',
  body: 'Check your inventory',
  scheduledDate: DateTime.now().add(Duration(hours: 1)),
);
```

### **15.3 Rich Notifications**
```dart
// Send rich notification with image
await NotificationManager.sendNotificationToUser(
  userId: userId,
  title: 'New Product Added',
  body: 'Check out our latest product',
  data: {
    'image_url': 'https://example.com/image.jpg',
    'action': 'view_product',
    'product_id': '123',
  },
);
```

## 📚 **Additional Resources**

### **Documentation**
- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)
- [FCM Flutter Guide](https://firebase.google.com/docs/cloud-messaging/flutter/client)
- [Local Notifications](https://pub.dev/packages/flutter_local_notifications)

### **Community**
- [Firebase Community](https://firebase.google.com/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/firebase)
- [GitHub](https://github.com/firebase)

## 🎯 **Next Steps**

1. **Complete Setup**: Follow all steps above
2. **Test Integration**: Send test notifications
3. **Configure Business Logic**: Set up notification triggers
4. **Deploy**: Deploy to production
5. **Monitor**: Track notification performance

---

**Your InvenShop app now has enterprise-grade push notifications with Firebase FCM!** 🚀

**Key Benefits:**
- ✅ **Real-time notifications** for important events
- ✅ **Cross-platform support** (Android, iOS, Web)
- ✅ **Rich notifications** with images and actions
- ✅ **Topic subscriptions** for targeted messaging
- ✅ **Scheduled notifications** for reminders
- ✅ **Analytics integration** for performance tracking
- ✅ **Free tier** with generous limits