// ============================================================================
// MAHMOUD TECH - Connectivity Service
// خدمة فحص الاتصال بالإنترنت
// ============================================================================

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;
  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  /// بدء مراقبة الاتصال
  void startMonitoring() {
    _connectivity.onConnectivityChanged.listen((results) async {
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        _updateConnection(false);
      } else {
        // تحقق فعلي من الإنترنت
        final hasInternet = await _checkInternet();
        _updateConnection(hasInternet);
      }
    });
    // فحص أولي
    checkConnection();
  }

  /// فحص الاتصال يدوياً
  Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result.isEmpty || result.contains(ConnectivityResult.none)) {
        _updateConnection(false);
        return false;
      }
      final hasInternet = await _checkInternet();
      _updateConnection(hasInternet);
      return hasInternet;
    } catch (e) {
      _updateConnection(false);
      return false;
    }
  }

  /// التحقق الفعلي من الوصول للإنترنت
  Future<bool> _checkInternet() async {
    // تجاوز الفحص المعمق في حالة الويب لتجنب مشاكل CORS
    if (kIsWeb) return true;
    
    try {
      final response = await http
          .get(Uri.parse('https://api.ipify.org'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void _updateConnection(bool isConnected) {
    _isConnected = isConnected;
    _connectionController.add(isConnected);
  }

  void dispose() {
    _connectionController.close();
  }
}
