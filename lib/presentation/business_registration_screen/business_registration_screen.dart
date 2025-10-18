import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/business_details_section.dart';
import './widgets/document_upload_section.dart';
import './widgets/owner_information_section.dart';
import './widgets/phone_verification_dialog.dart';
import './widgets/progress_indicator_widget.dart';

class BusinessRegistrationScreen extends StatefulWidget {
  const BusinessRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<BusinessRegistrationScreen> createState() =>
      _BusinessRegistrationScreenState();
}

class _BusinessRegistrationScreenState
    extends State<BusinessRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Controllers
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessTypeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // State variables
  int _currentStep = 1;
  final int _totalSteps = 3;
  bool _isBusinessNameAvailable = false;
  bool _isCheckingAvailability = false;
  bool _isPhoneVerified = false;
  bool _isSubmitting = false;
  XFile? _businessLicenseFile;
  XFile? _taxIdFile;
  Timer? _debounceTimer;

  final List<String> _stepTitles = [
    'Business Details',
    'Owner Info',
    'Documents'
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _addressController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _checkBusinessNameAvailability(String businessName) {
    if (businessName.isEmpty) {
      setState(() {
        _isBusinessNameAvailable = false;
        _isCheckingAvailability = false;
      });
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      setState(() {
        _isCheckingAvailability = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isCheckingAvailability = false;
            // Mock availability check - names containing "test" are unavailable
            _isBusinessNameAvailable =
                !businessName.toLowerCase().contains('test');
          });
        }
      });
    });
  }

  void _showPhoneVerificationDialog() {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number first'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PhoneVerificationDialog(
        phoneNumber: _phoneController.text,
        onVerificationSuccess: () {
          setState(() {
            _isPhoneVerified = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone number verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showLocationPicker() {
    // Mock location picker - in real app, this would open a map
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Picker'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'location_on',
              color: Theme.of(context).colorScheme.primary,
              size: 48,
            ),
            SizedBox(height: 2.h),
            const Text('GPS location picker would open here'),
            SizedBox(height: 2.h),
            const Text(
                'Mock Address: 123 Main Street, Business District, City, State 12345'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _addressController.text =
                    '123 Main Street, Business District, City, State 12345';
              });
              Navigator.pop(context);
            },
            child: const Text('Use This Location'),
          ),
        ],
      ),
    );
  }

  bool _isCurrentStepValid() {
    switch (_currentStep) {
      case 1:
        return _businessNameController.text.isNotEmpty &&
            _businessTypeController.text.isNotEmpty &&
            _addressController.text.isNotEmpty &&
            _isBusinessNameAvailable &&
            !_isCheckingAvailability;
      case 2:
        return _ownerNameController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty &&
            _emailController.text.isNotEmpty &&
            _isPhoneVerified;
      case 3:
        return _businessLicenseFile != null && _taxIdFile != null;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
      });
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitRegistration() {
    if (!_formKey.currentState!.validate() || !_isCurrentStepValid()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate registration process
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        _showSuccessDialog();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: Colors.green,
                  size: 48,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Registration Successful!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Your business registration has been submitted successfully. Our team will review your documents and verify your account within 2-3 business days.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'You will receive an email confirmation once your account is verified.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/inventory-dashboard');
              },
              child: const Text('Continue to Dashboard'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return BusinessDetailsSection(
          businessNameController: _businessNameController,
          businessTypeController: _businessTypeController,
          addressController: _addressController,
          onBusinessNameChanged: _checkBusinessNameAvailability,
          isBusinessNameAvailable: _isBusinessNameAvailable,
          isCheckingAvailability: _isCheckingAvailability,
          onLocationPicker: _showLocationPicker,
        );
      case 2:
        return OwnerInformationSection(
          ownerNameController: _ownerNameController,
          phoneController: _phoneController,
          emailController: _emailController,
          onPhoneVerification: _showPhoneVerificationDialog,
          isPhoneVerified: _isPhoneVerified,
        );
      case 3:
        return DocumentUploadSection(
          onBusinessLicenseSelected: (file) {
            setState(() {
              _businessLicenseFile = file;
            });
          },
          onTaxIdSelected: (file) {
            setState(() {
              _taxIdFile = file;
            });
          },
          businessLicenseFile: _businessLicenseFile,
          taxIdFile: _taxIdFile,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: CustomIconWidget(
                          iconName: 'arrow_back',
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Business Registration',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 12.w), // Balance the back button
                    ],
                  ),
                  SizedBox(height: 2.h),
                  ProgressIndicatorWidget(
                    currentStep: _currentStep,
                    totalSteps: _totalSteps,
                    stepTitles: _stepTitles,
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      _buildCurrentStepContent(),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky Bottom Navigation
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 1) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('Previous'),
                      ),
                    ),
                    SizedBox(width: 4.w),
                  ],
                  Expanded(
                    flex: _currentStep == 1 ? 1 : 2,
                    child: ElevatedButton(
                      onPressed: _isCurrentStepValid()
                          ? (_currentStep == _totalSteps
                              ? _submitRegistration
                              : _nextStep)
                          : null,
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          : Text(
                              _currentStep == _totalSteps
                                  ? 'Submit Registration'
                                  : 'Continue',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
