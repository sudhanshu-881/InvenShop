import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProductFormFields extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController brandController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController skuController;
  final TextEditingController supplierController;
  final String? selectedCategory;
  final String? selectedUnitType;
  final Function(String?) onCategoryChanged;
  final Function(String?) onUnitTypeChanged;
  final GlobalKey<FormState> formKey;

  const ProductFormFields({
    Key? key,
    required this.nameController,
    required this.brandController,
    required this.descriptionController,
    required this.priceController,
    required this.skuController,
    required this.supplierController,
    this.selectedCategory,
    this.selectedUnitType,
    required this.onCategoryChanged,
    required this.onUnitTypeChanged,
    required this.formKey,
  }) : super(key: key);

  @override
  State<ProductFormFields> createState() => _ProductFormFieldsState();
}

class _ProductFormFieldsState extends State<ProductFormFields> {
  final List<String> _categories = [
    'Electronics',
    'Clothing & Apparel',
    'Food & Beverages',
    'Health & Beauty',
    'Home & Garden',
    'Sports & Outdoors',
    'Books & Media',
    'Toys & Games',
    'Automotive',
    'Office Supplies',
    'Jewelry & Accessories',
    'Pet Supplies',
  ];

  final List<String> _unitTypes = [
    'Pieces',
    'Kilograms',
    'Grams',
    'Liters',
    'Milliliters',
    'Meters',
    'Centimeters',
    'Boxes',
    'Packs',
    'Bottles',
    'Bags',
    'Sets',
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Basic Information'),
          SizedBox(height: 2.h),
          _buildProductNameField(),
          SizedBox(height: 2.h),
          _buildCategoryDropdown(),
          SizedBox(height: 2.h),
          _buildBrandField(),
          SizedBox(height: 2.h),
          _buildDescriptionField(),
          SizedBox(height: 3.h),
          _buildSectionTitle('Pricing'),
          SizedBox(height: 2.h),
          _buildPriceField(),
          SizedBox(height: 3.h),
          _buildSectionTitle('Stock Information'),
          SizedBox(height: 2.h),
          _buildUnitTypeDropdown(),
          SizedBox(height: 3.h),
          _buildSectionTitle('Advanced Options'),
          SizedBox(height: 2.h),
          _buildSkuField(),
          SizedBox(height: 2.h),
          _buildSupplierField(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  Widget _buildProductNameField() {
    return TextFormField(
      controller: widget.nameController,
      decoration: InputDecoration(
        labelText: 'Product Name *',
        hintText: 'Enter product name',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'inventory_2',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Product name is required';
        }
        if (value.trim().length < 2) {
          return 'Product name must be at least 2 characters';
        }
        return null;
      },
      textCapitalization: TextCapitalization.words,
      maxLength: 100,
      buildCounter: (context,
          {required currentLength, required isFocused, maxLength}) {
        return Text(
          '$currentLength/${maxLength ?? 0}',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownSearch<String>(
      items: (filter, infiniteScrollProps) => _categories,
      selectedItem: widget.selectedCategory,
      onChanged: widget.onCategoryChanged,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: 'Category *',
          hintText: 'Select product category',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'category',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Search categories...',
            prefixIcon: Padding(
              padding: EdgeInsets.all(2.w),
              child: CustomIconWidget(
                iconName: 'search',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
        ),
        menuProps: MenuProps(
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  Widget _buildBrandField() {
    return TextFormField(
      controller: widget.brandController,
      decoration: InputDecoration(
        labelText: 'Brand',
        hintText: 'Enter brand name',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'business',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
      textCapitalization: TextCapitalization.words,
      maxLength: 50,
      buildCounter: (context,
          {required currentLength, required isFocused, maxLength}) {
        return currentLength > 0
            ? Text(
                '$currentLength/${maxLength ?? 0}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              )
            : null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: widget.descriptionController,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Enter product description',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'description',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      buildCounter: (context,
          {required currentLength, required isFocused, maxLength}) {
        return currentLength > 0
            ? Text(
                '$currentLength/${maxLength ?? 0}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              )
            : null;
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: widget.priceController,
      decoration: InputDecoration(
        labelText: 'Price *',
        hintText: '0.00',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'attach_money',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        prefixText: '\$ ',
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Price is required';
        }
        final price = double.tryParse(value);
        if (price == null) {
          return 'Please enter a valid price';
        }
        if (price <= 0) {
          return 'Price must be greater than 0';
        }
        if (price > 999999.99) {
          return 'Price cannot exceed \$999,999.99';
        }
        return null;
      },
    );
  }

  Widget _buildUnitTypeDropdown() {
    return DropdownSearch<String>(
      items: (filter, infiniteScrollProps) => _unitTypes,
      selectedItem: widget.selectedUnitType ?? 'Pieces',
      onChanged: widget.onUnitTypeChanged,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: 'Unit Type',
          hintText: 'Select unit type',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'straighten',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Search unit types...',
            prefixIcon: Padding(
              padding: EdgeInsets.all(2.w),
              child: CustomIconWidget(
                iconName: 'search',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
        ),
        menuProps: MenuProps(
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildSkuField() {
    return TextFormField(
      controller: widget.skuController,
      decoration: InputDecoration(
        labelText: 'SKU (Stock Keeping Unit)',
        hintText: 'Auto-generated or enter custom SKU',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'qr_code',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: _generateSku,
          icon: CustomIconWidget(
            iconName: 'refresh',
            color: AppTheme.lightTheme.primaryColor,
            size: 20,
          ),
          tooltip: 'Generate SKU',
        ),
      ),
      textCapitalization: TextCapitalization.characters,
      maxLength: 20,
      buildCounter: (context,
          {required currentLength, required isFocused, maxLength}) {
        return currentLength > 0
            ? Text(
                '$currentLength/${maxLength ?? 0}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              )
            : null;
      },
    );
  }

  Widget _buildSupplierField() {
    return TextFormField(
      controller: widget.supplierController,
      decoration: InputDecoration(
        labelText: 'Supplier',
        hintText: 'Enter supplier name',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'local_shipping',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
      textCapitalization: TextCapitalization.words,
      maxLength: 100,
      buildCounter: (context,
          {required currentLength, required isFocused, maxLength}) {
        return currentLength > 0
            ? Text(
                '$currentLength/${maxLength ?? 0}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              )
            : null;
      },
    );
  }

  void _generateSku() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final category =
        widget.selectedCategory?.substring(0, 3).toUpperCase() ?? 'GEN';
    final randomSuffix = (timestamp % 10000).toString().padLeft(4, '0');
    final sku = '$category$randomSuffix';

    widget.skuController.text = sku;
  }
}
