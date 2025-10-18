import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsWidget extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onAddToWishlist;
  final VoidCallback? onShare;
  final VoidCallback? onViewProfile;

  const QuickActionsWidget({
    Key? key,
    required this.product,
    this.onAddToWishlist,
    this.onShare,
    this.onViewProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product Info
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: product['image'] as String? ?? '',
                  width: 15.w,
                  height: 15.w,
                  fit: BoxFit.cover,
                  semanticLabel:
                      product['semanticLabel'] as String? ?? 'Product image',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] as String? ?? 'Unknown Product',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      product['shopkeeper'] as String? ?? 'Unknown Shop',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Action Buttons
          _buildActionButton(
            context,
            'Add to Wishlist',
            'favorite_border',
            onAddToWishlist,
          ),
          _buildActionButton(
            context,
            'Share Product',
            'share',
            onShare,
          ),
          _buildActionButton(
            context,
            'View Shopkeeper Profile',
            'store',
            onViewProfile,
          ),

          SizedBox(height: 2.h),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ),

          SizedBox(height: 1.h),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String iconName,
    VoidCallback? onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        size: 24,
        color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onTap: () {
        Navigator.pop(context);
        onTap?.call();
      },
    );
  }
}
