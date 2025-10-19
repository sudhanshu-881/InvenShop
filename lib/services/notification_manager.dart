import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_notification_service.dart';

class NotificationManager {
  static final SupabaseClient _client = SupabaseService.client;
  
  // Send notification to specific user
  static Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Save notification to database
      final response = await _client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': body,
        'type': type ?? 'general',
        'data': data ?? {},
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Send push notification via FCM
      await _sendPushNotification(
        userId: userId,
        title: title,
        body: body,
        type: type,
        data: data,
      );
      
      return true;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }
  
  // Send notification to shop
  static Future<bool> sendNotificationToShop({
    required String shopId,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get all users in the shop
      final users = await _client
          .from('staff')
          .select('user_id')
          .eq('shop_id', shopId)
          .eq('is_active', true);
      
      // Send to each user
      for (var user in users) {
        await sendNotificationToUser(
          userId: user['user_id'],
          title: title,
          body: body,
          type: type,
          data: data,
        );
      }
      
      return true;
    } catch (e) {
      print('Error sending shop notification: $e');
      return false;
    }
  }
  
  // Send low stock notification
  static Future<bool> sendLowStockNotification({
    required String productId,
    required String productName,
    required int currentStock,
    required int minStock,
  }) async {
    try {
      // Get product details
      final product = await _client
          .from('products')
          .select('shop_id, name')
          .eq('id', productId)
          .single();
      
      final shopId = product['shop_id'];
      final productName = product['name'];
      
      // Send notification
      return await sendNotificationToShop(
        shopId: shopId,
        title: 'Low Stock Alert',
        body: '$productName is running low (${currentStock} left, minimum: $minStock)',
        type: 'low_stock',
        data: {
          'product_id': productId,
          'current_stock': currentStock,
          'min_stock': minStock,
        },
      );
    } catch (e) {
      print('Error sending low stock notification: $e');
      return false;
    }
  }
  
  // Send new order notification
  static Future<bool> sendNewOrderNotification({
    required String transactionId,
    required String customerName,
    required double totalAmount,
  }) async {
    try {
      // Get transaction details
      final transaction = await _client
          .from('transactions')
          .select('shop_id, customer_id, customers(name)')
          .eq('id', transactionId)
          .single();
      
      final shopId = transaction['shop_id'];
      final customerName = transaction['customers']?['name'] ?? 'Walk-in Customer';
      
      // Send notification
      return await sendNotificationToShop(
        shopId: shopId,
        title: 'New Order Received',
        body: 'Order from $customerName for ₹${totalAmount.toStringAsFixed(2)}',
        type: 'new_order',
        data: {
          'transaction_id': transactionId,
          'customer_name': customerName,
          'total_amount': totalAmount,
        },
      );
    } catch (e) {
      print('Error sending new order notification: $e');
      return false;
    }
  }
  
  // Send payment received notification
  static Future<bool> sendPaymentReceivedNotification({
    required String customerId,
    required String customerName,
    required double amount,
  }) async {
    try {
      // Get customer details
      final customer = await _client
          .from('customers')
          .select('shop_id')
          .eq('id', customerId)
          .single();
      
      final shopId = customer['shop_id'];
      
      // Send notification
      return await sendNotificationToShop(
        shopId: shopId,
        title: 'Payment Received',
        body: 'Payment of ₹${amount.toStringAsFixed(2)} received from $customerName',
        type: 'payment_received',
        data: {
          'customer_id': customerId,
          'customer_name': customerName,
          'amount': amount,
        },
      );
    } catch (e) {
      print('Error sending payment notification: $e');
      return false;
    }
  }
  
  // Send customer credit notification
  static Future<bool> sendCustomerCreditNotification({
    required String customerId,
    required String customerName,
    required double creditAmount,
  }) async {
    try {
      // Get customer details
      final customer = await _client
          .from('customers')
          .select('shop_id')
          .eq('id', customerId)
          .single();
      
      final shopId = customer['shop_id'];
      
      // Send notification
      return await sendNotificationToShop(
        shopId: shopId,
        title: 'Credit Sale',
        body: 'Credit sale of ₹${creditAmount.toStringAsFixed(2)} to $customerName',
        type: 'customer_credit',
        data: {
          'customer_id': customerId,
          'customer_name': customerName,
          'credit_amount': creditAmount,
        },
      );
    } catch (e) {
      print('Error sending credit notification: $e');
      return false;
    }
  }
  
  // Send promotion notification
  static Future<bool> sendPromotionNotification({
    required String shopId,
    required String title,
    required String message,
    Map<String, dynamic>? promotionData,
  }) async {
    try {
      return await sendNotificationToShop(
        shopId: shopId,
        title: title,
        body: message,
        type: 'promotion',
        data: promotionData ?? {},
      );
    } catch (e) {
      print('Error sending promotion notification: $e');
      return false;
    }
  }
  
  // Get user notifications
  static Future<List<Map<String, dynamic>>> getUserNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];
      
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting user notifications: $e');
      return [];
    }
  }
  
  // Mark notification as read
  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
      
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
  
  // Mark all notifications as read
  static Future<bool> markAllNotificationsAsRead() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);
      
      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }
  
  // Get unread notification count
  static Future<int> getUnreadNotificationCount() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 0;
      
      final response = await _client
          .from('notifications')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('user_id', user.id)
          .eq('is_read', false);
      
      return response.count ?? 0;
    } catch (e) {
      print('Error getting unread notification count: $e');
      return 0;
    }
  }
  
  // Delete notification
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .delete()
          .eq('id', notificationId);
      
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }
  
  // Delete all notifications
  static Future<bool> deleteAllNotifications() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      
      await _client
          .from('notifications')
          .delete()
          .eq('user_id', user.id);
      
      return true;
    } catch (e) {
      print('Error deleting all notifications: $e');
      return false;
    }
  }
  
  // Send push notification via FCM
  static Future<void> _sendPushNotification({
    required String userId,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token
      final tokenResponse = await _client
          .from('user_tokens')
          .select('fcm_token')
          .eq('user_id', userId)
          .single();
      
      final String? fcmToken = tokenResponse['fcm_token'];
      if (fcmToken == null) {
        print('No FCM token found for user: $userId');
        return;
      }
      
      // Send notification via FCM
      // Note: In production, this should be done via your backend server
      // using Firebase Admin SDK
      print('Sending push notification to user: $userId');
      print('Title: $title');
      print('Body: $body');
      print('Type: $type');
      print('Data: $data');
      
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }
  
  // Schedule notification
  static Future<bool> scheduleNotification({
    required String userId,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Save scheduled notification to database
      await _client.from('scheduled_notifications').insert({
        'user_id': userId,
        'title': title,
        'message': body,
        'type': type ?? 'scheduled',
        'data': data ?? {},
        'scheduled_date': scheduledDate.toIso8601String(),
        'is_sent': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Schedule local notification
      await FirebaseNotificationService.scheduleNotification(
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        payload: data?.toString(),
      );
      
      return true;
    } catch (e) {
      print('Error scheduling notification: $e');
      return false;
    }
  }
  
  // Send bulk notification
  static Future<bool> sendBulkNotification({
    required List<String> userIds,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      bool allSuccess = true;
      
      for (String userId in userIds) {
        final success = await sendNotificationToUser(
          userId: userId,
          title: title,
          body: body,
          type: type,
          data: data,
        );
        
        if (!success) {
          allSuccess = false;
        }
      }
      
      return allSuccess;
    } catch (e) {
      print('Error sending bulk notification: $e');
      return false;
    }
  }
}