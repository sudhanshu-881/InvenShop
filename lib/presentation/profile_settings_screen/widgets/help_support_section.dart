import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class HelpSupportSection extends StatelessWidget {
  const HelpSupportSection({Key? key}) : super(key: key);

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: SizedBox(
          width: 80.w,
          height: 60.h,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFAQItem(
                  context,
                  'How do I add products to my inventory?',
                  'Go to the Inventory Dashboard and tap the "+" button to add new products. Fill in the product details and save.',
                ),
                SizedBox(height: 2.h),
                _buildFAQItem(
                  context,
                  'How do I list products in the marketplace?',
                  'From your inventory, select a product and toggle the "List in Marketplace" option. You can also enable auto-listing in settings.',
                ),
                SizedBox(height: 2.h),
                _buildFAQItem(
                  context,
                  'How do I track my sales?',
                  'Visit the Analytics Dashboard to view detailed sales reports, revenue tracking, and performance metrics.',
                ),
                SizedBox(height: 2.h),
                _buildFAQItem(
                  context,
                  'Can I backup my inventory data?',
                  'Yes, go to Profile Settings > Data Management to backup, restore, or export your inventory data.',
                ),
                SizedBox(height: 2.h),
                _buildFAQItem(
                  context,
                  'How do I change my notification preferences?',
                  'In Profile Settings > Notification Preferences, you can customize which notifications you want to receive.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 1.h),
        Text(
          answer,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'email',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Email Support'),
              subtitle: const Text('support@shopstockpro.com'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email client...')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'phone',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Phone Support'),
              subtitle: const Text('+1 (555) 123-4567'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening phone dialer...')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'chat',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Live Chat'),
              subtitle: const Text('Available 9 AM - 6 PM EST'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting live chat...')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'ShopStock Pro',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text('Version: 1.0.0'),
            SizedBox(height: 1.h),
            Text('Build: 2025.10.18'),
            SizedBox(height: 1.h),
            Text('© 2025 ShopStock Pro'),
            SizedBox(height: 2.h),
            Text(
              'Enterprise inventory management solution for local shopkeepers with integrated marketplace functionality.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
                iconName: 'help',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Help & Support',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CustomIconWidget(
              iconName: 'quiz',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('FAQ'),
            subtitle: const Text('Frequently asked questions'),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onTap: () => _showFAQDialog(context),
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CustomIconWidget(
              iconName: 'support_agent',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Contact Support'),
            subtitle: const Text('Get help from our support team'),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onTap: () => _showContactSupportDialog(context),
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CustomIconWidget(
              iconName: 'info_outline',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('App Information'),
            subtitle: const Text('Version and build details'),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onTap: () => _showAppInfoDialog(context),
          ),
        ],
      ),
    );
  }
}
