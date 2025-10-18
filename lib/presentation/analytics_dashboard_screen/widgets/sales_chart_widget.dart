import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SalesChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> salesData;
  final String selectedPeriod;

  const SalesChartWidget({
    Key? key,
    required this.salesData,
    required this.selectedPeriod,
  }) : super(key: key);

  @override
  State<SalesChartWidget> createState() => _SalesChartWidgetState();
}

class _SalesChartWidgetState extends State<SalesChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 32.h,
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
            'Sales Trend',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: Semantics(
              label:
                  "Sales trend line chart showing ${widget.selectedPeriod.toLowerCase()} performance",
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1000,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: (isDark
                                ? AppTheme.borderDark
                                : AppTheme.borderLight)
                            .withValues(alpha: 0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < widget.salesData.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                widget.salesData[value.toInt()]['period'],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppTheme.textSecondaryDark
                                      : AppTheme.textSecondaryLight,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1000,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '\$${(value / 1000).toStringAsFixed(0)}K',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color:
                          (isDark ? AppTheme.borderDark : AppTheme.borderLight)
                              .withValues(alpha: 0.3),
                    ),
                  ),
                  minX: 0,
                  maxX: (widget.salesData.length - 1).toDouble(),
                  minY: 0,
                  maxY: _getMaxValue() * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateSpots(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                          (isDark
                                  ? AppTheme.primaryDark
                                  : AppTheme.primaryLight)
                              .withValues(alpha: 0.3),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: touchedIndex == index ? 6 : 4,
                            color: isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight,
                            strokeWidth: 2,
                            strokeColor: theme.cardColor,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            (isDark
                                    ? AppTheme.primaryDark
                                    : AppTheme.primaryLight)
                                .withValues(alpha: 0.3),
                            (isDark
                                    ? AppTheme.primaryDark
                                    : AppTheme.primaryLight)
                                .withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchCallback:
                        (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      setState(() {
                        if (touchResponse != null &&
                            touchResponse.lineBarSpots != null) {
                          touchedIndex =
                              touchResponse.lineBarSpots!.first.spotIndex;
                        } else {
                          touchedIndex = -1;
                        }
                      });
                    },
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: theme.cardColor,
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          return LineTooltipItem(
                            '\$${barSpot.y.toStringAsFixed(0)}',
                            TextStyle(
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    return widget.salesData.asMap().entries.map((entry) {
      return FlSpot(
          entry.key.toDouble(), (entry.value['sales'] as num).toDouble());
    }).toList();
  }

  double _getMaxValue() {
    if (widget.salesData.isEmpty) return 5000;
    return widget.salesData
        .map((data) => (data['sales'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }
}
