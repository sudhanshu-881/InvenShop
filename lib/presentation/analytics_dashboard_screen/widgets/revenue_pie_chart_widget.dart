import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class RevenuePieChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> revenueData;

  const RevenuePieChartWidget({
    Key? key,
    required this.revenueData,
  }) : super(key: key);

  @override
  State<RevenuePieChartWidget> createState() => _RevenuePieChartWidgetState();
}

class _RevenuePieChartWidgetState extends State<RevenuePieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 40.h,
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
          Text(
            'Revenue Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Semantics(
                    label:
                        "Revenue breakdown pie chart showing category-wise performance",
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 8.w,
                        sections: _generateSections(isDark),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.revenueData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      final isSelected = touchedIndex == index;

                      return Container(
                        margin: EdgeInsets.only(bottom: 1.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                      ? AppTheme.primaryDark
                                      : AppTheme.primaryLight)
                                  .withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 3.w,
                              height: 3.w,
                              decoration: BoxDecoration(
                                color: _getColor(index, isDark),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['category'],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppTheme.textPrimaryDark
                                          : AppTheme.textPrimaryLight,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${data['percentage']}%',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondaryLight,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generateSections(bool isDark) {
    return widget.revenueData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 14.sp : 12.sp;
      final radius = isTouched ? 12.w : 10.w;

      return PieChartSectionData(
        color: _getColor(index, isDark),
        value: (data['percentage'] as num).toDouble(),
        title: isTouched ? '${data['percentage']}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getColor(int index, bool isDark) {
    final colors = isDark
        ? [
            AppTheme.primaryDark,
            AppTheme.secondaryDark,
            AppTheme.successDark,
            AppTheme.warningDark,
            AppTheme.errorDark,
          ]
        : [
            AppTheme.primaryLight,
            AppTheme.secondaryLight,
            AppTheme.successLight,
            AppTheme.warningLight,
            AppTheme.errorLight,
          ];

    return colors[index % colors.length];
  }
}
