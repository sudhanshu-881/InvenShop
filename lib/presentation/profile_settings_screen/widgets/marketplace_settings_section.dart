import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MarketplaceSettingsSection extends StatefulWidget {
  final Map<String, dynamic> marketplaceSettings;
  final Function(Map<String, dynamic>) onMarketplaceSettingsChanged;

  const MarketplaceSettingsSection({
    Key? key,
    required this.marketplaceSettings,
    required this.onMarketplaceSettingsChanged,
  }) : super(key: key);

  @override
  State<MarketplaceSettingsSection> createState() =>
      _MarketplaceSettingsSectionState();
}

class _MarketplaceSettingsSectionState
    extends State<MarketplaceSettingsSection> {
  void _updateMarketplaceSetting(String key, bool value) {
    final updatedSettings = {
      ...widget.marketplaceSettings,
      key: value,
    };
    widget.onMarketplaceSettingsChanged(updatedSettings);
  }

  void _showVisibilityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Visibility'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildVisibilityOption(
                'Public', 'public', 'Visible to all customers'),
            _buildVisibilityOption(
                'Local Only', 'local', 'Visible to customers in your area'),
            _buildVisibilityOption(
                'Private', 'private', 'Not visible in marketplace'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityOption(
      String title, String value, String description) {
    final currentVisibility =
        widget.marketplaceSettings['profileVisibility'] ?? 'public';

    return RadioListTile<String>(
      title: Text(title),
      subtitle: Text(description),
      value: value,
      groupValue: currentVisibility,
      onChanged: (selectedValue) {
        if (selectedValue != null) {
          final updatedSettings = {
            ...widget.marketplaceSettings,
            'profileVisibility': selectedValue,
          };
          widget.onMarketplaceSettingsChanged(updatedSettings);
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile visibility changed to $title')),
          );
        }
      },
    );
  }

  String _getVisibilityDisplayText() {
    final visibility =
        widget.marketplaceSettings['profileVisibility'] ?? 'public';
    switch (visibility) {
      case 'public':
        return 'Public';
      case 'local':
        return 'Local Only';
      case 'private':
        return 'Private';
      default:
        return 'Public';
    }
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
                iconName: 'store',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Marketplace Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CustomIconWidget(
              iconName: 'visibility',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Profile Visibility'),
            subtitle: Text(_getVisibilityDisplayText()),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onTap: _showVisibilityDialog,
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: CustomIconWidget(
              iconName: 'auto_awesome',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Auto-List New Products'),
            subtitle: const Text(
                'Automatically list new inventory items in marketplace'),
            value: widget.marketplaceSettings['autoListProducts'] ?? false,
            onChanged: (value) =>
                _updateMarketplaceSetting('autoListProducts', value),
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: CustomIconWidget(
              iconName: 'chat',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Customer Messages'),
            subtitle: const Text('Allow customers to send direct messages'),
            value: widget.marketplaceSettings['allowCustomerMessages'] ?? true,
            onChanged: (value) =>
                _updateMarketplaceSetting('allowCustomerMessages', value),
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: CustomIconWidget(
              iconName: 'star',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Customer Reviews'),
            subtitle:
                const Text('Allow customers to leave reviews and ratings'),
            value: widget.marketplaceSettings['allowCustomerReviews'] ?? true,
            onChanged: (value) =>
                _updateMarketplaceSetting('allowCustomerReviews', value),
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: CustomIconWidget(
              iconName: 'local_offer',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Promotional Offers'),
            subtitle: const Text('Enable promotional pricing and discounts'),
            value: widget.marketplaceSettings['enablePromotions'] ?? false,
            onChanged: (value) =>
                _updateMarketplaceSetting('enablePromotions', value),
          ),
        ],
      ),
    );
  }
}
