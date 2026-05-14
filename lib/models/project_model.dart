// ============================================================================
// MAHMOUD TECH - Project Model
// نموذج المشروع الكامل
// ============================================================================

import 'package:mahmoud_ai/constants/app_constants.dart';
import 'package:mahmoud_ai/models/scene_model.dart';
import 'package:mahmoud_ai/models/caption_model.dart';

class ProjectModel {
  final String id;
  String name;
  String script;
  String style;
  String aspectRatio;
  String language;
  ProjectStatus status;
  List<SceneModel> scenes;
  double progress;
  GenerationPhase currentPhase;
  DateTime createdAt;
  DateTime updatedAt;
  String? videoPath;
  String? audioPath;
  List<String> errorLog;
  String? summary;
  String voiceGender; // 'male', 'female'
  String voiceId;
  String captionStyle; // 'classic', 'modern', 'dynamic'
  List<CaptionModel> captions;

  ProjectModel({
    required this.id,
    this.name = 'مشروع جديد',
    this.script = '',
    this.style = 'cinematic',
    this.aspectRatio = '9:16',
    this.language = 'ar',
    this.status = ProjectStatus.draft,
    List<SceneModel>? scenes,
    this.progress = 0.0,
    this.currentPhase = GenerationPhase.analyzing,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.videoPath,
    this.audioPath,
    List<String>? errorLog,
    this.summary,
    this.voiceGender = 'male',
    this.voiceId = 'pNInz6OB8ntYPLMCSXT6', // Adam (ElevenLabs)
    this.captionStyle = 'dynamic',
    List<CaptionModel>? captions,
  })  : scenes = scenes ?? [],
        errorLog = errorLog ?? [],
        captions = captions ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// عدد الكلمات في السكريبت
  int get wordCount {
    if (script.trim().isEmpty) return 0;
    return script.trim().split(RegExp(r'\s+')).length;
  }

  /// المدة الإجمالية المتوقعة للفيديو
  double get totalDuration {
    if (scenes.isEmpty) return 0;
    return scenes.fold(0.0, (sum, scene) => sum + scene.duration);
  }

  /// عدد المشاهد المكتملة التوليد
  int get completedScenes {
    return scenes.where((s) => s.imageGenerated).length;
  }

  /// هل المشروع مكتمل
  bool get isCompleted => status == ProjectStatus.completed;

  /// هل يمكن بدء التوليد
  bool get canGenerate =>
      script.trim().isNotEmpty && wordCount >= AppConstants.minScriptWords;

  /// اسم النمط بالعربية
  String get styleNameAr {
    final found = AppConstants.videoStyles.firstWhere(
      (s) => s['id'] == style,
      orElse: () => {'name': 'سينمائي'},
    );
    return found['name'] ?? 'سينمائي';
  }

  /// أيقونة النمط
  String get styleIcon {
    final found = AppConstants.videoStyles.firstWhere(
      (s) => s['id'] == style,
      orElse: () => {'icon': '🎬'},
    );
    return found['icon'] ?? '🎬';
  }

  /// تحويل المشروع إلى Map للتخزين
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'script': script,
      'style': style,
      'aspectRatio': aspectRatio,
      'language': language,
      'status': status.index,
      'scenes': scenes.map((s) => s.toJson()).toList(),
      'progress': progress,
      'currentPhase': currentPhase.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'videoPath': videoPath,
      'audioPath': audioPath,
      'errorLog': errorLog,
      'summary': summary,
      'voiceGender': voiceGender,
      'voiceId': voiceId,
      'captionStyle': captionStyle,
      'captions': captions.map((c) => c.toJson()).toList(),
    };
  }

  /// إنشاء مشروع من Map مخزّن
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'مشروع جديد',
      script: json['script'] ?? '',
      style: json['style'] ?? 'cinematic',
      aspectRatio: json['aspectRatio'] ?? '9:16',
      language: json['language'] ?? 'ar',
      status: ProjectStatus.values[json['status'] ?? 0],
      scenes: (json['scenes'] as List<dynamic>?)
              ?.map((s) => SceneModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      progress: (json['progress'] ?? 0.0).toDouble(),
      currentPhase: GenerationPhase.values[json['currentPhase'] ?? 0],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      videoPath: json['videoPath'],
      audioPath: json['audioPath'],
      errorLog: (json['errorLog'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      summary: json['summary'],
      voiceGender: json['voiceGender'] ?? 'male',
      voiceId: json['voiceId'] ?? 'pNInz6OB8ntYPLMCSXT6',
      captionStyle: json['captionStyle'] ?? 'dynamic',
      captions: (json['captions'] as List<dynamic>?)
              ?.map((c) => CaptionModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// نسخة معدّلة من المشروع
  ProjectModel copyWith({
    String? name,
    String? script,
    String? style,
    String? aspectRatio,
    String? language,
    ProjectStatus? status,
    List<SceneModel>? scenes,
    double? progress,
    GenerationPhase? currentPhase,
    String? videoPath,
    String? audioPath,
    List<String>? errorLog,
    String? summary,
    String? voiceGender,
    String? voiceId,
    String? captionStyle,
    List<CaptionModel>? captions,
  }) {
    return ProjectModel(
      id: id,
      name: name ?? this.name,
      script: script ?? this.script,
      style: style ?? this.style,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      language: language ?? this.language,
      status: status ?? this.status,
      scenes: scenes ?? this.scenes,
      progress: progress ?? this.progress,
      currentPhase: currentPhase ?? this.currentPhase,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      videoPath: videoPath ?? this.videoPath,
      audioPath: audioPath ?? this.audioPath,
      errorLog: errorLog ?? this.errorLog,
      summary: summary ?? this.summary,
      voiceGender: voiceGender ?? this.voiceGender,
      voiceId: voiceId ?? this.voiceId,
      captionStyle: captionStyle ?? this.captionStyle,
      captions: captions ?? this.captions,
    );
  }
}
