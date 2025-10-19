import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'app_config.dart';
import 'app_export.dart';

class AnalyticsManager {
  static final AnalyticsManager _instance = AnalyticsManager._internal();
  factory AnalyticsManager() => _instance;
  AnalyticsManager._internal();

  late Box _analyticsBox;
  late Box _eventsBox;

  /// Initialize analytics manager
  Future<void> initialize() async {
    _analyticsBox = await Hive.openBox('invenshop_analytics');
    _eventsBox = await Hive.openBox('invenshop_events');
  }

  /// Track user event
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    try {
      if (!AppConfig.enableAnalytics) return;

      final event = {
        'eventName': eventName,
        'parameters': parameters ?? {},
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'userId': await _getUserId(),
        'sessionId': await _getSessionId(),
      };

      await _eventsBox.add(jsonEncode(event));
      
      // Keep only last 1000 events
      if (_eventsBox.length > 1000) {
        final keys = _eventsBox.keys.take(_eventsBox.length - 1000);
        for (final key in keys) {
          await _eventsBox.delete(key);
        }
      }
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  /// Track screen view
  Future<void> trackScreenView(String screenName, {Map<String, dynamic>? parameters}) async {
    await trackEvent('screen_view', parameters: {
      'screen_name': screenName,
      ...?parameters,
    });
  }

  /// Track user action
  Future<void> trackUserAction(String action, {Map<String, dynamic>? parameters}) async {
    await trackEvent('user_action', parameters: {
      'action': action,
      ...?parameters,
    });
  }

  /// Track business metrics
  Future<void> trackBusinessMetric(String metricName, double value, {Map<String, dynamic>? parameters}) async {
    await trackEvent('business_metric', parameters: {
      'metric_name': metricName,
      'value': value,
      ...?parameters,
    });
  }

  /// Track error
  Future<void> trackError(String errorType, String errorMessage, {Map<String, dynamic>? parameters}) async {
    await trackEvent('error', parameters: {
      'error_type': errorType,
      'error_message': errorMessage,
      ...?parameters,
    });
  }

  /// Track performance
  Future<void> trackPerformance(String operation, int durationMs, {Map<String, dynamic>? parameters}) async {
    await trackEvent('performance', parameters: {
      'operation': operation,
      'duration_ms': durationMs,
      ...?parameters,
    });
  }

  /// Get user ID
  Future<String> _getUserId() async {
    return _analyticsBox.get('user_id') ?? 'anonymous';
  }

  /// Set user ID
  Future<void> setUserId(String userId) async {
    await _analyticsBox.put('user_id', userId);
  }

  /// Get session ID
  Future<String> _getSessionId() async {
    String? sessionId = _analyticsBox.get('session_id');
    if (sessionId == null) {
      sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      await _analyticsBox.put('session_id', sessionId);
    }
    return sessionId;
  }

  /// Start new session
  Future<void> startNewSession() async {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    await _analyticsBox.put('session_id', sessionId);
    await trackEvent('session_start');
  }

  /// End current session
  Future<void> endSession() async {
    await trackEvent('session_end');
  }

  /// Get analytics data
  Future<Map<String, dynamic>> getAnalyticsData({
    DateTime? startDate,
    DateTime? endDate,
    String? eventName,
  }) async {
    try {
      final events = <Map<String, dynamic>>[];
      final keys = _eventsBox.keys;

      for (final key in keys) {
        final eventData = _eventsBox.get(key);
        if (eventData != null) {
          final event = jsonDecode(eventData);
          final timestamp = DateTime.fromMillisecondsSinceEpoch(event['timestamp']);
          
          // Filter by date range
          if (startDate != null && timestamp.isBefore(startDate)) continue;
          if (endDate != null && timestamp.isAfter(endDate)) continue;
          
          // Filter by event name
          if (eventName != null && event['eventName'] != eventName) continue;
          
          events.add(event);
        }
      }

      return _processAnalyticsData(events);
    } catch (e) {
      ErrorHandler.handleError(e);
      return {};
    }
  }

  /// Process analytics data
  Map<String, dynamic> _processAnalyticsData(List<Map<String, dynamic>> events) {
    final Map<String, int> eventCounts = {};
    final Map<String, double> metricValues = {};
    final Map<String, List<Map<String, dynamic>>> eventDetails = {};
    
    for (final event in events) {
      final eventName = event['eventName'];
      
      // Count events
      eventCounts[eventName] = (eventCounts[eventName] ?? 0) + 1;
      
      // Store event details
      if (!eventDetails.containsKey(eventName)) {
        eventDetails[eventName] = [];
      }
      eventDetails[eventName]!.add(event);
      
      // Process business metrics
      if (eventName == 'business_metric') {
        final metricName = event['parameters']['metric_name'];
        final value = event['parameters']['value'] ?? 0.0;
        metricValues[metricName] = (metricValues[metricName] ?? 0.0) + value;
      }
    }

    return {
      'totalEvents': events.length,
      'eventCounts': eventCounts,
      'metricValues': metricValues,
      'eventDetails': eventDetails,
      'dateRange': {
        'start': events.isNotEmpty ? events.first['timestamp'] : null,
        'end': events.isNotEmpty ? events.last['timestamp'] : null,
      },
    };
  }

  /// Get sales analytics
  Future<Map<String, dynamic>> getSalesAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final salesEvents = await getAnalyticsData(
        startDate: startDate,
        endDate: endDate,
        eventName: 'business_metric',
      );

      final salesData = <String, dynamic>{
        'totalSales': 0.0,
        'totalOrders': 0,
        'averageOrderValue': 0.0,
        'dailySales': <String, double>{},
        'topProducts': <Map<String, dynamic>>[],
        'salesByCategory': <String, double>{},
        'salesByPaymentMethod': <String, double>{},
      };

      // Process sales data
      final events = salesEvents['eventDetails']?['business_metric'] ?? [];
      for (final event in events) {
        final parameters = event['parameters'];
        final metricName = parameters['metric_name'];
        final value = parameters['value'] ?? 0.0;
        final date = DateFormat('yyyy-MM-dd').format(
          DateTime.fromMillisecondsSinceEpoch(event['timestamp']),
        );

        switch (metricName) {
          case 'daily_sales':
            salesData['totalSales'] += value;
            salesData['dailySales'][date] = (salesData['dailySales'][date] ?? 0.0) + value;
            break;
          case 'order_count':
            salesData['totalOrders'] += value.toInt();
            break;
          case 'product_sales':
            final productName = parameters['product_name'] ?? 'Unknown';
            final existingProduct = salesData['topProducts'].firstWhere(
              (p) => p['name'] == productName,
              orElse: () => {'name': productName, 'sales': 0.0},
            );
            existingProduct['sales'] += value;
            break;
          case 'category_sales':
            final category = parameters['category'] ?? 'Unknown';
            salesData['salesByCategory'][category] = 
                (salesData['salesByCategory'][category] ?? 0.0) + value;
            break;
          case 'payment_method_sales':
            final paymentMethod = parameters['payment_method'] ?? 'Unknown';
            salesData['salesByPaymentMethod'][paymentMethod] = 
                (salesData['salesByPaymentMethod'][paymentMethod] ?? 0.0) + value;
            break;
        }
      }

      // Calculate average order value
      if (salesData['totalOrders'] > 0) {
        salesData['averageOrderValue'] = salesData['totalSales'] / salesData['totalOrders'];
      }

      // Sort top products
      final topProducts = List<Map<String, dynamic>>.from(salesData['topProducts']);
      topProducts.sort((a, b) => b['sales'].compareTo(a['sales']));
      salesData['topProducts'] = topProducts.take(10).toList();

      return salesData;
    } catch (e) {
      ErrorHandler.handleError(e);
      return {};
    }
  }

  /// Get inventory analytics
  Future<Map<String, dynamic>> getInventoryAnalytics() async {
    try {
      final inventoryEvents = await getAnalyticsData(
        eventName: 'business_metric',
      );

      final inventoryData = <String, dynamic>{
        'totalProducts': 0,
        'lowStockProducts': 0,
        'outOfStockProducts': 0,
        'expiringProducts': 0,
        'totalInventoryValue': 0.0,
        'categoryDistribution': <String, int>{},
        'stockMovement': <String, dynamic>{},
      };

      // Process inventory data
      final events = inventoryEvents['eventDetails']?['business_metric'] ?? [];
      for (final event in events) {
        final parameters = event['parameters'];
        final metricName = parameters['metric_name'];
        final value = parameters['value'] ?? 0.0;

        switch (metricName) {
          case 'total_products':
            inventoryData['totalProducts'] = value.toInt();
            break;
          case 'low_stock_products':
            inventoryData['lowStockProducts'] = value.toInt();
            break;
          case 'out_of_stock_products':
            inventoryData['outOfStockProducts'] = value.toInt();
            break;
          case 'expiring_products':
            inventoryData['expiringProducts'] = value.toInt();
            break;
          case 'inventory_value':
            inventoryData['totalInventoryValue'] += value;
            break;
          case 'category_count':
            final category = parameters['category'] ?? 'Unknown';
            inventoryData['categoryDistribution'][category] = value.toInt();
            break;
        }
      }

      return inventoryData;
    } catch (e) {
      ErrorHandler.handleError(e);
      return {};
    }
  }

  /// Get customer analytics
  Future<Map<String, dynamic>> getCustomerAnalytics() async {
    try {
      final customerEvents = await getAnalyticsData(
        eventName: 'business_metric',
      );

      final customerData = <String, dynamic>{
        'totalCustomers': 0,
        'activeCustomers': 0,
        'newCustomers': 0,
        'creditCustomers': 0,
        'totalCreditDues': 0.0,
        'averagePurchaseValue': 0.0,
        'customerRetention': 0.0,
      };

      // Process customer data
      final events = customerEvents['eventDetails']?['business_metric'] ?? [];
      for (final event in events) {
        final parameters = event['parameters'];
        final metricName = parameters['metric_name'];
        final value = parameters['value'] ?? 0.0;

        switch (metricName) {
          case 'total_customers':
            customerData['totalCustomers'] = value.toInt();
            break;
          case 'active_customers':
            customerData['activeCustomers'] = value.toInt();
            break;
          case 'new_customers':
            customerData['newCustomers'] = value.toInt();
            break;
          case 'credit_customers':
            customerData['creditCustomers'] = value.toInt();
            break;
          case 'credit_dues':
            customerData['totalCreditDues'] += value;
            break;
          case 'average_purchase_value':
            customerData['averagePurchaseValue'] = value;
            break;
          case 'customer_retention':
            customerData['customerRetention'] = value;
            break;
        }
      }

      return customerData;
    } catch (e) {
      ErrorHandler.handleError(e);
      return {};
    }
  }

  /// Get performance analytics
  Future<Map<String, dynamic>> getPerformanceAnalytics() async {
    try {
      final performanceEvents = await getAnalyticsData(
        eventName: 'performance',
      );

      final performanceData = <String, dynamic>{
        'averageLoadTime': 0.0,
        'slowOperations': <Map<String, dynamic>>[],
        'errorRate': 0.0,
        'crashRate': 0.0,
      };

      final events = performanceEvents['eventDetails']?['performance'] ?? [];
      if (events.isNotEmpty) {
        final totalDuration = events.fold(0, (sum, event) => sum + (event['parameters']['duration_ms'] ?? 0));
        performanceData['averageLoadTime'] = totalDuration / events.length;

        // Find slow operations
        final slowOperations = events.where((event) => 
          (event['parameters']['duration_ms'] ?? 0) > 1000).toList();
        performanceData['slowOperations'] = slowOperations;
      }

      return performanceData;
    } catch (e) {
      ErrorHandler.handleError(e);
      return {};
    }
  }

  /// Export analytics data
  Future<Map<String, dynamic>> exportAnalyticsData() async {
    try {
      final events = <Map<String, dynamic>>[];
      final keys = _eventsBox.keys;

      for (final key in keys) {
        final eventData = _eventsBox.get(key);
        if (eventData != null) {
          events.add(jsonDecode(eventData));
        }
      }

      return {
        'exportDate': DateTime.now().toIso8601String(),
        'totalEvents': events.length,
        'events': events,
      };
    } catch (e) {
      ErrorHandler.handleError(e);
      return {};
    }
  }

  /// Clear analytics data
  Future<void> clearAnalyticsData() async {
    try {
      await _eventsBox.clear();
      await _analyticsBox.clear();
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  /// Get analytics summary
  Future<Map<String, dynamic>> getAnalyticsSummary() async {
    try {
      final salesAnalytics = await getSalesAnalytics();
      final inventoryAnalytics = await getInventoryAnalytics();
      final customerAnalytics = await getCustomerAnalytics();
      final performanceAnalytics = await getPerformanceAnalytics();

      return {
        'sales': salesAnalytics,
        'inventory': inventoryAnalytics,
        'customers': customerAnalytics,
        'performance': performanceAnalytics,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      ErrorHandler.handleError(e);
      return {};
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _analyticsBox.close();
    await _eventsBox.close();
  }
}