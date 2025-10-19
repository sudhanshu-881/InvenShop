import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static SupabaseClient? _client;
  
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    
    _client = Supabase.instance.client;
  }
  
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized');
    }
    return _client!;
  }
}

// Authentication Service
class AuthService {
  final SupabaseClient _client = SupabaseService.client;
  
  // Phone OTP Login
  Future<void> signInWithPhone(String phone) async {
    try {
      await _client.auth.signInWithOtp(
        phone: '+91$phone',
      );
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }
  
  // Verify OTP
  Future<AuthResponse> verifyOTP(String phone, String otp) async {
    try {
      final response = await _client.auth.verifyOTP(
        type: OtpType.sms,
        phone: '+91$phone',
        token: otp,
      );
      return response;
    } catch (e) {
      throw Exception('Invalid OTP: $e');
    }
  }
  
  // Create Shop Profile
  Future<void> createShopProfile(Map<String, dynamic> shopData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      await _client.from('shops').insert({
        'id': user.id,
        ...shopData,
      });
    } catch (e) {
      throw Exception('Failed to create shop: $e');
    }
  }
  
  // Get current shop
  Future<Map<String, dynamic>?> getCurrentShop() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      
      final response = await _client
          .from('shops')
          .select()
          .eq('id', user.id)
          .single();
      
      return response;
    } catch (e) {
      return null;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
  
  // Get current user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }
  
  // Check if user is logged in
  bool get isLoggedIn {
    return _client.auth.currentUser != null;
  }
  
  // Listen to auth state changes
  Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }
}

// Product Service
class ProductService {
  final SupabaseClient _client = SupabaseService.client;
  
  // Get all products
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final shopId = _client.auth.currentUser?.id;
      if (shopId == null) throw Exception('Not logged in');
      
      final response = await _client
          .from('products')
          .select('*, categories(*)')
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
  
  // Add product
  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      final shopId = _client.auth.currentUser?.id;
      if (shopId == null) throw Exception('Not logged in');
      
      await _client.from('products').insert({
        'shop_id': shopId,
        ...productData,
      });
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }
  
  // Update product
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await _client
          .from('products')
          .update(data)
          .eq('id', productId);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }
  
  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _client
          .from('products')
          .delete()
          .eq('id', productId);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
  
  // Search products
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final shopId = _client.auth.currentUser?.id;
      if (shopId == null) throw Exception('Not logged in');
      
      final response = await _client
          .from('products')
          .select()
          .eq('shop_id', shopId)
          .or('name.ilike.%$query%,barcode.ilike.%$query%,sku.ilike.%$query%');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }
  
  // Get low stock items
  Future<List<Map<String, dynamic>>> getLowStockItems() async {
    try {
      final shopId = _client.auth.currentUser?.id;
      if (shopId == null) throw Exception('Not logged in');
      
      final response = await _client
          .from('products')
          .select()
          .eq('shop_id', shopId)
          .lte('current_stock', 'min_stock');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch low stock items: $e');
    }
  }
  
  // Update stock
  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _client
          .from('products')
          .update({'current_stock': newStock})
          .eq('id', productId);
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }
}

// Customer Service
class CustomerService {
  final SupabaseClient _client = SupabaseService.client;
  
