import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/firebase_notification_service.dart';
import '../../services/notification_manager.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = false;
  bool _lowStockAlerts = true;
  bool _newOrderAlerts = true;
  bool _paymentAlerts = true;
  bool _creditAlerts = true;
  bool _promotionAlerts = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      // Check if notifications are enabled
      final enabled = await FirebaseNotificationService.areNotificationsEnabled();
      
      setState(() {
        _notificationsEnabled = enabled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error loading notification settings', isError: true);
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // Request permission
      final granted = await FirebaseNotificationService.requestNotificationPermission(
        title: 'Enable Notifications',
        message: 'Get important updates about your shop, orders, and inventory',
      );
      
      if (granted) {
        setState(() {
          _notificationsEnabled = true;
        });
        _showSnackBar('Notifications enabled successfully');
      } else {
        _showSnackBar('Notification permission denied', isError: true);
      }
    } else {
      setState(() {
        _notificationsEnabled = false;
      });
      _showSnackBar('Notifications disabled');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorLight : AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: AppTheme.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main notification toggle
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications,
                          color: AppTheme.primaryLight,
                          size: 6.w,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Push Notifications',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                'Receive important updates about your shop',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _notificationsEnabled,
                          onChanged: _toggleNotifications,
                          activeColor: AppTheme.primaryLight,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Notification categories
                  if (_notificationsEnabled) ...[
                    Text(
                      'Notification Types',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Low stock alerts
                    _buildNotificationOption(
                      icon: Icons.inventory,
                      title: 'Low Stock Alerts',
                      subtitle: 'Get notified when products are running low',
                      value: _lowStockAlerts,
                      onChanged: (value) => setState(() => _lowStockAlerts = value),
                    ),

                    SizedBox(height: 2.h),

                    // New order alerts
                    _buildNotificationOption(
                      icon: Icons.shopping_cart,
                      title: 'New Order Alerts',
                      subtitle: 'Get notified when new orders are received',
                      value: _newOrderAlerts,
                      onChanged: (value) => setState(() => _newOrderAlerts = value),
                    ),

                    SizedBox(height: 2.h),

                    // Payment alerts
                    _buildNotificationOption(
                      icon: Icons.payment,
                      title: 'Payment Alerts',
                      subtitle: 'Get notified when payments are received',
                      value: _paymentAlerts,
                      onChanged: (value) => setState(() => _paymentAlerts = value),
                    ),

                    SizedBox(height: 2.h),

                    // Credit alerts
                    _buildNotificationOption(
                      icon: Icons.credit_card,
                      title: 'Credit Sale Alerts',
                      subtitle: 'Get notified when credit sales are made',
                      value: _creditAlerts,
                      onChanged: (value) => setState(() => _creditAlerts = value),
                    ),

                    SizedBox(height: 2.h),

                    // Promotion alerts
                    _buildNotificationOption(
                      icon: Icons.campaign,
                      title: 'Promotion Alerts',
                      subtitle: 'Get notified about promotions and offers',
                      value: _promotionAlerts,
                      onChanged: (value) => setState(() => _promotionAlerts = value),
                    ),

                    SizedBox(height: 4.h),

                    // Test notification button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _sendTestNotification,
                        icon: const Icon(Icons.send),
                        label: const Text('Send Test Notification'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryLight,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Clear notifications button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _clearAllNotifications,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear All Notifications'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorLight,
                          side: BorderSide(color: AppTheme.errorLight),
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Notification disabled message
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 12.w,
                            color: AppTheme.textSecondaryLight,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Notifications Disabled',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Enable notifications to receive important updates about your shop, orders, and inventory.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryLight,
            size: 6.w,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryLight,
          ),
        ],
      ),
    );
  }

  Future<void> _sendTestNotification() async {
    try {
      await FirebaseNotificationService.sendLocalNotification(
        title: 'Test Notification',
        body: 'This is a test notification from InvenShop',
        payload: 'test',
      );
      
      _showSnackBar('Test notification sent');
    } catch (e) {
      _showSnackBar('Failed to send test notification', isError: true);
    }
  }

  Future<void> _clearAllNotifications() async {
    try {
      await NotificationManager.deleteAllNotifications();
      await FirebaseNotificationService.cancelAllNotifications();
      
      _showSnackBar('All notifications cleared');
    } catch (e) {
      _showSnackBar('Failed to clear notifications', isError: true);
    }
  }
}