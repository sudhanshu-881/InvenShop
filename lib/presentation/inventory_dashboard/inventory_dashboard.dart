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
  final String businessName = "Rajesh Kumar General Store";
  final int notificationCount = 5;

  // Mock metrics data - Indian retail focused
  final List<Map<String, dynamic>> metricsData = [
    {
      "title": "Total Items",
      "value": "1,247",
      "subtitle": "+12 आज",
      "statusColor": AppTheme.successLight,
      "iconName": "inventory_2",
    },
    {
      "title": "Low Stock",
      "value": "23",
      "subtitle": "तुरंत ध्यान दें",
      "statusColor": AppTheme.errorLight,
      "iconName": "warning",
    },
    {
      "title": "Today's Sales",
      "value": "₹2,840",
      "subtitle": "+15% कल से",
      "statusColor": AppTheme.successLight,
      "iconName": "trending_up",
    },
    {
      "title": "Credit Dues",
      "value": "₹15,600",
      "subtitle": "12 customers",
      "statusColor": AppTheme.warningLight,
      "iconName": "account_balance_wallet",
    },
  ];

  // Mock recent additions data - Indian retail products
  final List<Map<String, dynamic>> recentAdditions = [
    {
      "id": 1,
      "name": "Tata Salt 1kg",
      "category": "Groceries",
      "stock": 45,
      "price": "₹25",
      "image":
          "https://images.unsplash.com/photo-1586201375761-83865001e31c",
      "semanticLabel":
          "White salt packet with Tata logo on clean background",
    },
    {
      "id": 2,
      "name": "Maggi Noodles 2-Minute",
      "category": "Food & Beverages",
      "stock": 28,
      "price": "₹14",
      "image":
          "https://images.unsplash.com/photo-1569718212165-3a8278d5f624",
      "semanticLabel":
          "Yellow Maggi noodles packet with red logo on white background",
    },
    {
      "id": 3,
      "name": "Parle-G Biscuits 100g",
      "category": "Snacks",
      "stock": 12,
      "price": "₹5",
      "image":
          "https://images.unsplash.com/photo-1558961363-fa8fdf82db35",
      "semanticLabel":
          "Orange Parle-G biscuit packet with child's face on clean background",
    },
  ];

  // Mock low stock items data - Indian retail products
  final List<Map<String, dynamic>> lowStockItems = [
    {
      "id": 4,
      "name": "Coca Cola 600ml",
      "category": "Beverages",
      "stock": 3,
      "price": "₹35",
      "image":
          "https://images.unsplash.com/photo-1581636625402-29b2a704ef6f",
      "semanticLabel":
          "Red Coca Cola bottle with white logo on clean background",
    },
    {
      "id": 5,
      "name": "Lays Classic 50g",
      "category": "Snacks",
      "stock": 5,
      "price": "₹20",
      "image":
          "https://images.unsplash.com/photo-1566478989037-eec170784d0b",
      "semanticLabel":
          "Yellow Lays chips packet with red logo on white background",
    },
  ];

  // Mock top selling products data - Indian retail products
  final List<Map<String, dynamic>> topSellingProducts = [
    {
      "id": 6,
      "name": "Aashirvaad Atta 5kg",
      "category": "Groceries",
      "stock": 67,
      "price": "₹180",
      "image":
          "https://images.unsplash.com/photo-1586201375761-83865001e31c",
      "semanticLabel":
          "White flour packet with Aashirvaad logo on clean background",
    },
    {
      "id": 7,
      "name": "Dabur Honey 500g",
      "category": "Health & Wellness",
      "stock": 34,
      "price": "₹120",
      "image":
          "https://images.unsplash.com/photo-1558642084-fd07fae5282e",
      "semanticLabel":
          "Golden honey jar with Dabur logo on wooden surface",
    },
    {
      "id": 8,
      "name": "Surf Excel 1kg",
      "category": "Household",
      "stock": 89,
      "price": "₹95",
      "image":
          "https://images.unsplash.com/photo-1581578731548-c6a0c3f2fcc0",
      "semanticLabel":
          "Blue detergent powder packet with Surf Excel logo on white background",
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
              Navigator.pushNamed(context, '/billing-screen');
              break;
            case 3:
              Navigator.pushNamed(context, '/analytics-dashboard-screen');
              break;
            case 4:
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
              iconName: 'point_of_sale',
              color: _currentIndex == 2
                  ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                  : Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
              size: 6.w,
            ),
            label: 'Billing',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'analytics',
              color: _currentIndex == 3
                  ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                  : Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
              size: 6.w,
            ),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentIndex == 4
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
