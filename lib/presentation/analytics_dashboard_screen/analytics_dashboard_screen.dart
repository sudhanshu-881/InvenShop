import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/kpi_card_widget.dart';
import './widgets/low_stock_alerts_widget.dart';
import './widgets/marketplace_analytics_widget.dart';
import './widgets/revenue_pie_chart_widget.dart';
import './widgets/sales_chart_widget.dart';
import './widgets/top_products_widget.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Today';
  bool _isRefreshing = false;
  DateTime _lastUpdated = DateTime.now();

  // Mock data
  final List<Map<String, dynamic>> _kpiData = [
    {
      'title': 'Total Sales',
      'value': '\$12,450',
      'changePercentage': '+15.2% vs last period',
      'isPositive': true,
      'icon': CustomIconWidget(
          iconName: 'attach_money', color: AppTheme.primaryLight, size: 20),
    },
    {
      'title': 'Inventory Turnover',
      'value': '2.4x',
      'changePercentage': '+8.5% vs last period',
      'isPositive': true,
      'icon': CustomIconWidget(
          iconName: 'sync', color: AppTheme.successLight, size: 20),
    },
    {
      'title': 'Marketplace Sales',
      'value': '\$3,280',
      'changePercentage': '+22.1% vs last period',
      'isPositive': true,
      'icon': CustomIconWidget(
          iconName: 'store', color: AppTheme.secondaryLight, size: 20),
    },
    {
      'title': 'Profit Margin',
      'value': '28.5%',
      'changePercentage': '-2.3% vs last period',
      'isPositive': false,
      'icon': CustomIconWidget(
          iconName: 'trending_up', color: AppTheme.warningLight, size: 20),
    },
  ];

  final Map<String, List<Map<String, dynamic>>> _salesData = {
    'Today': [
      {'period': '9AM', 'sales': 1200},
      {'period': '12PM', 'sales': 2800},
      {'period': '3PM', 'sales': 1900},
      {'period': '6PM', 'sales': 3200},
      {'period': '9PM', 'sales': 2100},
    ],
    'Week': [
      {'period': 'Mon', 'sales': 8500},
      {'period': 'Tue', 'sales': 12200},
      {'period': 'Wed', 'sales': 9800},
      {'period': 'Thu', 'sales': 15600},
      {'period': 'Fri', 'sales': 18900},
      {'period': 'Sat', 'sales': 22100},
      {'period': 'Sun', 'sales': 16400},
    ],
    'Month': [
      {'period': 'Week 1', 'sales': 45000},
      {'period': 'Week 2', 'sales': 52000},
      {'period': 'Week 3', 'sales': 48000},
      {'period': 'Week 4', 'sales': 58000},
    ],
    'Year': [
      {'period': 'Q1', 'sales': 180000},
      {'period': 'Q2', 'sales': 220000},
      {'period': 'Q3', 'sales': 195000},
      {'period': 'Q4', 'sales': 245000},
    ],
  };

  final List<Map<String, dynamic>> _revenueData = [
    {'category': 'Electronics', 'percentage': 35},
    {'category': 'Clothing', 'percentage': 28},
    {'category': 'Home & Garden', 'percentage': 18},
    {'category': 'Sports', 'percentage': 12},
    {'category': 'Books', 'percentage': 7},
  ];

  final List<Map<String, dynamic>> _topProducts = [
    {
      'name': 'Wireless Headphones',
      'soldQuantity': 145,
      'revenue': '\$4,350',
      'contribution': 12.5,
      'image':
          'https://images.unsplash.com/photo-1677101030339-d6b9df60a5ad',
      'semanticLabel':
          'Black wireless over-ear headphones with silver accents on white background',
    },
    {
      'name': 'Cotton T-Shirt',
      'soldQuantity': 289,
      'revenue': '\$2,890',
      'contribution': 8.3,
      'image':
          'https://images.unsplash.com/photo-1666358059751-3accf39c2d95',
      'semanticLabel':
          'Plain white cotton t-shirt laid flat on neutral background',
    },
    {
      'name': 'Garden Planter',
      'soldQuantity': 67,
      'revenue': '\$2,010',
      'contribution': 5.8,
      'image':
          'https://images.unsplash.com/photo-1682963934264-f0bf1fc05762',
      'semanticLabel':
          'Terracotta garden planter with green plants growing in natural outdoor setting',
    },
    {
      'name': 'Running Shoes',
      'soldQuantity': 92,
      'revenue': '\$1,840',
      'contribution': 5.3,
      'image':
          'https://images.unsplash.com/photo-1575456456278-936c89ccdb7b',
      'semanticLabel':
          'Modern athletic running shoes in blue and white colors on clean surface',
    },
    {
      'name': 'Recipe Book',
      'soldQuantity': 156,
      'revenue': '\$1,560',
      'contribution': 4.5,
      'image':
          'https://images.unsplash.com/photo-1612031736184-77bc60f94c06',
      'semanticLabel':
          'Open cookbook with colorful food photography and recipe text on wooden table',
    },
  ];

  final List<Map<String, dynamic>> _lowStockItems = [
    {
      'name': 'Wireless Mouse',
      'currentStock': 3,
      'minStock': 10,
      'image':
          'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46',
      'semanticLabel':
          'Black wireless computer mouse on white surface with clean modern design',
    },
    {
      'name': 'Yoga Mat',
      'currentStock': 0,
      'minStock': 15,
      'image':
          'https://images.unsplash.com/photo-1502164365315-380021337592',
      'semanticLabel':
          'Purple yoga mat rolled up on wooden floor in bright fitness studio',
    },
    {
      'name': 'Coffee Mug',
      'currentStock': 8,
      'minStock': 20,
      'image':
          'https://images.unsplash.com/photo-1582906779651-bbff2ebdfb1c',
      'semanticLabel':
          'White ceramic coffee mug with steam rising from hot coffee on wooden table',
    },
  ];

  final Map<String, dynamic> _marketplaceData = {
    'listingViews': 2847,
    'conversionRate': 3.2,
    'averageRating': 4.6,
    'activeListings': 127,
    'insight':
        'Your electronics category is performing 23% better than average. Consider expanding this category.',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedPeriod = 'Today';
            break;
          case 1:
            _selectedPeriod = 'Week';
            break;
          case 2:
            _selectedPeriod = 'Month';
            break;
          case 3:
            _selectedPeriod = 'Year';
            break;
        }
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _lastUpdated = DateTime.now();
    });
  }

  void _exportReport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildExportBottomSheet(),
    );
  }

  Widget _buildExportBottomSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 10.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export Analytics Report',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 3.h),
                _buildExportOption(
                  context,
                  'PDF Report',
                  'Complete analytics with charts and insights',
                  'picture_as_pdf',
                  () => _handleExport('pdf'),
                  isDark,
                ),
                SizedBox(height: 2.h),
                _buildExportOption(
                  context,
                  'CSV Data',
                  'Raw data for further analysis',
                  'table_chart',
                  () => _handleExport('csv'),
                  isDark,
                ),
                SizedBox(height: 2.h),
                _buildExportOption(
                  context,
                  'Email Report',
                  'Send report to your email',
                  'email',
                  () => _handleExport('email'),
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(BuildContext context, String title, String subtitle,
      String iconName, VoidCallback onTap, bool isDark) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _handleExport(String type) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${type.toUpperCase()} export started. You will be notified when ready.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Analytics Dashboard',
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        actions: [
          IconButton(
            onPressed: _exportReport,
            icon: CustomIconWidget(
              iconName: 'file_download',
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: _refreshData,
            icon: _isRefreshing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                      ),
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'refresh',
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                    size: 24,
                  ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Week'),
            Tab(text: 'Month'),
            Tab(text: 'Year'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Last updated info
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'schedule',
                      color:
                          isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Last updated: ${_lastUpdated.hour.toString().padLeft(2, '0')}:${_lastUpdated.minute.toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.primaryDark
                            : AppTheme.primaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // KPI Cards
              Wrap(
                spacing: 3.w,
                runSpacing: 2.h,
                children: _kpiData
                    .map((kpi) => KpiCardWidget(
                          title: kpi['title'],
                          value: kpi['value'],
                          changePercentage: kpi['changePercentage'],
                          isPositive: kpi['isPositive'],
                          icon: kpi['icon'],
                        ))
                    .toList(),
              ),

              SizedBox(height: 3.h),

              // Sales Chart
              SalesChartWidget(
                salesData: _salesData[_selectedPeriod] ?? [],
                selectedPeriod: _selectedPeriod,
              ),

              SizedBox(height: 3.h),

              // Revenue Pie Chart
              RevenuePieChartWidget(
                revenueData: _revenueData,
              ),

              SizedBox(height: 3.h),

              // Top Products
              TopProductsWidget(
                topProducts: _topProducts,
              ),

              SizedBox(height: 3.h),

              // Low Stock Alerts
              LowStockAlertsWidget(
                lowStockItems: _lowStockItems,
                onViewAll: () {
                  Navigator.pushNamed(context, '/inventory-dashboard');
                },
              ),

              SizedBox(height: 3.h),

              // Marketplace Analytics
              MarketplaceAnalyticsWidget(
                marketplaceData: _marketplaceData,
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
