import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({Key? key}) : super(key: key);

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();

  late TabController _tabController;
  
  List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> _recentProducts = [];
  String _selectedPaymentMethod = 'Cash';
  double _totalAmount = 0.0;
  double _discountAmount = 0.0;
  double _gstAmount = 0.0;
  double _finalAmount = 0.0;
  bool _isGstEnabled = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecentProducts();
    _quantityController.text = '1';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _discountController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadRecentProducts() {
    // Mock recent products data
    _recentProducts = [
      {
        "id": 1,
        "name": "Tata Salt 1kg",
        "price": 25.0,
        "category": "Groceries",
        "stock": 45,
        "image": "https://images.unsplash.com/photo-1586201375761-83865001e31c",
      },
      {
        "id": 2,
        "name": "Maggi Noodles",
        "price": 14.0,
        "category": "Food & Beverages",
        "stock": 28,
        "image": "https://images.unsplash.com/photo-1569718212165-3a8278d5f624",
      },
      {
        "id": 3,
        "name": "Parle-G Biscuits",
        "price": 5.0,
        "category": "Snacks",
        "stock": 12,
        "image": "https://images.unsplash.com/photo-1558961363-fa8fdf82db35",
      },
      {
        "id": 4,
        "name": "Coca Cola 600ml",
        "price": 35.0,
        "category": "Beverages",
        "stock": 3,
        "image": "https://images.unsplash.com/photo-1581636625402-29b2a704ef6f",
      },
    ];
  }

  void _addToCart(Map<String, dynamic> product) {
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    
    // Check if product already exists in cart
    final existingIndex = _cartItems.indexWhere((item) => item['id'] == product['id']);
    
    if (existingIndex != -1) {
      setState(() {
        _cartItems[existingIndex]['quantity'] += quantity;
      });
    } else {
      setState(() {
        _cartItems.add({
          ...product,
          'quantity': quantity,
          'total': product['price'] * quantity,
        });
      });
    }
    
    _quantityController.text = '1';
    _calculateTotal();
    _showSuccessSnackBar('${product['name']} added to cart');
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
    _calculateTotal();
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(index);
      return;
    }
    
    setState(() {
      _cartItems[index]['quantity'] = newQuantity;
      _cartItems[index]['total'] = _cartItems[index]['price'] * newQuantity;
    });
    _calculateTotal();
  }

  void _calculateTotal() {
    _totalAmount = _cartItems.fold(0.0, (sum, item) => sum + item['total']);
    _discountAmount = double.tryParse(_discountController.text) ?? 0.0;
    
    if (_isGstEnabled) {
      _gstAmount = (_totalAmount - _discountAmount) * 0.18; // 18% GST
    } else {
      _gstAmount = 0.0;
    }
    
    _finalAmount = _totalAmount - _discountAmount + _gstAmount;
    
    setState(() {});
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _discountController.clear();
      _customerNameController.clear();
      _customerPhoneController.clear();
    });
    _calculateTotal();
  }

  void _processPayment() {
    if (_cartItems.isEmpty) {
      _showErrorSnackBar('Cart is empty');
      return;
    }

    // Generate bill
    final billData = {
      'items': _cartItems,
      'totalAmount': _totalAmount,
      'discountAmount': _discountAmount,
      'gstAmount': _gstAmount,
      'finalAmount': _finalAmount,
      'paymentMethod': _selectedPaymentMethod,
      'customerName': _customerNameController.text,
      'customerPhone': _customerPhoneController.text,
      'timestamp': DateTime.now(),
    };

    _showBillDialog(billData);
  }

  void _showBillDialog(Map<String, dynamic> billData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'receipt',
              color: AppTheme.primaryLight,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Bill Generated'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rajesh Kumar General Store',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Mobile: +91 9876543210'),
              Text('GST: 27ABCDE1234F1Z5'),
              Divider(),
              
              // Bill items
              ...billData['items'].map<Widget>((item) => Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${item['name']} x${item['quantity']}'),
                    ),
                    Text('₹${item['total'].toStringAsFixed(2)}'),
                  ],
                ),
              )),
              
              Divider(),
              
              // Bill summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal:'),
                  Text('₹${billData['totalAmount'].toStringAsFixed(2)}'),
                ],
              ),
              if (billData['discountAmount'] > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Discount:'),
                    Text('-₹${billData['discountAmount'].toStringAsFixed(2)}'),
                  ],
                ),
              ],
              if (_isGstEnabled) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('GST (18%):'),
                    Text('₹${billData['gstAmount'].toStringAsFixed(2)}'),
                  ],
                ),
              ],
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${billData['finalAmount'].toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 2.h),
              Text('Payment Method: ${billData['paymentMethod']}'),
              Text('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(billData['timestamp'])}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCart();
            },
            child: Text('Print & Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCart();
              _showSuccessSnackBar('Payment processed successfully');
            },
            child: Text('Share via WhatsApp'),
          ),
        ],
      ),
    );
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
        title: Text('Billing & POS'),
        actions: [
          IconButton(
            onPressed: _clearCart,
            icon: CustomIconWidget(
              iconName: 'clear_all',
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
                iconName: 'shopping_cart',
                size: 20,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
              text: 'Cart (${_cartItems.length})',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'inventory_2',
                size: 20,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
              text: 'Products',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCartView(),
                _buildProductsView(),
              ],
            ),
          ),
          _buildBottomSummary(),
        ],
      ),
    );
  }

  Widget _buildCartView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'shopping_cart',
              size: 80,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
            SizedBox(height: 2.h),
            Text(
              'Cart is Empty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Add products to start billing',
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
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return Card(
          margin: EdgeInsets.only(bottom: 2.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(item['image']),
            ),
            title: Text(item['name']),
            subtitle: Text('₹${item['price']} each'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _updateQuantity(index, item['quantity'] - 1),
                  icon: CustomIconWidget(
                    iconName: 'remove_circle',
                    color: AppTheme.errorLight,
                    size: 20,
                  ),
                ),
                Text(
                  '${item['quantity']}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => _updateQuantity(index, item['quantity'] + 1),
                  icon: CustomIconWidget(
                    iconName: 'add_circle',
                    color: AppTheme.successLight,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: () => _removeFromCart(index),
                  icon: CustomIconWidget(
                    iconName: 'delete',
                    color: AppTheme.errorLight,
                    size: 20,
                  ),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildProductsView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.all(4.w),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: CustomIconWidget(
                iconName: 'search',
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                size: 20,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  // Open barcode scanner
                },
                icon: CustomIconWidget(
                  iconName: 'qr_code_scanner',
                  color: AppTheme.primaryLight,
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        // Quantity input
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Text('Quantity: '),
              SizedBox(
                width: 20.w,
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Products grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(4.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 2.h,
            ),
            itemCount: _recentProducts.length,
            itemBuilder: (context, index) {
              final product = _recentProducts[index];
              return Card(
                child: InkWell(
                  onTap: () => _addToCart(product),
                  child: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(product['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          product['name'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '₹${product['price']}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Stock: ${product['stock']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSummary() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Customer details
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customerNameController,
                  decoration: InputDecoration(
                    labelText: 'Customer Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: TextField(
                  controller: _customerPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Discount and GST
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _calculateTotal(),
                  decoration: InputDecoration(
                    labelText: 'Discount (₹)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Row(
                  children: [
                    Text('GST: '),
                    Switch(
                      value: _isGstEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isGstEnabled = value;
                        });
                        _calculateTotal();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Payment method
          Row(
            children: [
              Text('Payment: '),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedPaymentMethod,
                  isExpanded: true,
                  items: ['Cash', 'Card', 'UPI', 'Credit'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPaymentMethod = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Total and pay button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total: ₹${_finalAmount.toStringAsFixed(2)}'),
                  if (_isGstEnabled)
                    Text(
                      'Incl. GST',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                      ),
                    ),
                ],
              ),
              ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                ),
                child: Text(
                  'Pay ₹${_finalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}