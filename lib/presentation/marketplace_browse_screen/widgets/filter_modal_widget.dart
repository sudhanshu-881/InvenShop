import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterModalWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterModalWidget({
    Key? key,
    required this.currentFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  late Map<String, dynamic> _filters;
  double _distanceRadius = 5.0;
  RangeValues _priceRange = const RangeValues(0, 1000);
  String _availabilityStatus = 'all';
  double _minRating = 0.0;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    _distanceRadius = (_filters['distance'] as double?) ?? 5.0;
    _priceRange = RangeValues(
      (_filters['minPrice'] as double?) ?? 0,
      (_filters['maxPrice'] as double?) ?? 1000,
    );
    _availabilityStatus = (_filters['availability'] as String?) ?? 'all';
    _minRating = (_filters['minRating'] as double?) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Reset',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isDark
                              ? AppTheme.primaryDark
                              : AppTheme.primaryLight,
                        ),
                  ),
                ),
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
          ),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Distance Radius
                  _buildFilterSection(
                    'Distance Radius',
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '0 km',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${_distanceRadius.toInt()} km',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              '50 km',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        Slider(
                          value: _distanceRadius,
                          min: 0,
                          max: 50,
                          divisions: 50,
                          onChanged: (value) {
                            setState(() => _distanceRadius = value);
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Price Range
                  _buildFilterSection(
                    'Price Range',
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${_priceRange.start.toInt()}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              '\$${_priceRange.end.toInt()}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 1000,
                          divisions: 100,
                          onChanged: (values) {
                            setState(() => _priceRange = values);
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Availability Status
                  _buildFilterSection(
                    'Availability',
                    Column(
                      children: [
                        _buildRadioOption('All Items', 'all'),
                        _buildRadioOption('In Stock Only', 'in_stock'),
                        _buildRadioOption('Low Stock', 'low_stock'),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Minimum Rating
                  _buildFilterSection(
                    'Minimum Rating',
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '0 stars',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Row(
                              children: [
                                Text(
                                  '${_minRating.toStringAsFixed(1)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                SizedBox(width: 1.w),
                                CustomIconWidget(
                                  iconName: 'star',
                                  size: 16,
                                  color: Colors.amber,
                                ),
                              ],
                            ),
                            Text(
                              '5 stars',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        Slider(
                          value: _minRating,
                          min: 0,
                          max: 5,
                          divisions: 50,
                          onChanged: (value) {
                            setState(() => _minRating = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 2.h),
        content,
      ],
    );
  }

  Widget _buildRadioOption(String title, String value) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: _availabilityStatus,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() => _availabilityStatus = newValue);
        }
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  void _resetFilters() {
    setState(() {
      _distanceRadius = 5.0;
      _priceRange = const RangeValues(0, 1000);
      _availabilityStatus = 'all';
      _minRating = 0.0;
    });
  }

  void _applyFilters() {
    final filters = {
      'distance': _distanceRadius,
      'minPrice': _priceRange.start,
      'maxPrice': _priceRange.end,
      'availability': _availabilityStatus,
      'minRating': _minRating,
    };

    widget.onFiltersChanged(filters);
    Navigator.pop(context);
  }
}
