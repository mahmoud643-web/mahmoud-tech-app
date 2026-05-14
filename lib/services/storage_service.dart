// ============================================================================
// MAHMOUD TECH - Storage Service
// خدمة التخزين المحلي للمشاريع والإعدادات
// ============================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mahmoud_ai/constants/app_constants.dart';
import 'package:mahmoud_ai/models/project_model.dart';

class StorageService {
  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  /// الحصول على النسخة الوحيدة من الخدمة
  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // ==================== إعدادات API ====================

  /// حفظ مفتاح Groq API
  Future<void> saveGroqApiKey(String key) async {
    await _prefs.setString(AppConstants.keyGroqApiKey, key);
  }

  /// جلب مفتاح Groq API
  String getGroqApiKey() {
    return _prefs.getString(AppConstants.keyGroqApiKey) ?? '';
  }

  /// حفظ مفتاح Image API
  Future<void> saveImageApiKey(String key) async {
    await _prefs.setString(AppConstants.keyImageApiKey, key);
  }

  /// جلب مفتاح Image API
  String getImageApiKey() {
    return _prefs.getString(AppConstants.keyImageApiKey) ?? '';
  }

  /// حفظ مفتاح Audio API
  Future<void> saveAudioApiKey(String key) async {
    await _prefs.setString(AppConstants.keyAudioApiKey, key);
  }

  /// جلب مفتاح Audio API
  String getAudioApiKey() {
    return _prefs.getString(AppConstants.keyAudioApiKey) ?? '';
  }

  // ==================== الإعدادات العامة ====================

  /// حفظ الوضع الداكن
  Future<void> saveDarkMode(bool isDark) async {
    await _prefs.setBool(AppConstants.keyDarkMode, isDark);
  }

  /// جلب الوضع الداكن
  bool getDarkMode() {
    return _prefs.getBool(AppConstants.keyDarkMode) ?? true;
  }

  /// حفظ اللغة
  Future<void> saveLanguage(String langCode) async {
    await _prefs.setString(AppConstants.keyLanguage, langCode);
  }

  /// جلب اللغة
  String getLanguage() {
    return _prefs.getString(AppConstants.keyLanguage) ?? 'ar';
  }

  // ==================== إدارة المشاريع ====================

  /// حفظ قائمة المشاريع
  Future<void> saveProjects(List<ProjectModel> projects) async {
    final jsonList = projects.map((p) => p.toJson()).toList();
    await _prefs.setString(AppConstants.keyProjects, jsonEncode(jsonList));
  }

  /// جلب قائمة المشاريع
  List<ProjectModel> getProjects() {
    final jsonString = _prefs.getString(AppConstants.keyProjects);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((j) => ProjectModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// حفظ مشروع واحد (إضافة أو تحديث)
  Future<void> saveProject(ProjectModel project) async {
    final projects = getProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      projects[index] = project;
    } else {
      projects.insert(0, project);
    }
    await saveProjects(projects);
  }

  /// حذف مشروع
  Future<void> deleteProject(String projectId) async {
    final projects = getProjects();
    projects.removeWhere((p) => p.id == projectId);
    await saveProjects(projects);
  }

  /// جلب مشروع بالمعرّف
  ProjectModel? getProject(String projectId) {
    final projects = getProjects();
    try {
      return projects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      return null;
    }
  }

  /// حفظ آخر مشروع مفتوح
  Future<void> saveLastProjectId(String id) async {
    await _prefs.setString(AppConstants.keyLastProjectId, id);
  }

  /// جلب آخر مشروع مفتوح
  String? getLastProjectId() {
    return _prefs.getString(AppConstants.keyLastProjectId);
  }

  // ==================== الكاش ====================

  /// مسح الكاش
  Future<void> clearCache() async {
    final groqKey = getGroqApiKey();
    final imageKey = getImageApiKey();
    final audioKey = getAudioApiKey();
    final isDark = getDarkMode();
    final lang = getLanguage();

    await _prefs.clear();

    // إعادة حفظ الإعدادات المهمة
    await saveGroqApiKey(groqKey);
    await saveImageApiKey(imageKey);
    await saveAudioApiKey(audioKey);
    await saveDarkMode(isDark);
    await saveLanguage(lang);
  }

  /// مسح كل البيانات
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
