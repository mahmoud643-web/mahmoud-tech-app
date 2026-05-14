// ============================================================================
// MAHMOUD TECH - App Provider
// مزوّد الحالة العامة للتطبيق (ثيم، لغة، اتصال)
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mahmoud_ai/services/storage_service.dart';
import 'package:mahmoud_ai/services/connectivity_service.dart';

class AppProvider extends ChangeNotifier {
  late StorageService _storage;
  final ConnectivityService _connectivity = ConnectivityService();
  StreamSubscription<bool>? _connectivitySub;

  bool _isDarkMode = true;
  String _language = 'ar';
  bool _isConnected = true;
  bool _isInitialized = false;

  // Getters
  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;
  bool get isArabic => _language == 'ar';

  /// تهيئة المزوّد
  Future<void> initialize() async {
    _storage = await StorageService.getInstance();
    _isDarkMode = _storage.getDarkMode();
    _language = _storage.getLanguage();

    // بدء مراقبة الاتصال
    _connectivity.startMonitoring();
    _connectivitySub = _connectivity.connectionStream.listen((connected) {
      _isConnected = connected;
      notifyListeners();
    });

    // فحص أولي
    _isConnected = await _connectivity.checkConnection();
    _isInitialized = true;
    notifyListeners();
  }

  /// تبديل الوضع الداكن/الفاتح
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _storage.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  /// تعيين الوضع الداكن/الفاتح
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _storage.saveDarkMode(value);
    notifyListeners();
  }

  /// تغيير اللغة
  Future<void> setLanguage(String langCode) async {
    _language = langCode;
    await _storage.saveLanguage(langCode);
    notifyListeners();
  }

  /// فحص الاتصال يدوياً
  Future<bool> checkConnection() async {
    _isConnected = await _connectivity.checkConnection();
    notifyListeners();
    return _isConnected;
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _connectivity.dispose();
    super.dispose();
  }
}
