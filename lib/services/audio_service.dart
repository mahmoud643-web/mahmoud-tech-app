// ============================================================================
// MAHMOUD TECH - Audio Service
// خدمة توليد الصوت للسكريبت (Text-To-Speech)
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mahmoud_ai/constants/app_constants.dart';

class AudioService {
  static final AudioService _instance = AudioService._();
  factory AudioService() => _instance;
  AudioService._();

  /// توليد صوت للسكريبت بالكامل
  /// يرجع البيانات الثنائية للصوت (mp3 bytes)
  Future<Uint8List> generateAudio({
    required String text,
    required String apiKey,
    String voiceId = 'pNInz6OB8ntYPLMCSXT6',
    int retryCount = 0,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('مفتاح ElevenLabs API غير موجود. الرجاء إدخاله في الإعدادات لتفعيل الصوت.');
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.audioBaseUrl}/text-to-speech/$voiceId'),
        headers: {
          'Content-Type': 'application/json',
          'xi-api-key': apiKey,
          'Accept': 'audio/mpeg',
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_multilingual_v2', // يدعم العربية
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
            'style': 0.0,
            'use_speaker_boost': true,
          }
        }),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 401) {
        throw Exception('مفتاح API للصوت غير صالح.');
      } else if (response.statusCode == 429) {
        if (retryCount < AppConstants.maxRetries) {
          await Future.delayed(
              Duration(seconds: AppConstants.retryDelay.inSeconds * (retryCount + 1)));
          return generateAudio(
            text: text,
            apiKey: apiKey,
            retryCount: retryCount + 1,
          );
        }
        throw Exception('تم تجاوز الحد المسموح. الرجاء المحاولة لاحقاً.');
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        throw Exception('فشل توليد الصوت (${response.statusCode}): $errorBody');
      }
    } catch (e) {
      if (retryCount < AppConstants.maxRetries && e is! Exception) {
        await Future.delayed(AppConstants.retryDelay);
        return generateAudio(
          text: text,
          apiKey: apiKey,
          retryCount: retryCount + 1,
        );
      }
      if (e is Exception) rethrow;
      throw Exception('خطأ في توليد الصوت: $e');
    }
  }

  /// اختبار الاتصال بالخدمة
  Future<bool> testConnection(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.audioBaseUrl}/user'),
        headers: {
          'xi-api-key': apiKey,
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
