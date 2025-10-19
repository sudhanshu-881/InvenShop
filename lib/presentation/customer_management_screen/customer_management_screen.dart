import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({Key? key}) : super(key: key);

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _creditLimitController = TextEditingController();

  late TabController _tabController;
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  String _selectedFilter = 'All';
  double _totalCreditDues = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _creditLimitController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadCustomers() {
    // Mock customer data
    _customers = [
      {
        "id": 1,
        "name": "Amit Kumar",
        "phone": "9876543210",
        "address": "123, Sector 5, Noida",
        "creditLimit": 5000.0,
        "currentDue": 1200.0,
        "lastPurchase": DateTime.now().subtract(Duration(days: 2)),
        "totalPurchases": 15000.0,
        "isActive": true,
        "image": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d",
      },
      {
        "id": 2,
        "name": "Priya Sharma",
        "phone": "9876543211",
        "address": "456, Model Town, Delhi",
        "creditLimit": 3000.0,
        "currentDue": 0.0,
        "lastPurchase": DateTime.now().subtract(Duration(days: 5)),
        "totalPurchases": 8500.0,
        "isActive": true,
        "image": "https://images.unsplash.com/photo-1494790108755-2616b612b786",
      },
      {
        "id": 3,
        "name": "Rajesh Singh",
        "phone": "9876543212",
        "address": "789, Lajpat Nagar, Delhi",
        "creditLimit": 10000.0,
        "currentDue": 3500.0,
        "lastPurchase": DateTime.now().subtract(Duration(days: 1)),
        "totalPurchases": 25000.0,
        "isActive": true,
        "image": "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e",
      },
      {
        "id": 4,
        "name": "Sunita Devi",
        "phone": "9876543213",
        "address": "321, Karol Bagh, Delhi",
        "creditLimit": 2000.0,
        "currentDue": 800.0,
        "lastPurchase": DateTime.now().subtract(Duration(days: 7)),
        "totalPurchases": 12000.0,
        "isActive": false,
        "image": "https://images.unsplash.com/photo-1438761681033-6461ffad8d80",
      },
    ];

    _filteredCustomers = List.from(_customers);
    _calculateTotalCreditDues();
  }

  void _calculateTotalCreditDues() {
    _totalCreditDues = _customers.fold(0.0, (sum, customer) => sum + customer['currentDue']);
  }

  void _filterCustomers() {
    List<Map<String, dynamic>> filtered = List.from(_customers);

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((customer) =>
          customer['name'].toLowerCase().contains(query) ||
          customer['phone'].contains(query)).toList();
    }

    // Filter by status
    switch (_selectedFilter) {
      case 'With Dues':
        filtered = filtered.where((customer) => customer['currentDue'] > 0).toList();
        break;
      case 'No Dues':
        filtered = filtered.where((customer) => customer['currentDue'] == 0).toList();
        break;
      case 'Inactive':
        filtered = filtered.where((customer) => !customer['isActive']).toList();
        break;
    }

    setState(() {
      _filteredCustomers = filtered;
    });
  }

  void _addCustomer() {
    showDialog(
      context: context,
      builder: (context) => _buildAddCustomerDialog(),
    );
  }

  Widget _buildAddCustomerDialog() {
    return AlertDialog(
      title: Text('Add New Customer'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _creditLimitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Credit Limit (₹)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _clearForm();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveCustomer,
          child: Text('Add Customer'),
        ),
      ],
    );
  }

  void _saveCustomer() {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      _showErrorSnackBar('Please fill required fields');
      return;
    }

    final newCustomer = {
      "id": DateTime.now().millisecondsSinceEpoch,
      "name": _nameController.text,
      "phone": _phoneController.text,
      "address": _addressController.text,
      "creditLimit": double.tryParse(_creditLimitController.text) ?? 0.0,
      "currentDue": 0.0,
      "lastPurchase": null,
      "totalPurchases": 0.0,
      "isActive": true,
      "image": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d",
    };

    setState(() {
      _customers.add(newCustomer);
    });

    _clearForm();
    _filterCustomers();
    Navigator.pop(context);
    _showSuccessSnackBar('Customer added successfully');
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _creditLimitController.clear();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Management'),
        actions: [
          IconButton(
            onPressed: _addCustomer,
            icon: CustomIconWidget(
              iconName: 'person_add',
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              size: 24,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'people',
                size: 20,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
              text: 'All Customers',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'account_balance_wallet',
                size: 20,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
              text: 'Credit Dues',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'analytics',
                size: 20,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
              text: 'Analytics',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                ),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _filterCustomers(),
                  decoration: InputDecoration(
                    hintText: 'Search customers...',
                    prefixIcon: CustomIconWidget(
                      iconName: 'search',
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text('Filter: '),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        isExpanded: true,
                        items: ['All', 'With Dues', 'No Dues', 'Inactive'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFilter = newValue!;
                          });
                          _filterCustomers();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllCustomersView(),
                _buildCreditDuesView(),
                _buildAnalyticsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCustomersView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_filteredCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'people',
              size: 80,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
            SizedBox(height: 2.h),
            Text(
              'No customers found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Add your first customer to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = _filteredCustomers[index];
        return Card(
          margin: EdgeInsets.only(bottom: 2.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(customer['image']),
            ),
            title: Text(customer['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer['phone']),
                Text(customer['address']),
                if (customer['currentDue'] > 0)
                  Text(
                    'Due: ₹${customer['currentDue'].toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppTheme.errorLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'visibility',
                        size: 16,
                        color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                      ),
                      SizedBox(width: 2.w),
                      Text('View Details'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'edit',
                        size: 16,
                        color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                      ),
                      SizedBox(width: 2.w),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'payment',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'payment',
                        size: 16,
                        color: AppTheme.primaryLight,
                      ),
                      SizedBox(width: 2.w),
                      Text('Record Payment'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _showCustomerDetails(customer);
                    break;
                  case 'edit':
                    _editCustomer(customer);
                    break;
                  case 'payment':
                    _recordPayment(customer);
                    break;
                }
              },
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildCreditDuesView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customersWithDues = _customers.where((c) => c['currentDue'] > 0).toList();

    return Column(
      children: [
        // Summary card
        Container(
          margin: EdgeInsets.all(4.w),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.errorLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.errorLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Credit Dues',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${_totalCreditDues.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.errorLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${customersWithDues.length} customers',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              CustomIconWidget(
                iconName: 'account_balance_wallet',
                size: 48,
                color: AppTheme.errorLight,
              ),
            ],
          ),
        ),

        // Customers with dues
        Expanded(
          child: customersWithDues.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'check_circle',
                        size: 80,
                        color: AppTheme.successLight,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No Credit Dues',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.successLight,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'All customers have cleared their dues',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: customersWithDues.length,
                  itemBuilder: (context, index) {
                    final customer = customersWithDues[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 2.h),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(customer['image']),
                        ),
                        title: Text(customer['name']),
                        subtitle: Text(customer['phone']),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${customer['currentDue'].toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppTheme.errorLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Due',
                              style: TextStyle(
                                color: AppTheme.errorLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _recordPayment(customer),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalCustomers = _customers.length;
    final activeCustomers = _customers.where((c) => c['isActive']).length;
    final totalPurchases = _customers.fold(0.0, (sum, c) => sum + c['totalPurchases']);

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Customers',
                  totalCustomers.toString(),
                  'people',
                  AppTheme.primaryLight,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildAnalyticsCard(
                  'Active Customers',
                  activeCustomers.toString(),
                  'person',
                  AppTheme.successLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Sales',
                  '₹${totalPurchases.toStringAsFixed(0)}',
                  'attach_money',
                  AppTheme.secondaryLight,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildAnalyticsCard(
                  'Credit Dues',
                  '₹${_totalCreditDues.toStringAsFixed(0)}',
                  'account_balance_wallet',
                  AppTheme.errorLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Top customers
          Text(
            'Top Customers by Sales',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          ..._customers
              .where((c) => c['totalPurchases'] > 0)
              .toList()
              ..sort((a, b) => b['totalPurchases'].compareTo(a['totalPurchases']))
              .take(5)
              .map((customer) => Card(
                    margin: EdgeInsets.only(bottom: 1.h),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(customer['image']),
                      ),
                      title: Text(customer['name']),
                      subtitle: Text(customer['phone']),
                      trailing: Text(
                        '₹${customer['totalPurchases'].toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ),
                  )),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, String iconName, Color color) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            size: 32,
            color: color,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Customer Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(customer['image']),
                ),
              ),
              SizedBox(height: 2.h),
              Text('Name: ${customer['name']}'),
              Text('Phone: ${customer['phone']}'),
              Text('Address: ${customer['address']}'),
              Text('Credit Limit: ₹${customer['creditLimit'].toStringAsFixed(2)}'),
              Text('Current Due: ₹${customer['currentDue'].toStringAsFixed(2)}'),
              Text('Total Purchases: ₹${customer['totalPurchases'].toStringAsFixed(2)}'),
              if (customer['lastPurchase'] != null)
                Text('Last Purchase: ${DateFormat('dd/MM/yyyy').format(customer['lastPurchase'])}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editCustomer(Map<String, dynamic> customer) {
    _nameController.text = customer['name'];
    _phoneController.text = customer['phone'];
    _addressController.text = customer['address'];
    _creditLimitController.text = customer['creditLimit'].toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _creditLimitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Credit Limit (₹)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearForm();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update customer logic
              Navigator.pop(context);
              _clearForm();
              _showSuccessSnackBar('Customer updated successfully');
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _recordPayment(Map<String, dynamic> customer) {
    final TextEditingController paymentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Customer: ${customer['name']}'),
            Text('Current Due: ₹${customer['currentDue'].toStringAsFixed(2)}'),
            SizedBox(height: 2.h),
            TextField(
              controller: paymentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Payment Amount (₹)',
                border: OutlineInputBorder(),
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
              final paymentAmount = double.tryParse(paymentController.text) ?? 0;
              if (paymentAmount > 0) {
                setState(() {
                  customer['currentDue'] = (customer['currentDue'] - paymentAmount).clamp(0.0, double.infinity);
                });
                _calculateTotalCreditDues();
                _filterCustomers();
                Navigator.pop(context);
                _showSuccessSnackBar('Payment recorded successfully');
              }
            },
            child: Text('Record Payment'),
          ),
        ],
      ),
    );
  }
}