  // Get all customers
  Future<List<Map<String, dynamic>>> getCustomers() async {
    try {
      final shopId = _client.auth.currentUser?.id;
      if (shopId == null) throw Exception('Not logged in');
      
      final response = await _client
          .from('customers')
          .select()
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }
  
  // Add customer
  Future<void> addCustomer(Map<String, dynamic> customerData) async {
    try {
      final shopId = _client.auth.currentUser?.id;
      if (shopId == null) throw Exception('Not logged in');
      
      await _client.from('customers').insert({
        'shop_id': shopId,
        ...customerData,
      });
    } catch (e) {
      throw Exception('Failed to add customer: $e');
    }
  }
  
  // Update customer
  Future<void> updateCustomer(String customerId, Map<String, dynamic> data) async {
    try {
      await _client
          .from('customers')
          .update(data)
          .eq('id', customerId);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }
  
  // Delete customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _client
          .from('customers')
          .delete()
          .eq('id', customerId);
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }
  
  // Search customers
  Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    try {
      final shopId = _client.auth.currentUser?.id;
      if (shopId == null) throw Exception('Not logged in');
      
      final response = await _client
          .from('customers')
          .select()
          .eq('shop_id', shopId)
          .or('name.ilike.%$query%,phone.ilike.%$query%');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }
  
  // Get customers with credit dues
  Future<List<Map<String, dynamic>>> getCustomersWithDues() async {
    try {
      final shopId = _client.auth.currentUser?.id;
      if (shopId == null) throw Exception('Not logged in');
      
      final response = await _client
          .from('customers')
          .select()
          .eq('shop_id', shopId)
          .gt('credit_due', 0)
          .order('credit_due', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch customers with dues: $e');
    }
  }
  
  // Record payment
  Future<void> recordPayment(String customerId, double amount) async {
    try {
      // Get current customer data
      final customer = await _client
          .from('customers')
          .select('credit_due')
          .eq('id', customerId)
          .single();
      
      final newCreditDue = (customer['credit_due'] as num) - amount;
      
      await _client
          .from('customers')
          .update({'credit_due': newCreditDue.clamp(0, double.infinity)})
          .eq('id', customerId);
    } catch (e) {
      throw Exception('Failed to record payment: $e');
    }
  }
}

// Transaction Service
class TransactionService {
  final SupabaseClient _client = SupabaseService.client;
  
  // Create transaction
  Future<Map<String, dynamic>> createTransaction({
    required List<Map<String, dynamic>> items,
    String? customerId,
    required String paymentMethod,
    required double paidAmount,
    double? discountAmount,
    String? notes,
  }) async {
    try {
      final shopId = _client.auth.currentUser?.id;
      if (shopId == null) throw Exception('Not logged in');
      
      // Calculate totals
      double subtotal = 0;
      for (var item in items) {
        subtotal += (item['price'] as num) * (item['quantity'] as num);
      }
      
      final gstAmount = subtotal * 0.18; // 18% GST
      final totalAmount = subtotal + gstAmount - (discountAmount ?? 0);
      
      // Create transaction
      final transactionResponse = await _client
          .from('transactions')
          .insert({
            'shop_id': shopId,
            'customer_id': customerId,
            'subtotal': subtotal,
            'discount_amount': discountAmount ?? 0,
            'gst_amount': gstAmount,
            'total_amount': totalAmount,
            'paid_amount': paidAmount,
            'payment_method': paymentMethod,
            'notes': notes,
            'status': 'completed',
          })
          .select()
          .single();
      
      // Create transaction items
      for (var item in items) {
        await _client.from('transaction_items').insert({
          'transaction_id': transactionResponse['id'],
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'price': item['price'],
          'total': (item['price'] as num) * (item['quantity'] as num),
        });
        
        // Update product stock
        await _client.rpc('decrease_product_stock', params: {
          'product_id': item['product_id'],
          'quantity': item['quantity'],
        });
      }
      
      return transactionResponse;
    } catch (e) {
      throw Exception('Transaction failed: $e');
    }
  }
  
  // Get transactions
  Future<List<Map<String, dynamic>>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final shopId = _client.auth.currentUser?.id;
      if (shopId == null) throw Exception('Not logged in');
      
      var query = _client
          .from('transactions')
          .select('*, customers(*), transaction_items(*, products(*))')
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);
      
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }
  
  // Get transaction by ID
  Future<Map<String, dynamic>> getTransaction(String transactionId) async {
    try {
      final response = await _client
          .from('transactions')
          .select('*, customers(*), transaction_items(*, products(*))')
          .eq('id', transactionId)
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to fetch transaction: $e');
    }
  }
  
  // Get today's transactions
  Future<List<Map<String, dynamic>>> getTodaysTransactions() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      return await getTransactions(
        startDate: startOfDay,
        endDate: endOfDay,
      );
    } catch (e) {
      throw Exception('Failed to fetch today\'s transactions: $e');
    }
  }
}

