import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class KpiCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String changePercentage;
  final bool isPositive;
  final CustomIconWidget icon;

  const KpiCardWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.changePercentage,
    required this.isPositive,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 42.w,
      height: 16.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            AppTheme.getElevationShadow(elevation: 2.0, isLight: !isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.all(1.5.w),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: icon,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              CustomIconWidget(
                iconName: isPositive ? 'trending_up' : 'trending_down',
                color: isPositive
                    ? (isDark ? AppTheme.successDark : AppTheme.successLight)
                    : (isDark ? AppTheme.errorDark : AppTheme.errorLight),
                size: 16,
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  changePercentage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isPositive
                        ? (isDark
                            ? AppTheme.successDark
                            : AppTheme.successLight)
                        : (isDark ? AppTheme.errorDark : AppTheme.errorLight),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
