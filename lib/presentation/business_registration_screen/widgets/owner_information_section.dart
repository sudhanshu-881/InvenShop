import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class OwnerInformationSection extends StatefulWidget {
  final TextEditingController ownerNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final VoidCallback onPhoneVerification;
  final bool isPhoneVerified;

  const OwnerInformationSection({
    Key? key,
    required this.ownerNameController,
    required this.phoneController,
    required this.emailController,
    required this.onPhoneVerification,
    required this.isPhoneVerified,
  }) : super(key: key);

  @override
  State<OwnerInformationSection> createState() =>
      _OwnerInformationSectionState();
}

class _OwnerInformationSectionState extends State<OwnerInformationSection> {
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
                iconName: 'person',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Owner Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Owner Name Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Owner Name *',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(height: 1.h),
              TextFormField(
                controller: widget.ownerNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter owner full name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Owner name is required';
                  }
                  return null;
                },
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Phone Number Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phone Number *',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: widget.phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '+1 (555) 123-4567',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'phone',
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                        suffixIcon: widget.isPhoneVerified
                            ? Padding(
                                padding: EdgeInsets.all(3.w),
                                child: CustomIconWidget(
                                  iconName: 'verified',
                                  color: Colors.green,
                                  size: 20,
                                ),
                              )
                            : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        if (!widget.isPhoneVerified) {
                          return 'Please verify your phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 2.w),
                  ElevatedButton(
                    onPressed: widget.phoneController.text.isNotEmpty &&
                            !widget.isPhoneVerified
                        ? widget.onPhoneVerification
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      backgroundColor: widget.isPhoneVerified
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      widget.isPhoneVerified ? 'Verified' : 'Verify',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.isPhoneVerified)
                Padding(
                  padding: EdgeInsets.only(top: 0.5.h),
                  child: Text(
                    'Phone number verified successfully',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                        ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 2.h),

          // Email Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email Address *',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(height: 1.h),
              TextFormField(
                controller: widget.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'owner@business.com',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'email',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email address is required';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
