import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

class SimplifiedCustomerScreen extends StatefulWidget {
  const SimplifiedCustomerScreen({Key? key}) : super(key: key);

  @override
  State<SimplifiedCustomerScreen> createState() => _SimplifiedCustomerScreenState();
}

class _SimplifiedCustomerScreenState extends State<SimplifiedCustomerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _creditLimitController = TextEditingController();

  List<Map<String, dynamic>> _customers = [
    {
      'id': 1,
      'name': 'Rajesh Kumar',
      'phone': '9876543210',
      'address': '123 Main Street, Delhi',
      'creditLimit': 5000.0,
      'currentDue': 1200.0,
      'isActive': true,
    },
    {
      'id': 2,
      'name': 'Priya Sharma',
      'phone': '9876543211',
      'address': '456 Park Avenue, Mumbai',
      'creditLimit': 3000.0,
      'currentDue': 0.0,
      'isActive': true,
    },
    {
      'id': 3,
      'name': 'Ahmed Khan',
      'phone': '9876543212',
      'address': '789 Market Road, Bangalore',
      'creditLimit': 2000.0,
      'currentDue': 800.0,
      'isActive': true,
    },
  ];

  String _selectedTab = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCustomers {
    List<Map<String, dynamic>> filtered = _customers;

    // Filter by tab
    if (_selectedTab == 'Credit Dues') {
      filtered = filtered.where((customer) => customer['currentDue'] > 0).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((customer) {
        return customer['name'].toLowerCase().contains(_searchQuery) ||
               customer['phone'].contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  void _showAddCustomerDialog() {
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _creditLimitController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _creditLimitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Credit Limit (₹)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addCustomer,
            child: const Text('Add Customer'),
          ),
        ],
      ),
    );
  }

  void _addCustomer() {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      _showSnackBar('Name and phone are required', isError: true);
      return;
    }

    setState(() {
      _customers.add({
        'id': _customers.length + 1,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'creditLimit': double.tryParse(_creditLimitController.text) ?? 0.0,
        'currentDue': 0.0,
        'isActive': true,
      });
    });

    Navigator.pop(context);
    _showSnackBar('Customer added successfully');
  }

  void _showCustomerDetails(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Phone', customer['phone']),
            _buildDetailRow('Address', customer['address']),
            _buildDetailRow('Credit Limit', '₹${customer['creditLimit'].toStringAsFixed(0)}'),
            _buildDetailRow('Current Due', '₹${customer['currentDue'].toStringAsFixed(0)}'),
            _buildDetailRow('Status', customer['isActive'] ? 'Active' : 'Inactive'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (customer['currentDue'] > 0)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showPaymentDialog(customer);
              },
              child: const Text('Record Payment'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(Map<String, dynamic> customer) {
    final TextEditingController paymentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Payment - ${customer['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Due: ₹${customer['currentDue'].toStringAsFixed(0)}'),
            SizedBox(height: 2.h),
            TextField(
              controller: paymentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Payment Amount (₹)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final paymentAmount = double.tryParse(paymentController.text) ?? 0.0;
              if (paymentAmount > 0) {
                _recordPayment(customer['id'], paymentAmount);
                Navigator.pop(context);
              }
            },
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }

  void _recordPayment(int customerId, double amount) {
    setState(() {
      final customerIndex = _customers.indexWhere((c) => c['id'] == customerId);
      if (customerIndex != -1) {
        _customers[customerIndex]['currentDue'] = 
            (_customers[customerIndex]['currentDue'] - amount).clamp(0.0, double.infinity);
      }
    });
    _showSnackBar('Payment recorded successfully');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorLight : AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: AppTheme.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(4.w),
            color: AppTheme.primaryLight,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Tab Bar - Simplified
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildTab('All', _customers.length),
                ),
                Expanded(
                  child: _buildTab('Credit Dues', _customers.where((c) => c['currentDue'] > 0).length),
                ),
              ],
            ),
          ),

          // Customer List
          Expanded(
            child: _filteredCustomers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 15.w,
                          color: AppTheme.textSecondaryLight,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No customers found'
                              : 'No customers yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          SizedBox(height: 2.h),
                          ElevatedButton.icon(
                            onPressed: _showAddCustomerDialog,
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add First Customer'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(4.w),
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 2.h),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryLight,
                            child: Text(
                              customer['name'][0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            customer['name'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(customer['phone']),
                              if (customer['currentDue'] > 0)
                                Text(
                                  'Due: ₹${customer['currentDue'].toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: AppTheme.errorLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                          trailing: customer['currentDue'] > 0
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorLight.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    'Due',
                                    style: TextStyle(
                                      color: AppTheme.errorLight,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.check_circle,
                                  color: AppTheme.successLight,
                                  size: 20,
                                ),
                          onTap: () => _showCustomerDetails(customer),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        backgroundColor: AppTheme.primaryLight,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildTab(String title, int count) {
    final isSelected = _selectedTab == title;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppTheme.primaryLight : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryLight : AppTheme.textSecondaryLight,
              ),
            ),
            SizedBox(height: 0.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryLight : AppTheme.textSecondaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}