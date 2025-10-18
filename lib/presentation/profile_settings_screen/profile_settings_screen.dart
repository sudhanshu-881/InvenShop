import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/account_security_section.dart';
import './widgets/app_settings_section.dart';
import './widgets/business_profile_section.dart';
import './widgets/data_management_section.dart';
import './widgets/help_support_section.dart';
import './widgets/marketplace_settings_section.dart';
import './widgets/notification_preferences_section.dart';
import './widgets/profile_photo_section.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  // Mock user data
  Map<String, dynamic> _businessData = {
    'shopName': 'Mike\'s Electronics Store',
    'address': '123 Main Street, Downtown, NY 10001',
    'phone': '+1 (555) 123-4567',
    'email': 'mike@electronicsstore.com',
    'businessHours': {
      'Monday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '18:00'},
      'Tuesday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '18:00'},
      'Wednesday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '18:00'},
      'Thursday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '18:00'},
      'Friday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '18:00'},
      'Saturday': {'isOpen': true, 'openTime': '10:00', 'closeTime': '16:00'},
      'Sunday': {'isOpen': false, 'openTime': '10:00', 'closeTime': '16:00'},
    },
  };

  String? _profileImageUrl =
      'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=400';

  Map<String, dynamic> _securitySettings = {
    'biometricEnabled': true,
    'twoFactorEnabled': false,
  };

  Map<String, dynamic> _notificationSettings = {
    'inventoryAlerts': true,
    'orderNotifications': true,
    'marketplaceUpdates': true,
    'promotionalMessages': false,
    'salesReports': true,
    'paymentNotifications': true,
  };

  Map<String, dynamic> _appSettings = {
    'theme': 'system',
    'language': 'en',
    'currency': 'USD',
  };

  Map<String, dynamic> _marketplaceSettings = {
    'profileVisibility': 'public',
    'autoListProducts': false,
    'allowCustomerMessages': true,
    'allowCustomerReviews': true,
    'enablePromotions': false,
  };

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'logout',
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('Logout'),
          ],
        ),
        content: const Text(
            'Are you sure you want to logout? Any unsaved changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    // Clear session data and navigate to login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );

    // Navigate to business registration screen (simulating logout flow)
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/business-registration-screen',
      (route) => false,
    );
  }

  void _handleAccountDeletion() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Account deleted successfully'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );

    // Navigate to business registration screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/business-registration-screen',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: CustomIconWidget(
              iconName: 'logout',
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 2.h),

              // Profile Photo Section
              ProfilePhotoSection(
                profileImageUrl: _profileImageUrl,
                onImageChanged: (newImageUrl) {
                  setState(() {
                    _profileImageUrl = newImageUrl;
                  });
                },
              ),

              // Business Profile Section
              BusinessProfileSection(
                businessData: _businessData,
                onBusinessDataChanged: (updatedData) {
                  setState(() {
                    _businessData = updatedData;
                  });
                },
              ),

              // Account Security Section
              AccountSecuritySection(
                securitySettings: _securitySettings,
                onSecuritySettingsChanged: (updatedSettings) {
                  setState(() {
                    _securitySettings = updatedSettings;
                  });
                },
              ),

              // Notification Preferences Section
              NotificationPreferencesSection(
                notificationSettings: _notificationSettings,
                onNotificationSettingsChanged: (updatedSettings) {
                  setState(() {
                    _notificationSettings = updatedSettings;
                  });
                },
              ),

              // App Settings Section
              AppSettingsSection(
                appSettings: _appSettings,
                onAppSettingsChanged: (updatedSettings) {
                  setState(() {
                    _appSettings = updatedSettings;
                  });
                },
              ),

              // Marketplace Settings Section
              MarketplaceSettingsSection(
                marketplaceSettings: _marketplaceSettings,
                onMarketplaceSettingsChanged: (updatedSettings) {
                  setState(() {
                    _marketplaceSettings = updatedSettings;
                  });
                },
              ),

              // Data Management Section
              DataManagementSection(
                onAccountDeleted: _handleAccountDeletion,
              ),

              // Help & Support Section
              const HelpSupportSection(),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
