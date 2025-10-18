import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CategoryChipWidget extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback? onTap;
  final int? filterCount;

  const CategoryChipWidget({
    Key? key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.filterCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 2.w),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
              : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? (isDark
                            ? AppTheme.onPrimaryDark
                            : AppTheme.onPrimaryLight)
                        : (isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
            if (filterCount != null && filterCount! > 0) ...[
              SizedBox(width: 1.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? AppTheme.onPrimaryDark
                          : AppTheme.onPrimaryLight)
                      : (isDark ? AppTheme.primaryDark : AppTheme.primaryLight),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  filterCount.toString(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? (isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight)
                            : (isDark
                                ? AppTheme.onPrimaryDark
                                : AppTheme.onPrimaryLight),
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
