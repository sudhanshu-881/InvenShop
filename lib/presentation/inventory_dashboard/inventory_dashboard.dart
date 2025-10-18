import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/dashboard_header_widget.dart';
import './widgets/inventory_section_widget.dart';
import './widgets/metrics_card_widget.dart';

class InventoryDashboard extends StatefulWidget {
  const InventoryDashboard({Key? key}) : super(key: key);

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isRefreshing = false;
  late TabController _tabController;

  // Mock data for business
  final String businessName = "Mike's Electronics Store";
  final int notificationCount = 3;

  // Mock metrics data
  final List<Map<String, dynamic>> metricsData = [
    {
      "title": "Total Items",
      "value": "1,247",
      "subtitle": "+12 today",
      "statusColor": AppTheme.successLight,
      "iconName": "inventory_2",
    },
    {
      "title": "Low Stock",
      "value": "23",
      "subtitle": "Need attention",
      "statusColor": AppTheme.errorLight,
      "iconName": "warning",
    },
    {
      "title": "Today's Sales",
      "value": "\$2,840",
      "subtitle": "+15% vs yesterday",
      "statusColor": AppTheme.successLight,
      "iconName": "trending_up",
    },
    {
      "title": "Marketplace",
      "value": "156",
      "subtitle": "Active listings",
      "statusColor": AppTheme.secondaryLight,
      "iconName": "store",
    },
  ];

  // Mock recent additions data
  final List<Map<String, dynamic>> recentAdditions = [
    {
      "id": 1,
      "name": "iPhone 15 Pro Max",
      "category": "Smartphones",
      "stock": 45,
      "price": "\$1,199",
      "image":
          "https://images.unsplash.com/photo-1636462060335-a0e53fcba38f",
      "semanticLabel":
          "Modern black smartphone with sleek design lying on white surface with soft lighting",
    },
    {
      "id": 2,
      "name": "Samsung Galaxy Watch 6",
      "category": "Wearables",
      "stock": 28,
      "price": "\$329",
      "image":
          "https://images.unsplash.com/photo-1684691106418-3b9e4a63ee64",
      "semanticLabel":
          "Silver smartwatch with black sport band displaying digital interface on white background",
    },
    {
      "id": 3,
      "name": "MacBook Air M3",
      "category": "Laptops",
      "stock": 12,
      "price": "\$1,299",
      "image":
          "https://images.unsplash.com/photo-1518472803163-8d3a9e90792c",
      "semanticLabel":
          "Silver laptop computer opened on wooden desk with clean modern workspace setup",
    },
  ];

  // Mock low stock items data
  final List<Map<String, dynamic>> lowStockItems = [
    {
      "id": 4,
      "name": "AirPods Pro 2nd Gen",
      "category": "Audio",
      "stock": 3,
      "price": "\$249",
      "image":
          "https://images.unsplash.com/photo-1596789270729-df562b516d96",
      "semanticLabel":
          "White wireless earbuds in charging case on minimalist white surface with soft shadows",
    },
    {
      "id": 5,
      "name": "iPad Pro 12.9",
      "category": "Tablets",
      "stock": 5,
      "price": "\$1,099",
      "image":
          "https://images.unsplash.com/photo-1603695680521-1f8489438a92",
      "semanticLabel":
          "Black tablet device with large screen displaying colorful interface on modern desk",
    },
  ];

  // Mock top selling products data
  final List<Map<String, dynamic>> topSellingProducts = [
    {
      "id": 6,
      "name": "iPhone 14",
      "category": "Smartphones",
      "stock": 67,
      "price": "\$799",
      "image":
          "https://images.unsplash.com/photo-1662627362392-da345c6f7731",
      "semanticLabel":
          "Blue smartphone with modern design placed on white surface with professional lighting",
    },
    {
      "id": 7,
      "name": "Samsung Galaxy S24",
      "category": "Smartphones",
      "stock": 34,
      "price": "\$899",
      "image":
          "https://images.unsplash.com/photo-1527912634026-9155185a7fe3",
      "semanticLabel":
          "Black Android smartphone with curved edges displaying home screen on dark surface",
    },
    {
      "id": 8,
      "name": "Apple Watch Series 9",
      "category": "Wearables",
      "stock": 89,
      "price": "\$399",
      "image":
          "https://images.unsplash.com/photo-1617043593449-c881f876a4b4",
      "semanticLabel":
          "Rose gold smartwatch with white sport band showing fitness app interface on wrist",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isRefreshing = false;
    });

    Fluttertoast.showToast(
      msg: "Dashboard updated successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onItemTap(Map<String, dynamic> item) {
    Navigator.pushNamed(context, '/add-edit-product-screen');
  }

  void _onEditStock(Map<String, dynamic> item) {
    _showStockEditDialog(item);
  }

