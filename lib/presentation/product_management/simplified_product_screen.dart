import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

class SimplifiedProductScreen extends StatefulWidget {
  const SimplifiedProductScreen({Key? key}) : super(key: key);

  @override
  State<SimplifiedProductScreen> createState() => _SimplifiedProductScreenState();
}

class _SimplifiedProductScreenState extends State<SimplifiedProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  List<Map<String, dynamic>> _products = [
    {
      'id': 1,
      'name': 'Tata Salt',
      'price': 20.0,
      'stock': 15,
      'category': 'Grocery',
      'isLowStock': true,
      'lastUpdated': '2 hours ago',
    },
    {
      'id': 2,
      'name': 'Maggi Noodles',
      'price': 12.0,
      'stock': 25,
      'category': 'Grocery',
      'isLowStock': false,
      'lastUpdated': '1 day ago',
    },
    {
      'id': 3,
      'name': 'Coca Cola',
      'price': 35.0,
      'stock': 5,
      'category': 'Beverages',
      'isLowStock': true,
      'lastUpdated': '3 hours ago',
    },
    {
      'id': 4,
      'name': 'Bread',
      'price': 25.0,
      'stock': 30,
      'category': 'Bakery',
      'isLowStock': false,
      'lastUpdated': '1 hour ago',
    },
  ];

  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Grocery', 'Beverages', 'Bakery', 'Snacks'];

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
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> filtered = _products;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((product) => product['category'] == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product['name'].toLowerCase().contains(_searchQuery) ||
               product['category'].toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  void _showAddProductDialog() {
    _nameController.clear();
    _priceController.clear();
    _stockController.clear();
    _categoryController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (₹) *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              DropdownButtonFormField<String>(
                value: _categories[1], // Default to 'Grocery'
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.skip(1).map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  _categoryController.text = value ?? '';
                },
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
            onPressed: _addProduct,
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  void _addProduct() {
    if (_nameController.text.isEmpty || 
        _priceController.text.isEmpty || 
        _stockController.text.isEmpty) {
      _showSnackBar('Please fill all required fields', isError: true);
      return;
    }

    setState(() {
      _products.add({
        'id': _products.length + 1,
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'category': _categoryController.text.isNotEmpty ? _categoryController.text : 'Grocery',
        'isLowStock': (int.tryParse(_stockController.text) ?? 0) < 10,
        'lastUpdated': 'Just now',
      });
    });

    Navigator.pop(context);
    _showSnackBar('Product added successfully');
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Price', '₹${product['price'].toStringAsFixed(0)}'),
            _buildDetailRow('Stock', '${product['stock']} units'),
            _buildDetailRow('Category', product['category']),
            _buildDetailRow('Status', product['isLowStock'] ? 'Low Stock' : 'In Stock'),
            _buildDetailRow('Last Updated', product['lastUpdated']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditProductDialog(product);
            },
            child: const Text('Edit'),
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

  void _showEditProductDialog(Map<String, dynamic> product) {
    _nameController.text = product['name'];
    _priceController.text = product['price'].toString();
    _stockController.text = product['stock'].toString();
    _categoryController.text = product['category'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${product['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (₹) *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              DropdownButtonFormField<String>(
                value: product['category'],
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.skip(1).map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  _categoryController.text = value ?? '';
                },
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
            onPressed: () {
              _updateProduct(product['id']);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _updateProduct(int productId) {
    setState(() {
      final productIndex = _products.indexWhere((p) => p['id'] == productId);
      if (productIndex != -1) {
        _products[productIndex] = {
          ..._products[productIndex],
          'name': _nameController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'stock': int.tryParse(_stockController.text) ?? 0,
          'category': _categoryController.text,
          'isLowStock': (int.tryParse(_stockController.text) ?? 0) < 10,
          'lastUpdated': 'Just now',
        };
      }
    });
    _showSnackBar('Product updated successfully');
  }

  void _deleteProduct(int productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _products.removeWhere((p) => p['id'] == productId);
              });
              Navigator.pop(context);
              _showSnackBar('Product deleted successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
        title: const Text('Products'),
        backgroundColor: AppTheme.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: EdgeInsets.all(4.w),
            color: AppTheme.primaryLight,
            child: Column(
              children: [
                TextField(
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
                ),
                SizedBox(height: 2.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: EdgeInsets.only(right: 2.w),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: Colors.white,
                          checkmarkColor: AppTheme.primaryLight,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_outlined,
                          size: 15.w,
                          color: AppTheme.textSecondaryLight,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No products found'
                              : 'No products yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          SizedBox(height: 2.h),
                          ElevatedButton.icon(
                            onPressed: _showAddProductDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Product'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(4.w),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 2.h),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: product['isLowStock'] 
                                ? AppTheme.warningLight 
                                : AppTheme.successLight,
                            child: Icon(
                              product['isLowStock'] ? Icons.warning : Icons.inventory,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            product['name'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('₹${product['price'].toStringAsFixed(0)} • ${product['stock']} units'),
                              Text(
                                product['category'],
                                style: TextStyle(
                                  color: AppTheme.textSecondaryLight,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Text('View Details'),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 'view':
                                  _showProductDetails(product);
                                  break;
                                case 'edit':
                                  _showEditProductDialog(product);
                                  break;
                                case 'delete':
                                  _deleteProduct(product['id']);
                                  break;
                              }
                            },
                          ),
                          onTap: () => _showProductDetails(product),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        backgroundColor: AppTheme.primaryLight,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}