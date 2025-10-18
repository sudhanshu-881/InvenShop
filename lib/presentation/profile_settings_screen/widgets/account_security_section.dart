import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AccountSecuritySection extends StatefulWidget {
  final Map<String, dynamic> securitySettings;
  final Function(Map<String, dynamic>) onSecuritySettingsChanged;

  const AccountSecuritySection({
    Key? key,
    required this.securitySettings,
    required this.onSecuritySettingsChanged,
  }) : super(key: key);

  @override
  State<AccountSecuritySection> createState() => _AccountSecuritySectionState();
}

class _AccountSecuritySectionState extends State<AccountSecuritySection> {
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(
        onPasswordChanged: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
        },
      ),
    );
  }

  void _toggleBiometricAuth(bool value) {
    final updatedSettings = {
      ...widget.securitySettings,
      'biometricEnabled': value,
    };
    widget.onSecuritySettingsChanged(updatedSettings);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Biometric authentication enabled'
              : 'Biometric authentication disabled',
        ),
      ),
    );
  }

  void _toggleTwoFactorAuth(bool value) {
    if (value) {
      _showTwoFactorSetupDialog();
    } else {
      final updatedSettings = {
        ...widget.securitySettings,
        'twoFactorEnabled': false,
      };
      widget.onSecuritySettingsChanged(updatedSettings);
    }
  }

  void _showTwoFactorSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => TwoFactorSetupDialog(
        onSetupComplete: () {
          final updatedSettings = {
            ...widget.securitySettings,
            'twoFactorEnabled': true,
          };
          widget.onSecuritySettingsChanged(updatedSettings);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Two-factor authentication enabled')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
                iconName: 'security',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Account Security',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CustomIconWidget(
              iconName: 'lock',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Change Password'),
            subtitle: const Text('Update your account password'),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onTap: _showChangePasswordDialog,
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: CustomIconWidget(
              iconName: 'fingerprint',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use fingerprint or face ID to unlock'),
            value: widget.securitySettings['biometricEnabled'] ?? false,
            onChanged: _toggleBiometricAuth,
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: CustomIconWidget(
              iconName: 'verified_user',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Add an extra layer of security'),
            value: widget.securitySettings['twoFactorEnabled'] ?? false,
            onChanged: _toggleTwoFactorAuth,
          ),
        ],
      ),
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  final VoidCallback onPasswordChanged;

  const ChangePasswordDialog({
    Key? key,
    required this.onPasswordChanged,
  }) : super(key: key);

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  void _changePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      // Simulate password change
      Navigator.pop(context);
      widget.onPasswordChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrentPassword,
              decoration: InputDecoration(
                labelText: 'Current Password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                  icon: CustomIconWidget(
                    iconName: _obscureCurrentPassword
                        ? 'visibility'
                        : 'visibility_off',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current password';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                  icon: CustomIconWidget(
                    iconName:
                        _obscureNewPassword ? 'visibility' : 'visibility_off',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a new password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  icon: CustomIconWidget(
                    iconName: _obscureConfirmPassword
                        ? 'visibility'
                        : 'visibility_off',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
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
          onPressed: _changePassword,
          child: const Text('Change Password'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

class TwoFactorSetupDialog extends StatefulWidget {
  final VoidCallback onSetupComplete;

  const TwoFactorSetupDialog({
    Key? key,
    required this.onSetupComplete,
  }) : super(key: key);

  @override
  State<TwoFactorSetupDialog> createState() => _TwoFactorSetupDialogState();
}

class _TwoFactorSetupDialogState extends State<TwoFactorSetupDialog> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _codeSent = false;

  void _sendCode() {
    if (_phoneController.text.isNotEmpty) {
      setState(() {
        _codeSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code sent to your phone')),
      );
    }
  }

  void _verifyCode() {
    if (_codeController.text.length == 6) {
      Navigator.pop(context);
      widget.onSetupComplete();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Setup Two-Factor Authentication'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_codeSent) ...[
            const Text(
                'Enter your phone number to receive verification codes:'),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1 (555) 123-4567',
              ),
              keyboardType: TextInputType.phone,
            ),
          ] else ...[
            const Text('Enter the 6-digit code sent to your phone:'),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                hintText: '123456',
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _codeSent ? _verifyCode : _sendCode,
          child: Text(_codeSent ? 'Verify' : 'Send Code'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}
