// ============================================================================
// MAHMOUD TECH - Groq AI Service
// خدمة تحليل السكريبت وفهم النص باستخدام Groq API
// ============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mahmoud_ai/constants/app_constants.dart';
import 'package:mahmoud_ai/models/scene_model.dart';
import 'package:uuid/uuid.dart';

class GroqService {
  static final GroqService _instance = GroqService._();
  factory GroqService() => _instance;
  GroqService._();

  final _uuid = const Uuid();

  /// تحليل السكريبت وتقسيمه إلى مشاهد
  Future<Map<String, dynamic>> analyzeScript({
    required String script,
    required String style,
    required String aspectRatio,
    required String apiKey,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('مفتاح Groq API غير موجود. الرجاء إدخاله في الإعدادات.');
    }

    final styleNameAr = AppConstants.videoStyles
        .firstWhere((s) => s['id'] == style, orElse: () => {'name': 'سينمائي'})['name'];

    final systemPrompt = '''
أنت خبير محترف في تحليل السكريبتات وإنشاء مشاهد بصرية لفيديوهات YouTube Shorts.

مهمتك:
1. افهم المعنى العميق للسكريبت
2. قسّمه إلى مشاهد منطقية (3-12 مشهد)
3. لكل مشهد أنشئ وصف بصري مفصل باللغة الإنجليزية لتوليد صورة
4. حدد مدة كل مشهد (2-6 ثوانٍ)
5. حدد أهمية كل مشهد (1-5)

نوع الفيديو: $styleNameAr
أبعاد الفيديو: $aspectRatio

القواعد المهمة:
- كل prompt بصري يجب أن يكون باللغة الإنجليزية ومفصل جداً
- كل prompt يجب أن يتضمن: الإضاءة، الزاوية، الألوان، الأجواء، التفاصيل
- المشاهد يجب أن تكون متسلسلة ومنطقية
- العناوين والأوصاف بالعربية
- الـ prompts البصرية بالإنجليزية

أعد النتيجة كـ JSON بالتنسيق التالي بدون أي نص إضافي:
{
  "summary": "ملخص عربي قصير للسكريبت",
  "scenes": [
    {
      "title": "عنوان المشهد بالعربية",
      "description": "وصف المشهد بالعربية",
      "visualPrompt": "Detailed English visual prompt for image generation, cinematic style, 8K quality, professional lighting...",
      "duration": 4.0,
      "importance": 3
    }
  ]
}
''';

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.groqBaseUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': AppConstants.groqModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': 'حلّل السكريبت التالي وأنشئ مشاهد بصرية له:\n\n$script'},
          ],
          'temperature': 0.7,
          'max_tokens': 4000,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];
        final result = jsonDecode(content) as Map<String, dynamic>;

        // التحقق من صحة البيانات
        if (!result.containsKey('scenes') || (result['scenes'] as List).isEmpty) {
          throw Exception('لم يتم العثور على مشاهد في التحليل');
        }

        return result;
      } else if (response.statusCode == 401) {
        throw Exception('مفتاح API غير صالح. الرجاء التحقق من الإعدادات.');
      } else if (response.statusCode == 429) {
        throw Exception('تم تجاوز الحد المسموح للطلبات. الرجاء المحاولة لاحقاً.');
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        throw Exception('فشل في تحليل السكريبت (${response.statusCode}): $errorBody');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('خطأ في الاتصال بخدمة التحليل: $e');
    }
  }

  /// توليد كابشنز متزامنة زمنياً مع السكريبت
  Future<List<Map<String, dynamic>>> generateCaptions({
    required String script,
    required double totalDuration,
    required String apiKey,
  }) async {
    if (apiKey.isEmpty) return [];

    final systemPrompt = '''
أنت خبير في إنشاء كابشنز (Subtitles) احترافية لفيديوهات Shorts.

مهمتك:
1. تقسيم السكريبت بالكامل إلى جمل قصيرة جداً (3-7 كلمات لكل جملة)
2. تحديد زمن البدء والنهاية لكل جملة بحيث تغطي المدة الإجمالية للفيديو ($totalDuration ثانية)
3. التأكد من أن الكابشنز متسلسلة ولا تتداخل

أعد النتيجة كـ JSON بالتنسيق التالي بدون أي نص إضافي:
{
  "captions": [
    {
      "text": "الجملة القصيرة هنا",
      "startTime": 0.0,
      "endTime": 2.5
    }
  ]
}
''';

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.groqBaseUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': AppConstants.groqModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': 'أنشئ كابشنز متزامنة لهذا السكريبت:\n\n$script'},
          ],
          'temperature': 0.3,
          'max_tokens': 4000,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];
        final result = jsonDecode(content) as Map<String, dynamic>;
        return (result['captions'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  /// تحويل نتيجة التحليل إلى قائمة مشاهد
  List<SceneModel> parseScenes(Map<String, dynamic> analysisResult) {
    final scenesJson = analysisResult['scenes'] as List<dynamic>;
    return scenesJson.map((s) {
      final json = s as Map<String, dynamic>;
      return SceneModel(
        id: _uuid.v4(),
        title: json['title'] ?? 'مشهد بدون عنوان',
        description: json['description'] ?? '',
        visualPrompt: json['visualPrompt'] ?? '',
        duration: (json['duration'] ?? AppConstants.defaultSceneDuration).toDouble(),
        importance: json['importance'] ?? 3,
      );
    }).toList();
  }

  /// اختبار الاتصال بالخدمة
  Future<bool> testConnection(String apiKey) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.groqBaseUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': AppConstants.groqModel,
          'messages': [
            {'role': 'user', 'content': 'Hi'},
          ],
          'max_tokens': 5,
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
