import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _isResendEnabled = false;
  int _resendCountdown = 30;
  String _enteredPhone = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.length != 10) {
      _showErrorSnackBar('Please enter a valid 10-digit mobile number');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _isOtpSent = true;
      _enteredPhone = _phoneController.text;
      _startResendCountdown();
    });

    _showSuccessSnackBar('OTP sent to +91 ${_phoneController.text}');
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      _showErrorSnackBar('Please enter a valid 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Navigate to onboarding or dashboard
    Navigator.pushReplacementNamed(context, '/business-registration-screen');
  }

  void _startResendCountdown() {
    setState(() {
      _isResendEnabled = false;
      _resendCountdown = 30;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      }
    });
  }

  void _resendOtp() {
    if (_isResendEnabled) {
      _sendOtp();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8.h),
                
                // Logo and App Name
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryLight.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'store',
                            color: Colors.white,
                            size: 12.w,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'InvenShop',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Digital Inventory Management for Local Retailers',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),

                // Main Content
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isOtpSent ? 'Verify OTP' : 'Enter Mobile Number',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _isOtpSent
                            ? 'We have sent a 6-digit OTP to +91 $_enteredPhone'
                            : 'Enter your 10-digit mobile number to get started',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                        ),
                      ),
                      SizedBox(height: 4.h),

                      if (!_isOtpSent) ...[
                        // Phone Number Input
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                            hintText: '9876543210',
                            prefixText: '+91 ',
                            prefixIcon: CustomIconWidget(
                              iconName: 'phone',
                              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                              size: 20,
                            ),
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
                            activeFillColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                            inactiveFillColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                            selectedFillColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                            activeColor: AppTheme.primaryLight,
                            inactiveColor: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                            selectedColor: AppTheme.primaryLight,
                          ),
                          enableActiveFill: true,
                          onChanged: (value) {},
                        ),
                        SizedBox(height: 2.h),
                        Center(
                          child: Text(
                            'Didn\'t receive OTP?',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Center(
                          child: TextButton(
                            onPressed: _isResendEnabled ? _resendOtp : null,
                            child: Text(
                              _isResendEnabled
                                  ? 'Resend OTP'
                                  : 'Resend in ${_resendCountdown}s',
                              style: TextStyle(
                                color: _isResendEnabled
                                    ? AppTheme.primaryLight
                                    : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
                              ),
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 4.h),

                      // Submit Button
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
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isOtpSent ? 'Verify & Continue' : 'Send OTP',
                                  style: TextStyle(
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

                SizedBox(height: 4.h),

                // Terms and Privacy
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                      ),
                      children: [
                        const TextSpan(text: 'By continuing, you agree to our '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // Language Selection
                Center(
                  child: DropdownButton<String>(
                    value: 'English',
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'English', child: Text('English')),
                      DropdownMenuItem(value: 'Hindi', child: Text('हिंदी')),
                      DropdownMenuItem(value: 'Tamil', child: Text('தமிழ்')),
                      DropdownMenuItem(value: 'Telugu', child: Text('తెలుగు')),
                      DropdownMenuItem(value: 'Bengali', child: Text('বাংলা')),
                    ],
                    onChanged: (value) {
                      // Handle language change
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}