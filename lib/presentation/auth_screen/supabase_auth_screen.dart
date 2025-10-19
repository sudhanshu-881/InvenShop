import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/supabase_service.dart';

class SupabaseAuthScreen extends StatefulWidget {
  const SupabaseAuthScreen({Key? key}) : super(key: key);

  @override
  State<SupabaseAuthScreen> createState() => _SupabaseAuthScreenState();
}

class _SupabaseAuthScreenState extends State<SupabaseAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  bool _isOtpSent = false;
  bool _isLoading = false;
  int _resendCountdown = 30;
  Timer? _timer;
  String _enteredPhone = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.length != 10) {
      _showSnackBar('Please enter a valid 10-digit mobile number', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      await authService.signInWithPhone(_phoneController.text);
      
      setState(() {
        _isLoading = false;
        _isOtpSent = true;
        _enteredPhone = _phoneController.text;
        _startResendCountdown();
      });

      _showSnackBar('OTP sent to +91 ${_phoneController.text}');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Failed to send OTP: ${e.toString()}', isError: true);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      _showSnackBar('Please enter a valid 6-digit OTP', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final response = await authService.verifyOTP(_enteredPhone, _otpController.text);
      
      if (response.user != null) {
        // Check if shop profile exists
        final shop = await authService.getCurrentShop();
        
        setState(() {
          _isLoading = false;
        });

        if (shop == null) {
          // Navigate to shop setup
          Navigator.pushReplacementNamed(context, '/business-registration-screen');
        } else {
          // Navigate to dashboard
          Navigator.pushReplacementNamed(context, '/simplified-dashboard');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Invalid OTP: ${e.toString()}', isError: true);
    }
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _resendOtp() {
    if (_resendCountdown == 0) {
      _sendOtp();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorLight : AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            children: [
              SizedBox(height: 8.h),
              
              // Logo and Title
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const CustomIconWidget(
                  iconName: 'store',
                  color: Colors.white,
                  size: 40,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'InvenShop',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Your Digital Shop Assistant',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),

              SizedBox(height: 8.h),

              // Auth Form
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _isOtpSent ? 'Enter OTP' : 'Enter Mobile Number',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _isOtpSent
                          ? 'We sent a 6-digit code to +91 $_enteredPhone'
                          : 'Enter your 10-digit mobile number to get started',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),

                    if (!_isOtpSent) ...[
                      // Phone Input
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          hintText: '9876543210',
                          prefixText: '+91 ',
                          prefixIcon: const Icon(Icons.phone, color: AppTheme.primaryLight),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ] else ...[
                      // OTP Input
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(8),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                          activeColor: AppTheme.primaryLight,
                          inactiveColor: AppTheme.borderLight,
                          selectedColor: AppTheme.primaryLight,
                        ),
                        enableActiveFill: true,
                        onChanged: (value) {},
                      ),
                      SizedBox(height: 2.h),
                      TextButton(
                        onPressed: _resendCountdown == 0 ? _resendOtp : null,
                        child: Text(
                          _resendCountdown == 0
                              ? 'Resend OTP'
                              : 'Resend in ${_resendCountdown}s',
                          style: TextStyle(
                            color: _resendCountdown == 0
                                ? AppTheme.primaryLight
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 4.h),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _sendOtp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isOtpSent ? 'Verify & Continue' : 'Get OTP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Footer
              Text(
                'By continuing, you agree to our Terms & Privacy Policy',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}