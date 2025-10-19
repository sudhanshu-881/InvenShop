import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'app_config.dart';
import 'app_export.dart';

class OfflineManager {
  static final OfflineManager _instance = OfflineManager._internal();
  factory OfflineManager() => _instance;
  OfflineManager._internal();

  late Box _localBox;
  late Dio _dio;
  bool _isOnline = false;
  List<Map<String, dynamic>> _pendingOperations = [];

  /// Initialize offline manager
  Future<void> initialize() async {
    // Initialize Hive box for local storage
    _localBox = await Hive.openBox('invenshop_offline_data');
    
    // Initialize Dio for network requests
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.apiTimeout),
      receiveTimeout: Duration(milliseconds: AppConfig.apiTimeout),
    ));

    // Check initial connectivity
    await _checkConnectivity();
    
    // Start connectivity monitoring
    _startConnectivityMonitoring();
    
    // Start sync process
    _startSyncProcess();
  }

  /// Check network connectivity
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _isOnline = connectivityResult != ConnectivityResult.none;
    } catch (e) {
      _isOnline = false;
    }
  }

  /// Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _isOnline = result != ConnectivityResult.none;
      
      if (_isOnline) {
        _syncPendingOperations();
      }
    });
  }

  /// Start periodic sync process
  void _startSyncProcess() {
    if (AppConfig.enableOfflineMode) {
      Future.delayed(AppConfig.syncInterval, () {
        if (_isOnline) {
          _syncPendingOperations();
        }
        _startSyncProcess();
      });
    }
  }

  /// Save data locally
  Future<void> saveData(String key, Map<String, dynamic> data) async {
    try {
      // Add timestamp for sync tracking
      data['_localTimestamp'] = DateTime.now().millisecondsSinceEpoch;
      data['_synced'] = false;
      
      // Save to local storage
      await _localBox.put(key, jsonEncode(data));
      
      // Add to pending operations if offline
      if (!_isOnline) {
        _pendingOperations.add({
          'operation': 'save',
          'key': key,
          'data': data,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        // Try to sync immediately if online
        await _syncData(key, data);
      }
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  /// Get data from local storage
  Future<Map<String, dynamic>?> getData(String key) async {
    try {
      final data = _localBox.get(key);
      if (data != null) {
        return jsonDecode(data);
      }
      return null;
    } catch (e) {
      ErrorHandler.handleError(e);
      return null;
    }
  }

  /// Get all data of a specific type
  Future<List<Map<String, dynamic>>> getAllData(String type) async {
    try {
      final List<Map<String, dynamic>> result = [];
      final keys = _localBox.keys.where((key) => key.toString().startsWith(type));
      
      for (final key in keys) {
        final data = await getData(key.toString());
        if (data != null) {
          result.add(data);
        }
      }
      
      return result;
    } catch (e) {
      ErrorHandler.handleError(e);
      return [];
    }
  }

  /// Delete data locally
  Future<void> deleteData(String key) async {
    try {
      await _localBox.delete(key);
      
      // Add to pending operations if offline
      if (!_isOnline) {
        _pendingOperations.add({
          'operation': 'delete',
          'key': key,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        // Try to sync immediately if online
        await _syncDelete(key);
      }
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  /// Update data locally
  Future<void> updateData(String key, Map<String, dynamic> data) async {
    try {
      // Add timestamp for sync tracking
      data['_localTimestamp'] = DateTime.now().millisecondsSinceEpoch;
      data['_synced'] = false;
      
      // Update local storage
      await _localBox.put(key, jsonEncode(data));
      
      // Add to pending operations if offline
      if (!_isOnline) {
        _pendingOperations.add({
          'operation': 'update',
          'key': key,
          'data': data,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        // Try to sync immediately if online
        await _syncData(key, data);
      }
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  /// Sync data with server
  Future<void> _syncData(String key, Map<String, dynamic> data) async {
    try {
      // Remove local metadata before sending
      final syncData = Map<String, dynamic>.from(data);
      syncData.remove('_localTimestamp');
      syncData.remove('_synced');
      
      // Determine endpoint based on key prefix
      String endpoint = _getEndpointForKey(key);
      
      // Make API call
      await _dio.post(endpoint, data: syncData);
      
      // Mark as synced
      data['_synced'] = true;
      await _localBox.put(key, jsonEncode(data));
      
    } catch (e) {
      // If sync fails, add to pending operations
      _pendingOperations.add({
        'operation': 'save',
        'key': key,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      ErrorHandler.handleError(e);
    }
  }

  /// Sync delete with server
  Future<void> _syncDelete(String key) async {
    try {
      String endpoint = _getEndpointForKey(key);
      await _dio.delete('$endpoint/$key');
    } catch (e) {
      // If sync fails, add to pending operations
      _pendingOperations.add({
        'operation': 'delete',
        'key': key,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      ErrorHandler.handleError(e);
    }
  }

  /// Get API endpoint based on key prefix
  String _getEndpointForKey(String key) {
    if (key.startsWith('product_')) {
      return '/products';
    } else if (key.startsWith('customer_')) {
      return '/customers';
    } else if (key.startsWith('bill_')) {
      return '/bills';
    } else if (key.startsWith('category_')) {
      return '/categories';
    } else if (key.startsWith('supplier_')) {
      return '/suppliers';
    } else {
      return '/data';
    }
  }

  /// Sync all pending operations
  Future<void> _syncPendingOperations() async {
    if (_pendingOperations.isEmpty || !_isOnline) return;
    
    final operations = List<Map<String, dynamic>>.from(_pendingOperations);
    _pendingOperations.clear();
    
    for (final operation in operations) {
      try {
        switch (operation['operation']) {
          case 'save':
          case 'update':
            await _syncData(operation['key'], operation['data']);
            break;
          case 'delete':
            await _syncDelete(operation['key']);
            break;
        }
      } catch (e) {
        // Re-add failed operations to pending list
        _pendingOperations.add(operation);
        ErrorHandler.handleError(e);
      }
    }
  }

  /// Force sync all data
  Future<void> forceSync() async {
    if (!_isOnline) {
      throw Exception('No internet connection');
    }
    
    await _syncPendingOperations();
    
    // Sync all unsynced data
    final keys = _localBox.keys;
    for (final key in keys) {
      final data = await getData(key.toString());
      if (data != null && data['_synced'] != true) {
        await _syncData(key.toString(), data);
      }
    }
  }

  /// Get sync status
  Map<String, dynamic> getSyncStatus() {
    return {
      'isOnline': _isOnline,
      'pendingOperations': _pendingOperations.length,
      'lastSync': _getLastSyncTime(),
    };
  }

  /// Get last sync time
  DateTime? _getLastSyncTime() {
    final lastSync = _localBox.get('_lastSync');
    if (lastSync != null) {
      return DateTime.fromMillisecondsSinceEpoch(lastSync);
    }
    return null;
  }

  /// Set last sync time
  Future<void> _setLastSyncTime() async {
    await _localBox.put('_lastSync', DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear all local data
  Future<void> clearAllData() async {
    try {
      await _localBox.clear();
      _pendingOperations.clear();
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  /// Get data size
  int getDataSize() {
    return _localBox.length;
  }

  /// Check if data exists
  bool hasData(String key) {
    return _localBox.containsKey(key);
  }

  /// Get all keys
  Iterable<dynamic> getAllKeys() {
    return _localBox.keys;
  }

  /// Search data
  Future<List<Map<String, dynamic>>> searchData(String query, String type) async {
    try {
      final List<Map<String, dynamic>> result = [];
      final keys = _localBox.keys.where((key) => key.toString().startsWith(type));
      
      for (final key in keys) {
        final data = await getData(key.toString());
        if (data != null && _matchesQuery(data, query)) {
          result.add(data);
        }
      }
      
      return result;
    } catch (e) {
      ErrorHandler.handleError(e);
      return [];
    }
  }

  /// Check if data matches search query
  bool _matchesQuery(Map<String, dynamic> data, String query) {
    final queryLower = query.toLowerCase();
    
    for (final value in data.values) {
      if (value is String && value.toLowerCase().contains(queryLower)) {
        return true;
      }
    }
    
    return false;
  }

  /// Export data for backup
  Future<Map<String, dynamic>> exportData() async {
    try {
      final Map<String, dynamic> exportData = {};
      final keys = _localBox.keys;
      
      for (final key in keys) {
        final data = await getData(key.toString());
        if (data != null) {
          exportData[key.toString()] = data;
        }
      }
      
      return exportData;
    } catch (e) {
      ErrorHandler.handleError(e);
      return {};
    }
  }

  /// Import data from backup
  Future<void> importData(Map<String, dynamic> data) async {
    try {
      for (final entry in data.entries) {
        await _localBox.put(entry.key, jsonEncode(entry.value));
      }
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  /// Clean up old data
  Future<void> cleanupOldData() async {
    try {
      final now = DateTime.now();
      final keys = _localBox.keys.toList();
      
      for (final key in keys) {
        final data = await getData(key.toString());
        if (data != null) {
          final timestamp = data['_localTimestamp'];
          if (timestamp != null) {
            final dataTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final age = now.difference(dataTime);
            
            // Delete data older than retention period
            if (age > AppConfig.dataRetentionPeriod) {
              await _localBox.delete(key);
            }
          }
        }
      }
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _localBox.close();
  }
}