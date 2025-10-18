import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BusinessDetailsSection extends StatefulWidget {
  final TextEditingController businessNameController;
  final TextEditingController businessTypeController;
  final TextEditingController addressController;
  final Function(String) onBusinessNameChanged;
  final bool isBusinessNameAvailable;
  final bool isCheckingAvailability;
  final VoidCallback onLocationPicker;

  const BusinessDetailsSection({
    Key? key,
    required this.businessNameController,
    required this.businessTypeController,
    required this.addressController,
    required this.onBusinessNameChanged,
    required this.isBusinessNameAvailable,
    required this.isCheckingAvailability,
    required this.onLocationPicker,
  }) : super(key: key);

  @override
  State<BusinessDetailsSection> createState() => _BusinessDetailsSectionState();
}

class _BusinessDetailsSectionState extends State<BusinessDetailsSection> {
  final List<String> businessTypes = [
    'Grocery Store',
    'Electronics Shop',
    'Clothing Store',
    'Restaurant',
    'Pharmacy',
    'Hardware Store',
    'Book Store',
    'Jewelry Store',
    'Mobile Shop',
    'Other'
  ];

  String? selectedBusinessType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'business',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Business Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Business Name Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business Name *',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(height: 1.h),
              TextFormField(
                controller: widget.businessNameController,
                onChanged: widget.onBusinessNameChanged,
                decoration: InputDecoration(
                  hintText: 'Enter your business name',
                  suffixIcon: widget.isCheckingAvailability
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      : widget.businessNameController.text.isNotEmpty
                          ? CustomIconWidget(
                              iconName: widget.isBusinessNameAvailable
                                  ? 'check_circle'
                                  : 'error',
                              color: widget.isBusinessNameAvailable
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.error,
                              size: 24,
                            )
                          : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Business name is required';
                  }
                  if (!widget.isBusinessNameAvailable &&
                      !widget.isCheckingAvailability) {
                    return 'Business name is already taken';
                  }
                  return null;
                },
              ),
              if (widget.businessNameController.text.isNotEmpty &&
                  !widget.isCheckingAvailability)
                Padding(
                  padding: EdgeInsets.only(top: 0.5.h),
                  child: Text(
                    widget.isBusinessNameAvailable
                        ? 'Business name is available'
                        : 'Business name is already taken',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: widget.isBusinessNameAvailable
                              ? Colors.green
                              : Theme.of(context).colorScheme.error,
                        ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 2.h),

          // Business Type Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business Type *',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(height: 1.h),
              DropdownButtonFormField<String>(
                value: selectedBusinessType,
                decoration: const InputDecoration(
                  hintText: 'Select business type',
                ),
                items: businessTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedBusinessType = newValue;
                    widget.businessTypeController.text = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a business type';
                  }
                  return null;
                },
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Address Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business Address *',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(height: 1.h),
              TextFormField(
                controller: widget.addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter your complete business address',
                  suffixIcon: IconButton(
                    onPressed: widget.onLocationPicker,
                    icon: CustomIconWidget(
                      iconName: 'location_on',
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Business address is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 0.5.h),
              GestureDetector(
                onTap: widget.onLocationPicker,
                child: Text(
                  'Tap location icon to use GPS assistance',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
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
