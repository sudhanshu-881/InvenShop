import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class NotificationPreferencesSection extends StatefulWidget {
  final Map<String, dynamic> notificationSettings;
  final Function(Map<String, dynamic>) onNotificationSettingsChanged;

  const NotificationPreferencesSection({
    Key? key,
    required this.notificationSettings,
    required this.onNotificationSettingsChanged,
  }) : super(key: key);

  @override
  State<NotificationPreferencesSection> createState() =>
      _NotificationPreferencesSectionState();
}

class _NotificationPreferencesSectionState
    extends State<NotificationPreferencesSection> {
  void _updateNotificationSetting(String key, bool value) {
    final updatedSettings = {
      ...widget.notificationSettings,
      key: value,
    };
    widget.onNotificationSettingsChanged(updatedSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'notifications',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Notification Preferences',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildNotificationToggle(
            icon: 'inventory',
            title: 'Inventory Alerts',
            subtitle: 'Low stock and out of stock notifications',
            key: 'inventoryAlerts',
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          _buildNotificationToggle(
            icon: 'shopping_cart',
            title: 'Order Notifications',
            subtitle: 'New orders and order status updates',
            key: 'orderNotifications',
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          _buildNotificationToggle(
            icon: 'store',
            title: 'Marketplace Updates',
            subtitle: 'Product views, inquiries, and marketplace news',
            key: 'marketplaceUpdates',
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          _buildNotificationToggle(
            icon: 'campaign',
            title: 'Promotional Messages',
            subtitle: 'Special offers and feature announcements',
            key: 'promotionalMessages',
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          _buildNotificationToggle(
            icon: 'analytics',
            title: 'Sales Reports',
            subtitle: 'Daily and weekly sales summaries',
            key: 'salesReports',
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          _buildNotificationToggle(
            icon: 'payment',
            title: 'Payment Notifications',
            subtitle: 'Payment confirmations and payout updates',
            key: 'paymentNotifications',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String icon,
    required String title,
    required String subtitle,
    required String key,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: CustomIconWidget(
        iconName: icon,
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      value: widget.notificationSettings[key] ?? true,
      onChanged: (value) => _updateNotificationSetting(key, value),
    );
  }
}
