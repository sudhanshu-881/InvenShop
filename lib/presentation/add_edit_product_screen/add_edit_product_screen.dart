import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/barcode_scanner_widget.dart';
import './widgets/product_form_fields.dart';
import './widgets/product_image_section.dart';
import './widgets/stock_management_section.dart';

class AddEditProductScreen extends StatefulWidget {
  final Map<String, dynamic>? productData;

  const AddEditProductScreen({
    Key? key,
    this.productData,
  }) : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _skuController;
  late TextEditingController _supplierController;

  // Form state
  List<XFile> _productImages = [];
  int? _primaryImageIndex;
  String? _selectedCategory;
  String? _selectedUnitType = 'Pieces';
  int _currentQuantity = 0;
  int _minimumStock = 5;
  DateTime? _expirationDate;
  bool _isMarketplaceVisible = true;
  bool _showBarcodeScanner = false;
  bool _isEditing = false;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  // Auto-save timer
  DateTime _lastAutoSave = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadProductData();
    _startAutoSaveTimer();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _skuController.dispose();
    _supplierController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _brandController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _skuController = TextEditingController();
    _supplierController = TextEditingController();

    // Add listeners to track changes
    _nameController.addListener(_onFormChanged);
    _brandController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
    _priceController.addListener(_onFormChanged);
    _skuController.addListener(_onFormChanged);
    _supplierController.addListener(_onFormChanged);
  }

  void _loadProductData() {
    if (widget.productData != null) {
      setState(() {
        _isEditing = true;
        final data = widget.productData!;

        _nameController.text = data['name'] ?? '';
        _brandController.text = data['brand'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _priceController.text = data['price']?.toString() ?? '';
        _skuController.text = data['sku'] ?? '';
        _supplierController.text = data['supplier'] ?? '';
        _selectedCategory = data['category'];
        _selectedUnitType = data['unitType'] ?? 'Pieces';
        _currentQuantity = data['quantity'] ?? 0;
        _minimumStock = data['minimumStock'] ?? 5;
        _isMarketplaceVisible = data['isMarketplaceVisible'] ?? true;

        if (data['expirationDate'] != null) {
          _expirationDate = DateTime.parse(data['expirationDate']);
        }
      });
    }
  }

  void _onFormChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _startAutoSaveTimer() {
    // Auto-save every 30 seconds
    Future.delayed(Duration(seconds: 30), () {
      if (mounted && _hasUnsavedChanges) {
        _autoSaveDraft();
        _startAutoSaveTimer();
      }
    });
  }

  void _autoSaveDraft() {
    if (_nameController.text.trim().isNotEmpty) {
      _lastAutoSave = DateTime.now();
      // In a real app, save to local storage
      debugPrint('Auto-saved draft at ${_lastAutoSave}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _showBarcodeScanner
          ? _buildBarcodeScannerView()
          : _buildMainContent(),
      bottomNavigationBar: _showBarcodeScanner ? null : _buildBottomActions(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
      leading: IconButton(
        onPressed: _onBackPressed,
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      actions: [
        if (!_showBarcodeScanner)
          IconButton(
            onPressed: () {
              setState(() {
                _showBarcodeScanner = true;
              });
            },
            icon: CustomIconWidget(
              iconName: 'qr_code_scanner',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            tooltip: 'Scan Barcode',
          ),
        if (_hasUnsavedChanges && !_showBarcodeScanner)
          TextButton(
            onPressed: _isSaving ? null : _saveProduct,
            child: Text(
              'Save',
              style: TextStyle(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBarcodeScannerView() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Expanded(
            child: BarcodeScannerWidget(
              onBarcodeScanned: _onBarcodeScanned,
              onClose: () {
                setState(() {
                  _showBarcodeScanner = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImageSection(
            images: _productImages,
            onImagesChanged: (images) {
              setState(() {
                _productImages = images;
                _hasUnsavedChanges = true;
              });
            },
            primaryImageIndex: _primaryImageIndex,
            onPrimaryImageChanged: (index) {
              setState(() {
                _primaryImageIndex = index >= 0 ? index : null;
                _hasUnsavedChanges = true;
              });
            },
          ),
          SizedBox(height: 3.h),
          ProductFormFields(
            nameController: _nameController,
            brandController: _brandController,
            descriptionController: _descriptionController,
            priceController: _priceController,
            skuController: _skuController,
            supplierController: _supplierController,
            selectedCategory: _selectedCategory,
            selectedUnitType: _selectedUnitType,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
                _hasUnsavedChanges = true;
              });
            },
            onUnitTypeChanged: (unitType) {
              setState(() {
                _selectedUnitType = unitType;
                _hasUnsavedChanges = true;
              });
            },
            formKey: _formKey,
          ),
          SizedBox(height: 3.h),
          StockManagementSection(
            currentQuantity: _currentQuantity,
            minimumStock: _minimumStock,
            expirationDate: _expirationDate,
            isMarketplaceVisible: _isMarketplaceVisible,
            onQuantityChanged: (quantity) {
              setState(() {
                _currentQuantity = quantity;
                _hasUnsavedChanges = true;
              });
            },
            onMinimumStockChanged: (minStock) {
              setState(() {
                _minimumStock = minStock;
                _hasUnsavedChanges = true;
              });
            },
            onExpirationDateChanged: (date) {
              setState(() {
                _expirationDate = date;
                _hasUnsavedChanges = true;
              });
            },
            onMarketplaceVisibilityChanged: (visible) {
              setState(() {
                _isMarketplaceVisible = visible;
                _hasUnsavedChanges = true;
              });
            },
          ),
          SizedBox(height: 10.h), // Space for bottom actions
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_hasUnsavedChanges)
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'You have unsaved changes',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      'Auto-saved ${_getTimeSinceAutoSave()}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _onBackPressed,
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed:
                        _isSaving || !_isFormValid() ? null : _saveProduct,
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(_isEditing ? 'Update Product' : 'Save Product'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onBarcodeScanned(String barcode) {
    setState(() {
      _showBarcodeScanner = false;
      _skuController.text = barcode;
      _hasUnsavedChanges = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Barcode scanned: $barcode'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  bool _isFormValid() {
    return _nameController.text.trim().isNotEmpty &&
        _selectedCategory != null &&
        _priceController.text.trim().isNotEmpty &&
        double.tryParse(_priceController.text) != null;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      final productData = {
        'id': _isEditing
            ? widget.productData!['id']
            : DateTime.now().millisecondsSinceEpoch,
        'name': _nameController.text.trim(),
        'brand': _brandController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'sku': _skuController.text.trim(),
        'supplier': _supplierController.text.trim(),
        'category': _selectedCategory,
        'unitType': _selectedUnitType,
        'quantity': _currentQuantity,
        'minimumStock': _minimumStock,
        'expirationDate': _expirationDate?.toIso8601String(),
        'isMarketplaceVisible': _isMarketplaceVisible,
        'images': _productImages.map((image) => image.path).toList(),
        'primaryImageIndex': _primaryImageIndex,
        'createdAt': _isEditing
            ? widget.productData!['createdAt']
            : DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      setState(() {
        _hasUnsavedChanges = false;
        _isSaving = false;
      });

      _showSuccessDialog(productData);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save product. Please try again.'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  void _showSuccessDialog(Map<String, dynamic> productData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: CustomIconWidget(
          iconName: 'check_circle',
          color: AppTheme.lightTheme.colorScheme.tertiary,
          size: 48,
        ),
        title: Text(
          _isEditing ? 'Product Updated!' : 'Product Added!',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isEditing
                  ? 'Your product has been successfully updated.'
                  : 'Your product has been successfully added to inventory.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productData['name'],
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'SKU: ${productData['sku']}',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                  Text(
                    'Price: \$${productData['price'].toStringAsFixed(2)}',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetForm();
              },
              child: Text('Add Another'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/inventory-dashboard');
            },
            child: Text(_isEditing ? 'View Inventory' : 'View in Inventory'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _brandController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _skuController.clear();
      _supplierController.clear();
      _productImages.clear();
      _primaryImageIndex = null;
      _selectedCategory = null;
      _selectedUnitType = 'Pieces';
      _currentQuantity = 0;
      _minimumStock = 5;
      _expirationDate = null;
      _isMarketplaceVisible = true;
      _hasUnsavedChanges = false;
    });
  }

  Future<void> _onBackPressed() async {
    if (_hasUnsavedChanges) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Discard Changes?'),
          content: Text(
              'You have unsaved changes. Are you sure you want to go back?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Discard',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      );

      if (shouldDiscard == true) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  String _getTimeSinceAutoSave() {
    final difference = DateTime.now().difference(_lastAutoSave);
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inSeconds}s ago';
    }
  }
}
