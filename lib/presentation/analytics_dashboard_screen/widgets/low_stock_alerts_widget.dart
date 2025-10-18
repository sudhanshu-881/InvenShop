import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LowStockAlertsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> lowStockItems;
  final VoidCallback onViewAll;

  const LowStockAlertsWidget({
    Key? key,
    required this.lowStockItems,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            AppTheme.getElevationShadow(elevation: 2.0, isLight: !isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color:
                        isDark ? AppTheme.warningDark : AppTheme.warningLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Low Stock Alerts',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  'View All',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          lowStockItems.isEmpty
              ? _buildEmptyState(context, isDark)
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      lowStockItems.length > 3 ? 3 : lowStockItems.length,
                  separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
                  itemBuilder: (context, index) {
                    final item = lowStockItems[index];
                    return _buildLowStockItem(context, item, isDark);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            color: isDark ? AppTheme.successDark : AppTheme.successLight,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'All items are well stocked!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockItem(
      BuildContext context, Map<String, dynamic> item, bool isDark) {
    final theme = Theme.of(context);
    final stockLevel = item['currentStock'] as int;
    final minStock = item['minStock'] as int;
    final urgencyLevel = stockLevel == 0
        ? 'critical'
        : stockLevel <= minStock * 0.5
            ? 'high'
            : 'medium';

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _getUrgencyColor(urgencyLevel, isDark).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getUrgencyColor(urgencyLevel, isDark).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomImageWidget(
              imageUrl: item['image'],
              width: 12.w,
              height: 12.w,
              fit: BoxFit.cover,
              semanticLabel: item['semanticLabel'],
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      'Stock: ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                    Text(
                      '$stockLevel units',
                      style: AppTheme.quantityTextStyle(
                        isLight: !isDark,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                LinearProgressIndicator(
                  value: stockLevel / (minStock * 2),
                  backgroundColor:
                      (isDark ? AppTheme.borderDark : AppTheme.borderLight)
                          .withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getUrgencyColor(urgencyLevel, isDark),
                  ),
                  minHeight: 1.h,
                ),
              ],
            ),
          ),
          SizedBox(width: 3.w),
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getUrgencyColor(urgencyLevel, isDark),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  urgencyLevel.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 9.sp,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/inventory-dashboard');
                },
                child: Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color:
                        (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CustomIconWidget(
                    iconName: 'arrow_forward',
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(String urgencyLevel, bool isDark) {
    switch (urgencyLevel) {
      case 'critical':
        return isDark ? AppTheme.errorDark : AppTheme.errorLight;
      case 'high':
        return isDark ? AppTheme.warningDark : AppTheme.warningLight;
      case 'medium':
        return isDark ? AppTheme.secondaryDark : AppTheme.secondaryLight;
      default:
        return isDark
            ? AppTheme.textSecondaryDark
            : AppTheme.textSecondaryLight;
    }
  }
}
