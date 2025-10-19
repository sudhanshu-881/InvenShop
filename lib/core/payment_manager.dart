import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'app_config.dart';
import 'app_export.dart';

class PaymentManager {
  static final PaymentManager _instance = PaymentManager._internal();
  factory PaymentManager() => _instance;
  PaymentManager._internal();

  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? _onSuccess;
  Function(PaymentFailureResponse)? _onFailure;
  Function(PaymentExternalWalletResponse)? _onExternalWallet;

  /// Initialize Razorpay
  void initialize() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');
    if (_onSuccess != null) {
      _onSuccess!(response);
    }
  }

  /// Handle payment failure
  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    if (_onFailure != null) {
      _onFailure!(response);
    }
  }

  /// Handle external wallet
  void _handleExternalWallet(PaymentExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
    if (_onExternalWallet != null) {
      _onExternalWallet!(response);
    }
  }

  /// Create payment order
  Future<Map<String, dynamic>?> createOrder({
    required double amount,
    required String currency,
    required String receipt,
    Map<String, dynamic>? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/payments/create-order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'amount': (amount * 100).toInt(), // Convert to paise
          'currency': currency,
          'receipt': receipt,
          'notes': notes ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  /// Process payment
  Future<void> processPayment({
    required double amount,
    required String currency,
    required String receipt,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? description,
    Map<String, dynamic>? notes,
    Function(PaymentSuccessResponse)? onSuccess,
    Function(PaymentFailureResponse)? onFailure,
    Function(PaymentExternalWalletResponse)? onExternalWallet,
  }) async {
    try {
      _onSuccess = onSuccess;
      _onFailure = onFailure;
      _onExternalWallet = onExternalWallet;

      // Create order
      final order = await createOrder(
        amount: amount,
        currency: currency,
        receipt: receipt,
        notes: notes,
      );

      if (order == null) {
        throw Exception('Failed to create payment order');
      }

      // Configure Razorpay options
      final options = {
        'key': AppConfig.razorpayKeyId,
        'amount': (amount * 100).toInt(), // Convert to paise
        'currency': currency,
        'name': 'InvenShop',
        'description': description ?? 'Payment for InvenShop',
        'order_id': order['id'],
        'prefill': {
          'contact': customerPhone,
          'email': customerEmail,
          'name': customerName,
        },
        'theme': {
          'color': '#2E7D32',
        },
        'retry': {
          'enabled': true,
          'max_count': 3,
        },
        'modal': {
          'ondismiss': () {
            print('Payment modal dismissed');
          },
        },
      };

      // Open Razorpay checkout
      _razorpay.open(options);
    } catch (e) {
      print('Error processing payment: $e');
      if (onFailure != null) {
        onFailure!(PaymentFailureResponse(
          code: 0,
          message: e.toString(),
        ));
      }
    }
  }

  /// Verify payment
  Future<bool> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/payments/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'payment_id': paymentId,
          'order_id': orderId,
          'signature': signature,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error verifying payment: $e');
      return false;
    }
  }

  /// Get payment methods
  List<String> getSupportedPaymentMethods() {
    return [
      'card',
      'netbanking',
      'wallet',
      'upi',
      'emi',
    ];
  }

  /// Get supported banks
  List<String> getSupportedBanks() {
    return [
      'HDFC',
      'ICICI',
      'Axis Bank',
      'SBI',
      'Kotak Mahindra',
      'Yes Bank',
      'IndusInd Bank',
      'Federal Bank',
      'IDBI Bank',
      'Bank of Baroda',
    ];
  }

  /// Get supported wallets
  List<String> getSupportedWallets() {
    return [
      'Paytm',
      'PhonePe',
      'Google Pay',
      'Amazon Pay',
      'Mobikwik',
      'Freecharge',
      'JioMoney',
      'Airtel Money',
    ];
  }

  /// Get supported UPI apps
  List<String> getSupportedUPIApps() {
    return [
      'Google Pay',
      'PhonePe',
      'Paytm',
      'BHIM',
      'Amazon Pay',
      'Mobikwik',
      'Freecharge',
      'JioMoney',
      'Airtel Money',
    ];
  }

  /// Show payment method selection dialog
  Future<String?> showPaymentMethodDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.credit_card, color: AppTheme.primaryLight),
              title: Text('Card'),
              subtitle: Text('Credit/Debit Card'),
              onTap: () => Navigator.pop(context, 'card'),
            ),
            ListTile(
              leading: Icon(Icons.account_balance, color: AppTheme.primaryLight),
              title: Text('Net Banking'),
              subtitle: Text('Online Banking'),
              onTap: () => Navigator.pop(context, 'netbanking'),
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet, color: AppTheme.primaryLight),
              title: Text('Wallet'),
              subtitle: Text('Paytm, PhonePe, etc.'),
              onTap: () => Navigator.pop(context, 'wallet'),
            ),
            ListTile(
              leading: Icon(Icons.qr_code, color: AppTheme.primaryLight),
              title: Text('UPI'),
              subtitle: Text('Google Pay, PhonePe, etc.'),
              onTap: () => Navigator.pop(context, 'upi'),
            ),
            ListTile(
              leading: Icon(Icons.money, color: AppTheme.primaryLight),
              title: Text('Cash'),
              subtitle: Text('Pay on delivery'),
              onTap: () => Navigator.pop(context, 'cash'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Show payment success dialog
  void showPaymentSuccessDialog(BuildContext context, PaymentSuccessResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successLight, size: 32),
            SizedBox(width: 2.w),
            Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment ID: ${response.paymentId}'),
            Text('Order ID: ${response.orderId}'),
            Text('Signature: ${response.signature}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show payment failure dialog
  void showPaymentFailureDialog(BuildContext context, PaymentFailureResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: AppTheme.errorLight, size: 32),
            SizedBox(width: 2.w),
            Text('Payment Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error Code: ${response.code}'),
            Text('Error Message: ${response.message}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Get auth token (implement based on your auth system)
  Future<String> _getAuthToken() async {
    // Implement your token retrieval logic
    return 'your-auth-token';
  }

  /// Dispose Razorpay
  void dispose() {
    _razorpay.clear();
  }
}