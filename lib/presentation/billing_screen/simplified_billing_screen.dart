import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

class SimplifiedBillingScreen extends StatefulWidget {
  const SimplifiedBillingScreen({Key? key}) : super(key: key);

  @override
  State<SimplifiedBillingScreen> createState() => _SimplifiedBillingScreenState();
}

class _SimplifiedBillingScreenState extends State<SimplifiedBillingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();

  List<Map<String, dynamic>> _cartItems = [];
  double _totalAmount = 0.0;
  double _discountAmount = 0.0;
  double _gstAmount = 0.0;
  String _selectedPaymentMethod = 'Cash';

  // Simplified product list
  final List<Map<String, dynamic>> _products = [
    {'id': 1, 'name': 'Tata Salt', 'price': 20.0, 'stock': 50},
    {'id': 2, 'name': 'Maggi Noodles', 'price': 12.0, 'stock': 30},
    {'id': 3, 'name': 'Coca Cola', 'price': 35.0, 'stock': 25},
    {'id': 4, 'name': 'Bread', 'price': 25.0, 'stock': 15},
    {'id': 5, 'name': 'Milk 1L', 'price': 60.0, 'stock': 20},
    {'id': 6, 'name': 'Rice 1kg', 'price': 80.0, 'stock': 40},
    {'id': 7, 'name': 'Oil 1L', 'price': 120.0, 'stock': 10},
    {'id': 8, 'name': 'Sugar 1kg', 'price': 45.0, 'stock': 35},
  ];

  @override
  void initState() {
    super.initState();
    _quantityController.text = '1';
    _calculateTotal();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item['id'] == product['id'],
      );

      if (existingItemIndex != -1) {
        _cartItems[existingItemIndex]['quantity'] += 1;
      } else {
        _cartItems.add({
          ...product,
          'quantity': 1,
        });
      }
      _calculateTotal();
    });
  }

  void _removeFromCart(int productId) {
    setState(() {
      _cartItems.removeWhere((item) => item['id'] == productId);
      _calculateTotal();
    });
  }

  void _updateQuantity(int productId, int quantity) {
    setState(() {
      final itemIndex = _cartItems.indexWhere((item) => item['id'] == productId);
      if (itemIndex != -1) {
        if (quantity <= 0) {
          _cartItems.removeAt(itemIndex);
        } else {
          _cartItems[itemIndex]['quantity'] = quantity;
        }
        _calculateTotal();
      }
    });
  }

  void _calculateTotal() {
    double subtotal = 0.0;
    for (var item in _cartItems) {
      subtotal += item['price'] * item['quantity'];
    }
    
    _gstAmount = subtotal * 0.18; // 18% GST
    _totalAmount = subtotal + _gstAmount - _discountAmount;
    
    setState(() {});
  }

  void _processPayment() {
    if (_cartItems.isEmpty) {
      _showSnackBar('Cart is empty', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items: ${_cartItems.length}'),
            Text('Subtotal: ₹${(_totalAmount - _gstAmount + _discountAmount).toStringAsFixed(2)}'),
            Text('GST (18%): ₹${_gstAmount.toStringAsFixed(2)}'),
            if (_discountAmount > 0) Text('Discount: -₹${_discountAmount.toStringAsFixed(2)}'),
            const Divider(),
            Text('Total: ₹${_totalAmount.toStringAsFixed(2)}', 
                 style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Payment: $_selectedPaymentMethod'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog();
            },
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successLight, size: 32),
            SizedBox(width: 2.w),
            const Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Amount: ₹${_totalAmount.toStringAsFixed(2)}'),
            Text('Payment Method: $_selectedPaymentMethod'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _clearCart();
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Print Bill'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _clearCart();
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _totalAmount = 0.0;
      _discountAmount = 0.0;
      _gstAmount = 0.0;
    });
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
        title: const Text('Billing'),
        backgroundColor: AppTheme.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar - Simplified
          Container(
            padding: EdgeInsets.all(4.w),
            color: AppTheme.primaryLight,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          Expanded(
            child: Row(
              children: [
                // Products List - Simplified
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Products',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              final isInCart = _cartItems.any((item) => item['id'] == product['id']);
                              
                              return Card(
                                elevation: 2,
                                child: InkWell(
                                  onTap: () => _addToCart(product),
                                  child: Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inventory,
                                          size: 8.w,
                                          color: isInCart ? AppTheme.primaryLight : AppTheme.textSecondaryLight,
                                        ),
                                        SizedBox(height: 1.h),
                                        Text(
                                          product['name'],
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          '₹${product['price'].toStringAsFixed(0)}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppTheme.primaryLight,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Stock: ${product['stock']}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppTheme.textSecondaryLight,
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
                    ),
                  ),
                ),

                // Cart - Simplified
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(-2, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cart (${_cartItems.length})',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        
                        Expanded(
                          child: _cartItems.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 15.w,
                                        color: AppTheme.textSecondaryLight,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Cart is empty',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: AppTheme.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _cartItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _cartItems[index];
                                    return Card(
                                      margin: EdgeInsets.only(bottom: 2.h),
                                      child: Padding(
                                        padding: EdgeInsets.all(3.w),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'],
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                            SizedBox(height: 1.h),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('₹${item['price'].toStringAsFixed(0)}'),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () => _updateQuantity(
                                                        item['id'],
                                                        item['quantity'] - 1,
                                                      ),
                                                      icon: const Icon(Icons.remove, size: 16),
                                                      constraints: const BoxConstraints(
                                                        minWidth: 32,
                                                        minHeight: 32,
                                                      ),
                                                    ),
                                                    Text('${item['quantity']}'),
                                                    IconButton(
                                                      onPressed: () => _updateQuantity(
                                                        item['id'],
                                                        item['quantity'] + 1,
                                                      ),
                                                      icon: const Icon(Icons.add, size: 16),
                                                      constraints: const BoxConstraints(
                                                        minWidth: 32,
                                                        minHeight: 32,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),

                        // Payment Summary - Simplified
                        if (_cartItems.isNotEmpty) ...[
                          const Divider(),
                          Text(
                            'Payment Summary',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:'),
                              Text('₹${(_totalAmount - _gstAmount + _discountAmount).toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('GST (18%):'),
                              Text('₹${_gstAmount.toStringAsFixed(2)}'),
                            ],
                          ),
                          if (_discountAmount > 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Discount:'),
                                Text('-₹${_discountAmount.toStringAsFixed(2)}'),
                              ],
                            ),
                          const Divider(),
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
                                '₹${_totalAmount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),

                          // Payment Method - Simplified
                          DropdownButtonFormField<String>(
                            value: _selectedPaymentMethod,
                            decoration: const InputDecoration(
                              labelText: 'Payment Method',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                              DropdownMenuItem(value: 'Card', child: Text('Card')),
                              DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                              DropdownMenuItem(value: 'Credit', child: Text('Credit')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                          ),
                          SizedBox(height: 2.h),

                          // Process Payment Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _processPayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryLight,
                                padding: EdgeInsets.symmetric(vertical: 3.h),
                              ),
                              child: const Text(
                                'Process Payment',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}