  void _onAddToMarketplace(Map<String, dynamic> item) {
    Fluttertoast.showToast(
      msg: "${item['name']} added to marketplace",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onViewDetails(Map<String, dynamic> item) {
    Navigator.pushNamed(context, '/add-edit-product-screen');
  }

  void _onDuplicate(Map<String, dynamic> item) {
    Fluttertoast.showToast(
      msg: "${item['name']} duplicated successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onArchive(Map<String, dynamic> item) {
    Fluttertoast.showToast(
      msg: "${item['name']} archived",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onShare(Map<String, dynamic> item) {
    Fluttertoast.showToast(
      msg: "Sharing ${item['name']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showStockEditDialog(Map<String, dynamic> item) {
    final TextEditingController stockController = TextEditingController(
      text: item['stock'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['name'],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Stock Quantity',
                hintText: 'Enter stock quantity',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Stock updated for ${item['name']}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _onAddNewItem() {
    Navigator.pushNamed(context, '/add-edit-product-screen');
  }

  void _onNotificationTap() {
    Fluttertoast.showToast(
      msg: "You have $notificationCount new notifications",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onSearchTap() {
    Fluttertoast.showToast(
      msg: "Search functionality coming soon",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DashboardHeaderWidget(
                  businessName: businessName,
                  notificationCount: notificationCount,
                  onNotificationTap: _onNotificationTap,
                  onSearchTap: _onSearchTap,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 2.h),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 20.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: metricsData.length,
                    itemBuilder: (context, index) {
                      final metric = metricsData[index];
                      return MetricsCardWidget(
                        title: metric['title'],
                        value: metric['value'],
                        subtitle: metric['subtitle'],
                        statusColor: metric['statusColor'],
                        iconName: metric['iconName'],
                        onTap: () {
                          if (metric['title'] == 'Marketplace') {
                            Navigator.pushNamed(
                                context, '/marketplace-browse-screen');
                          } else if (metric['title'] == 'Today\'s Sales') {
                            Navigator.pushNamed(
                                context, '/analytics-dashboard-screen');
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 3.h),
              ),
              SliverToBoxAdapter(
                child: InventorySectionWidget(
                  title: 'Recent Additions',
                  subtitle: 'Latest products added to inventory',
                  items: recentAdditions,
                  onSeeAll: () =>
                      Navigator.pushNamed(context, '/add-edit-product-screen'),
                  onItemTap: _onItemTap,
                  onEditStock: _onEditStock,
                  onAddToMarketplace: _onAddToMarketplace,
                  onViewDetails: _onViewDetails,
                  onDuplicate: _onDuplicate,
                  onArchive: _onArchive,
                  onShare: _onShare,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 3.h),
              ),
              SliverToBoxAdapter(
                child: InventorySectionWidget(
                  title: 'Low Stock Alert',
                  subtitle: 'Items that need immediate attention',
                  items: lowStockItems,
                  onSeeAll: () =>
                      Navigator.pushNamed(context, '/add-edit-product-screen'),
                  onItemTap: _onItemTap,
                  onEditStock: _onEditStock,
                  onAddToMarketplace: _onAddToMarketplace,
                  onViewDetails: _onViewDetails,
                  onDuplicate: _onDuplicate,
                  onArchive: _onArchive,
                  onShare: _onShare,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 3.h),
              ),
              SliverToBoxAdapter(
                child: InventorySectionWidget(
                  title: 'Top Selling Products',
                  subtitle: 'Your best performing items',
                  items: topSellingProducts,
                  onSeeAll: () => Navigator.pushNamed(
                      context, '/analytics-dashboard-screen'),
                  onItemTap: _onItemTap,
                  onEditStock: _onEditStock,
                  onAddToMarketplace: _onAddToMarketplace,
                  onViewDetails: _onViewDetails,
                  onDuplicate: _onDuplicate,
                  onArchive: _onArchive,
                  onShare: _onShare,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 10.h),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddNewItem,
        icon: CustomIconWidget(
          iconName: 'add_a_photo',
          color: Theme.of(context).floatingActionButtonTheme.foregroundColor ??
              Colors.white,
          size: 6.w,
        ),
        label: Text(
          'Add Item',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context)
                        .floatingActionButtonTheme
                        .foregroundColor ??
                    Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              // Already on Dashboard
              break;
            case 1:
              Navigator.pushNamed(context, '/add-edit-product-screen');
              break;
            case 2:
              Navigator.pushNamed(context, '/marketplace-browse-screen');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile-settings-screen');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              color: _currentIndex == 0
                  ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                  : Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
              size: 6.w,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'inventory_2',
              color: _currentIndex == 1
                  ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                  : Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
              size: 6.w,
            ),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'store',
              color: _currentIndex == 2
                  ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                  : Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
              size: 6.w,
            ),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentIndex == 3
                  ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                  : Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
              size: 6.w,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
