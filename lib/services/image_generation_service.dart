// ============================================================================
// MAHMOUD TECH - Image Generation Service
// خدمة توليد الصور لكل مشهد
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mahmoud_ai/constants/app_constants.dart';

class ImageGenerationService {
  static final ImageGenerationService _instance = ImageGenerationService._();
  factory ImageGenerationService() => _instance;
  ImageGenerationService._();

  /// توليد صورة من prompt بصري
  /// يرجع البيانات الثنائية للصورة (bytes)
  Future<Uint8List> generateImage({
    required String prompt,
    required String apiKey,
    String aspectRatio = '9:16',
    int retryCount = 0,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('مفتاح توليد الصور غير موجود. الرجاء إدخاله في الإعدادات.');
    }

    // تحديد الأبعاد
    final dims = AppConstants.videoDimensions[aspectRatio] ??
        AppConstants.videoDimensions['9:16']!;
    final width = dims['width']!;
    final height = dims['height']!;

    // تحسين الـ prompt للحصول على نتائج أفضل
    final enhancedPrompt =
        '$prompt, ultra high quality, 8K resolution, cinematic lighting, '
        'professional photography, sharp details, vibrant colors, '
        'masterpiece, best quality';

    try {
      // استخدام Stability AI API
      final response = await http.post(
        Uri.parse('${AppConstants.imageBaseUrl}/generation/stable-diffusion-xl-1024-v1-0/text-to-image'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'text_prompts': [
            {
              'text': enhancedPrompt,
              'weight': 1.0,
            },
            {
              'text': 'blurry, low quality, distorted, ugly, bad anatomy, watermark, text',
              'weight': -1.0,
            },
          ],
          'cfg_scale': 7,
          'width': _clampDimension(width),
          'height': _clampDimension(height),
          'samples': 1,
          'steps': 30,
          'style_preset': 'cinematic',
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final artifacts = data['artifacts'] as List;
        if (artifacts.isNotEmpty) {
          final base64Image = artifacts[0]['base64'] as String;
          return base64Decode(base64Image);
        }
        throw Exception('لم يتم توليد أي صورة');
      } else if (response.statusCode == 401) {
        throw Exception('مفتاح API للصور غير صالح.');
      } else if (response.statusCode == 429) {
        // إعادة المحاولة بعد تأخير
        if (retryCount < AppConstants.maxRetries) {
          await Future.delayed(
              Duration(seconds: AppConstants.retryDelay.inSeconds * (retryCount + 1)));
          return generateImage(
            prompt: prompt,
            apiKey: apiKey,
            aspectRatio: aspectRatio,
            retryCount: retryCount + 1,
          );
        }
        throw Exception('تم تجاوز الحد المسموح. الرجاء المحاولة لاحقاً.');
      } else {
        throw Exception('فشل توليد الصورة (${response.statusCode})');
      }
    } catch (e) {
      // إعادة المحاولة عند فشل الاتصال
      if (retryCount < AppConstants.maxRetries && e is! Exception) {
        await Future.delayed(AppConstants.retryDelay);
        return generateImage(
          prompt: prompt,
          apiKey: apiKey,
          aspectRatio: aspectRatio,
          retryCount: retryCount + 1,
        );
      }
      if (e is Exception) rethrow;
      throw Exception('خطأ في توليد الصورة: $e');
    }
  }

  /// تقريب الأبعاد لتتوافق مع متطلبات Stability AI
  int _clampDimension(int dim) {
    // Stability AI يتطلب أبعاد مضاعفات 64
    // وبين 128 و 2048
    int clamped = (dim ~/ 64) * 64;
    if (clamped < 128) clamped = 128;
    if (clamped > 2048) clamped = 2048;
    // للـ SDXL الأبعاد المدعومة
    if (clamped > 1024) clamped = 1024;
    return clamped;
  }

  /// إنشاء صورة placeholder عند الفشل
  Uint8List getPlaceholderImage() {
    // إرجاع بيانات PNG شفافة بسيطة 1x1
    return Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
      0x54, 0x78, 0x9C, 0x62, 0x00, 0x00, 0x00, 0x02,
      0x00, 0x01, 0xE5, 0x27, 0xDE, 0xFC, 0x00, 0x00,
      0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
      0x60, 0x82,
    ]);
  }

  /// اختبار الاتصال بالخدمة
  Future<bool> testConnection(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.imageBaseUrl}/user/account'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
