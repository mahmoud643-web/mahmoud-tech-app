// ============================================================================
// MAHMOUD TECH - App Constants
// ثوابت التطبيق العامة
// ============================================================================

class AppConstants {
  // اسم التطبيق
  static const String appName = 'MAHMOUD TECH';
  static const String appIcon = '🎬';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'استوديو إنشاء فيديوهات Shorts الذكي';

  // مفاتيح التخزين المحلي
  static const String keyGroqApiKey = 'groq_api_key';
  static const String keyImageApiKey = 'image_api_key';
  static const String keyAudioApiKey = 'audio_api_key';
  static const String keyDarkMode = 'dark_mode';
  static const String keyLanguage = 'language';
  static const String keyProjects = 'projects';
  static const String keyLastProjectId = 'last_project_id';

  // إعدادات API
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String groqModel = 'llama-3.3-70b-versatile';
  static const String imageBaseUrl = 'https://api.stability.ai/v1';
  static const String audioBaseUrl = 'https://api.elevenlabs.io/v1';

  // أبعاد الفيديو
  static const Map<String, Map<String, int>> videoDimensions = {
    '9:16': {'width': 1080, 'height': 1920},
    '16:9': {'width': 1920, 'height': 1080},
    '1:1': {'width': 1080, 'height': 1080},
  };

  // أنماط الفيديو
  static const List<Map<String, String>> videoStyles = [
    {'id': 'historical', 'name': 'تاريخي', 'icon': '🏛️'},
    {'id': 'tourism', 'name': 'سياحي', 'icon': '✈️'},
    {'id': 'documentary', 'name': 'وثائقي', 'icon': '📽️'},
    {'id': 'narrative', 'name': 'قصصي', 'icon': '📖'},
    {'id': 'cinematic', 'name': 'سينمائي', 'icon': '🎬'},
  ];

  // مدد المشاهد الافتراضية (بالثواني)
  static const double defaultSceneDuration = 4.0;
  static const double minSceneDuration = 2.0;
  static const double maxSceneDuration = 8.0;
  static const double maxShortsDuration = 60.0;

  // حدود السكريبت
  static const int maxScriptWords = 500;
  static const int minScriptWords = 10;
  static const int maxScenes = 15;
  static const int minScenes = 3;

  // إعدادات إعادة المحاولة
  static const int maxRetries = 2;
  static const Duration retryDelay = Duration(seconds: 2);

  // لغات مدعومة
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'en', 'name': 'English'},
  ];

  // خيارات الأصوات
  static const List<Map<String, String>> voiceOptions = [
    {
      'id': 'pNInz6OB8ntYPLMCSXT6',
      'name': 'آدم (رجل)',
      'gender': 'male',
      'icon': '👨‍💼'
    },
    {
      'id': 'EXAVITQu4vr4xnSDxMaL',
      'name': 'بيلا (امرأة)',
      'gender': 'female',
      'icon': '👩‍💼'
    },
    {
      'id': 'onwK4e9ZLuTAKqWW03F9',
      'name': 'دانيال (رجل عميق)',
      'gender': 'male',
      'icon': '🧔'
    },
    {
      'id': 'AZnzlk1Xhk9WfS68Z8S6',
      'name': 'نيكول (امرأة ناعمة)',
      'gender': 'female',
      'icon': '👩‍🎤'
    },
  ];

  // أنماط الكابشنز
  static const List<Map<String, String>> captionStyles = [
    {'id': 'classic', 'name': 'كلاسيكي', 'icon': '📜'},
    {'id': 'modern', 'name': 'عصري', 'icon': '📱'},
    {'id': 'dynamic', 'name': 'ديناميكي (متحرك)', 'icon': '⚡'},
    {'id': 'none', 'name': 'بدون كابشنز', 'icon': '🚫'},
  ];
}

// حالات المشروع
enum ProjectStatus {
  draft,
  analyzing,
  generating,
  completed,
  failed,
}

extension ProjectStatusExtension on ProjectStatus {
  String get nameAr {
    switch (this) {
      case ProjectStatus.draft:
        return 'مسودة';
      case ProjectStatus.analyzing:
        return 'جارٍ التحليل';
      case ProjectStatus.generating:
        return 'جارٍ التوليد';
      case ProjectStatus.completed:
        return 'مكتمل';
      case ProjectStatus.failed:
        return 'فشل';
    }
  }

  String get icon {
    switch (this) {
      case ProjectStatus.draft:
        return '📝';
      case ProjectStatus.analyzing:
        return '🔍';
      case ProjectStatus.generating:
        return '⚙️';
      case ProjectStatus.completed:
        return '✅';
      case ProjectStatus.failed:
        return '❌';
    }
  }
}

// مراحل التوليد
enum GenerationPhase {
  analyzing,
  creatingScenes,
  generatingImages,
  composingVideo,
  preparingExport,
  done,
}

extension GenerationPhaseExtension on GenerationPhase {
  String get nameAr {
    switch (this) {
      case GenerationPhase.analyzing:
        return 'تحليل النص';
      case GenerationPhase.creatingScenes:
        return 'إنشاء المشاهد';
      case GenerationPhase.generatingImages:
        return 'توليد الصور';
      case GenerationPhase.composingVideo:
        return 'تركيب الفيديو';
      case GenerationPhase.preparingExport:
        return 'تجهيز التصدير';
      case GenerationPhase.done:
        return 'اكتمل';
    }
  }

  double get progressWeight {
    switch (this) {
      case GenerationPhase.analyzing:
        return 0.1;
      case GenerationPhase.creatingScenes:
        return 0.15;
      case GenerationPhase.generatingImages:
        return 0.5;
      case GenerationPhase.composingVideo:
        return 0.2;
      case GenerationPhase.preparingExport:
        return 0.05;
      case GenerationPhase.done:
        return 0.0;
    }
  }
}
