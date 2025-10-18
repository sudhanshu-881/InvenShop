import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PhoneVerificationDialog extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onVerificationSuccess;

  const PhoneVerificationDialog({
    Key? key,
    required this.phoneNumber,
    required this.onVerificationSuccess,
  }) : super(key: key);

  @override
  State<PhoneVerificationDialog> createState() =>
      _PhoneVerificationDialogState();
}

class _PhoneVerificationDialogState extends State<PhoneVerificationDialog> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  Timer? _timer;
  int _remainingTime = 60;
  bool _isResendEnabled = false;
  bool _isVerifying = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      }
    });
  }

  void _resendOTP() {
    setState(() {
      _remainingTime = 60;
      _isResendEnabled = false;
      _errorMessage = '';
    });
    _startTimer();

    // Clear OTP fields
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _onOTPChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all fields are filled
    if (index == 5 && value.isNotEmpty) {
      _verifyOTP();
    }

    setState(() {
      _errorMessage = '';
    });
  }

  void _verifyOTP() {
    final otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter complete OTP';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    // Simulate OTP verification
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Mock verification - accept "123456" as valid OTP
        if (otp == '123456') {
          widget.onVerificationSuccess();
          Navigator.of(context).pop();
        } else {
          setState(() {
            _isVerifying = false;
            _errorMessage = 'Invalid OTP. Please try again.';
          });

          // Clear OTP fields
          for (var controller in _otpControllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
        }
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'verified_user',
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verify Phone Number',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        'Enter the 6-digit code sent to',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        widget.phoneNumber,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 12.w,
                  child: TextFormField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(vertical: 2.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                          width: 2,
                        ),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) => _onOTPChanged(value, index),
                  ),
                );
              }),
            ),

            if (_errorMessage.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'error',
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 3.h),

            // Timer and Resend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isResendEnabled
                      ? 'Didn\'t receive code?'
                      : 'Resend code in ${_formatTime(_remainingTime)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_isResendEnabled)
                  TextButton(
                    onPressed: _resendOTP,
                    child: Text(
                      'Resend',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 3.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isVerifying ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyOTP,
                    child: _isVerifying
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : const Text('Verify'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Mock credentials info
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Demo: Use OTP "123456" for verification',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 10.sp,
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