// Dashboard Service
class DashboardService {
  final SupabaseClient _client = SupabaseService.client;
  
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final shopId = _client.auth.currentUser?.id;
      if (shopId == null) throw Exception('Not logged in');
      
      // Get today's date range
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      // Get yesterday's date range
      final yesterday = today.subtract(const Duration(days: 1));
      final startOfYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day);
      final endOfYesterday = startOfYesterday.add(const Duration(days: 1));
      
      // Get today's sales
      final todaySales = await _client
          .from('transactions')
          .select('total_amount')
          .eq('shop_id', shopId)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());
      
      // Get yesterday's sales
      final yesterdaySales = await _client
          .from('transactions')
          .select('total_amount')
          .eq('shop_id', shopId)
          .gte('created_at', startOfYesterday.toIso8601String())
          .lt('created_at', endOfYesterday.toIso8601String());
      
      // Get total products
      final totalProducts = await _client
          .from('products')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('shop_id', shopId);
      
      // Get low stock items
      final lowStockItems = await _client
          .from('products')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('shop_id', shopId)
          .lte('current_stock', 'min_stock');
      
      // Get credit dues
      final creditDues = await _client
          .from('customers')
          .select('credit_due')
          .eq('shop_id', shopId);
      
      // Calculate totals
      double todayTotal = 0;
      for (var sale in todaySales) {
        todayTotal += (sale['total_amount'] as num).toDouble();
      }
      
      double yesterdayTotal = 0;
      for (var sale in yesterdaySales) {
        yesterdayTotal += (sale['total_amount'] as num).toDouble();
      }
      
      double totalCreditDues = 0;
      for (var customer in creditDues) {
        totalCreditDues += (customer['credit_due'] as num).toDouble();
      }
      
      return {
        'today_sales': todayTotal,
        'yesterday_sales': yesterdayTotal,
        'total_products': totalProducts.count ?? 0,
        'low_stock_items': lowStockItems.count ?? 0,
        'credit_dues': totalCreditDues,
        'sales_growth': yesterdayTotal > 0 ? ((todayTotal - yesterdayTotal) / yesterdayTotal) * 100 : 0,
      };
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }
  
  // Get sales analytics
  Future<Map<String, dynamic>> getSalesAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final shopId = _client.auth.currentUser?.id;
      if (shopId == null) throw Exception('Not logged in');
      
      final response = await _client
          .from('transactions')
          .select('total_amount, created_at')
          .eq('shop_id', shopId)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: true);
      
      double totalSales = 0;
      int transactionCount = 0;
      
      for (var transaction in response) {
        totalSales += (transaction['total_amount'] as num).toDouble();
        transactionCount++;
      }
      
      return {
        'total_sales': totalSales,
        'transaction_count': transactionCount,
        'average_transaction': transactionCount > 0 ? totalSales / transactionCount : 0,
        'transactions': response,
      };
    } catch (e) {
      throw Exception('Failed to fetch sales analytics: $e');
    }
  }
}

// Category Service
class CategoryService {
  final SupabaseClient _client = SupabaseService.client;
  
  // Get all categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final shopId = _client.auth.currentUser?.id;
      if (shopId == null) throw Exception('Not logged in');
      
      final response = await _client
          .from('categories')
          .select()
          .eq('shop_id', shopId)
          .order('name', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
  
  // Add category
  Future<void> addCategory(Map<String, dynamic> categoryData) async {
    try {
      final shopId = _client.auth.currentUser?.id;
      if (shopId == null) throw Exception('Not logged in');
      
      await _client.from('categories').insert({
        'shop_id': shopId,
        ...categoryData,
      });
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }
  
  // Update category
  Future<void> updateCategory(String categoryId, Map<String, dynamic> data) async {
    try {
      await _client
          .from('categories')
          .update(data)
          .eq('id', categoryId);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }
  
  // Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _client
          .from('categories')
          .delete()
          .eq('id', categoryId);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}