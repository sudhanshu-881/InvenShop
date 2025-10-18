import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AppSettingsSection extends StatefulWidget {
  final Map<String, dynamic> appSettings;
  final Function(Map<String, dynamic>) onAppSettingsChanged;

  const AppSettingsSection({
    Key? key,
    required this.appSettings,
    required this.onAppSettingsChanged,
  }) : super(key: key);

  @override
  State<AppSettingsSection> createState() => _AppSettingsSectionState();
}

class _AppSettingsSectionState extends State<AppSettingsSection> {
  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('Light', 'light'),
            _buildThemeOption('Dark', 'dark'),
            _buildThemeOption('System Default', 'system'),
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

  Widget _buildThemeOption(String title, String value) {
    final currentTheme = widget.appSettings['theme'] ?? 'system';

    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: currentTheme,
      onChanged: (selectedValue) {
        if (selectedValue != null) {
          final updatedSettings = {
            ...widget.appSettings,
            'theme': selectedValue,
          };
          widget.onAppSettingsChanged(updatedSettings);
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Theme changed to $title')),
          );
        }
      },
    );
  }

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', 'en'),
            _buildLanguageOption('Spanish', 'es'),
            _buildLanguageOption('French', 'fr'),
            _buildLanguageOption('German', 'de'),
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

  Widget _buildLanguageOption(String title, String value) {
    final currentLanguage = widget.appSettings['language'] ?? 'en';

    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: currentLanguage,
      onChanged: (selectedValue) {
        if (selectedValue != null) {
          final updatedSettings = {
            ...widget.appSettings,
            'language': selectedValue,
          };
          widget.onAppSettingsChanged(updatedSettings);
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Language changed to $title')),
          );
        }
      },
    );
  }

  void _showCurrencySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyOption('US Dollar (\$)', 'USD'),
            _buildCurrencyOption('Euro (€)', 'EUR'),
            _buildCurrencyOption('British Pound (£)', 'GBP'),
            _buildCurrencyOption('Canadian Dollar (C\$)', 'CAD'),
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

  Widget _buildCurrencyOption(String title, String value) {
    final currentCurrency = widget.appSettings['currency'] ?? 'USD';

    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: currentCurrency,
      onChanged: (selectedValue) {
        if (selectedValue != null) {
          final updatedSettings = {
            ...widget.appSettings,
            'currency': selectedValue,
          };
          widget.onAppSettingsChanged(updatedSettings);
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Currency changed to $title')),
          );
        }
      },
    );
  }

  String _getThemeDisplayText() {
    final theme = widget.appSettings['theme'] ?? 'system';
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
      default:
        return 'System Default';
    }
  }

  String _getLanguageDisplayText() {
    final language = widget.appSettings['language'] ?? 'en';
    switch (language) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      default:
        return 'English';
    }
  }

  String _getCurrencyDisplayText() {
    final currency = widget.appSettings['currency'] ?? 'USD';
    switch (currency) {
      case 'USD':
        return 'US Dollar (\$)';
      case 'EUR':
        return 'Euro (€)';
      case 'GBP':
        return 'British Pound (£)';
      case 'CAD':
        return 'Canadian Dollar (C\$)';
      default:
        return 'US Dollar (\$)';
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
                iconName: 'settings',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'App Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CustomIconWidget(
              iconName: 'palette',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Theme'),
            subtitle: Text(_getThemeDisplayText()),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onTap: _showThemeSelectionDialog,
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CustomIconWidget(
              iconName: 'language',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Language'),
            subtitle: Text(_getLanguageDisplayText()),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onTap: _showLanguageSelectionDialog,
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CustomIconWidget(
              iconName: 'attach_money',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Currency'),
            subtitle: Text(_getCurrencyDisplayText()),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onTap: _showCurrencySelectionDialog,
          ),
        ],
      ),
    );
  }
}
