import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StockManagementSection extends StatefulWidget {
  final int currentQuantity;
  final int minimumStock;
  final DateTime? expirationDate;
  final bool isMarketplaceVisible;
  final Function(int) onQuantityChanged;
  final Function(int) onMinimumStockChanged;
  final Function(DateTime?) onExpirationDateChanged;
  final Function(bool) onMarketplaceVisibilityChanged;

  const StockManagementSection({
    Key? key,
    required this.currentQuantity,
    required this.minimumStock,
    this.expirationDate,
    required this.isMarketplaceVisible,
    required this.onQuantityChanged,
    required this.onMinimumStockChanged,
    required this.onExpirationDateChanged,
    required this.onMarketplaceVisibilityChanged,
  }) : super(key: key);

  @override
  State<StockManagementSection> createState() => _StockManagementSectionState();
}

class _StockManagementSectionState extends State<StockManagementSection> {
  late TextEditingController _quantityController;
  late TextEditingController _minimumStockController;
  bool _showAdvancedOptions = false;

  @override
  void initState() {
    super.initState();
    _quantityController =
        TextEditingController(text: widget.currentQuantity.toString());
    _minimumStockController =
        TextEditingController(text: widget.minimumStock.toString());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Stock Management'),
        SizedBox(height: 2.h),
        _buildCurrentQuantitySection(),
        SizedBox(height: 2.h),
        _buildMinimumStockSection(),
        SizedBox(height: 2.h),
        _buildAdvancedOptionsToggle(),
        if (_showAdvancedOptions) ...[
          SizedBox(height: 2.h),
          _buildAdvancedOptions(),
        ],
      ],
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

  Widget _buildCurrentQuantitySection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'inventory',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Current Stock',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    hintText: '0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    final quantity = int.tryParse(value) ?? 0;
                    widget.onQuantityChanged(quantity);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final quantity = int.tryParse(value);
                    if (quantity == null || quantity < 0) {
                      return 'Invalid quantity';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 3.w),
              _buildStepperButtons(),
            ],
          ),
          SizedBox(height: 1.h),
          _buildStockStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildStepperButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _adjustQuantity(1),
          child: Container(
            width: 10.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 20,
              ),
            ),
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: () => _adjustQuantity(-1),
          child: Container(
            width: 10.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'remove',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockStatusIndicator() {
    final quantity = widget.currentQuantity;
    final minStock = widget.minimumStock;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (quantity == 0) {
      statusColor = AppTheme.lightTheme.colorScheme.error;
      statusText = 'Out of Stock';
      statusIcon = Icons.error;
    } else if (quantity <= minStock) {
      statusColor = AppTheme.lightTheme.colorScheme.tertiaryContainer;
      statusText = 'Low Stock';
      statusIcon = Icons.warning;
    } else {
      statusColor = AppTheme.lightTheme.colorScheme.tertiary;
      statusText = 'In Stock';
      statusIcon = Icons.check_circle;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 16,
          ),
          SizedBox(width: 1.w),
          Text(
            statusText,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimumStockSection() {
    return TextFormField(
      controller: _minimumStockController,
      decoration: InputDecoration(
        labelText: 'Minimum Stock Alert',
        hintText: 'Set minimum stock threshold',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'notifications',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        helperText: 'You\'ll be notified when stock falls below this level',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (value) {
        final minStock = int.tryParse(value) ?? 0;
        widget.onMinimumStockChanged(minStock);
      },
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final minStock = int.tryParse(value);
          if (minStock == null || minStock < 0) {
            return 'Please enter a valid minimum stock value';
          }
        }
        return null;
      },
    );
  }

  Widget _buildAdvancedOptionsToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAdvancedOptions = !_showAdvancedOptions;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline,
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.primaryColor,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'Advanced Options',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            CustomIconWidget(
              iconName: _showAdvancedOptions ? 'expand_less' : 'expand_more',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExpirationDatePicker(),
          SizedBox(height: 2.h),
          _buildMarketplaceVisibilityToggle(),
        ],
      ),
    );
  }

  Widget _buildExpirationDatePicker() {
    return GestureDetector(
      onTap: _selectExpirationDate,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'event',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expiration Date',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    widget.expirationDate != null
                        ? '${widget.expirationDate!.day}/${widget.expirationDate!.month}/${widget.expirationDate!.year}'
                        : 'Select expiration date (optional)',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: widget.expirationDate != null
                          ? AppTheme.lightTheme.colorScheme.onSurface
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.expirationDate != null)
              GestureDetector(
                onTap: () => widget.onExpirationDateChanged(null),
                child: CustomIconWidget(
                  iconName: 'clear',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketplaceVisibilityToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'storefront',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marketplace Visibility',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Make this product visible in the local marketplace',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: widget.isMarketplaceVisible,
            onChanged: widget.onMarketplaceVisibilityChanged,
          ),
        ],
      ),
    );
  }

  void _adjustQuantity(int adjustment) {
    final currentValue = int.tryParse(_quantityController.text) ?? 0;
    final newValue = (currentValue + adjustment).clamp(0, 999999);
    _quantityController.text = newValue.toString();
    widget.onQuantityChanged(newValue);
  }

  Future<void> _selectExpirationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          widget.expirationDate ?? DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 3650)), // 10 years
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onExpirationDateChanged(picked);
    }
  }
}
