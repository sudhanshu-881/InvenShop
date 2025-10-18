import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SortOptionsWidget extends StatelessWidget {
  final String currentSort;
  final Function(String) onSortChanged;

  const SortOptionsWidget({
    Key? key,
    required this.currentSort,
    required this.onSortChanged,
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
          // Header
          Row(
            children: [
              Text(
                'Sort by',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  size: 24,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Sort Options
          _buildSortOption(
            context,
            'Distance (Nearest First)',
            'distance',
            'location_on',
          ),
          _buildSortOption(
            context,
            'Price (Low to High)',
            'price_low',
            'arrow_upward',
          ),
          _buildSortOption(
            context,
            'Price (High to Low)',
            'price_high',
            'arrow_downward',
          ),
          _buildSortOption(
            context,
            'Rating (Highest First)',
            'rating',
            'star',
          ),
          _buildSortOption(
            context,
            'Newest Listings',
            'newest',
            'schedule',
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String title,
    String value,
    String iconName,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = currentSort == value;

    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        size: 24,
        color: isSelected
            ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
            : (isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                  : null,
            ),
      ),
      trailing: isSelected
          ? CustomIconWidget(
              iconName: 'check',
              size: 24,
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            )
          : null,
      onTap: () {
        onSortChanged(value);
        Navigator.pop(context);
      },
    );
  }
}
