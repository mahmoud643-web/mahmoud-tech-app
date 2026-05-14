// ============================================================================
// MAHMOUD TECH - Project Provider
// مزوّد حالة المشاريع والتوليد
// ============================================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:mahmoud_ai/constants/app_constants.dart';
import 'package:mahmoud_ai/models/project_model.dart';
import 'package:mahmoud_ai/models/scene_model.dart';
import 'package:mahmoud_ai/models/caption_model.dart';
import 'package:mahmoud_ai/services/storage_service.dart';
import 'package:mahmoud_ai/services/groq_service.dart';
import 'package:mahmoud_ai/services/image_generation_service.dart';
import 'package:mahmoud_ai/services/audio_service.dart';

class ProjectProvider extends ChangeNotifier {
  late StorageService _storage;
  final GroqService _groqService = GroqService();
  final ImageGenerationService _imageService = ImageGenerationService();
  final AudioService _audioService = AudioService();
  final _uuid = const Uuid();

  List<ProjectModel> _projects = [];
  ProjectModel? _currentProject;
  bool _isLoading = false;
  bool _isGenerating = false;
  bool _isCancelled = false;
  String? _error;
  double _progress = 0.0;
  GenerationPhase _currentPhase = GenerationPhase.analyzing;
  Map<String, Uint8List> _generatedImages = {};
  Uint8List? _projectAudio;

  // Getters
  List<ProjectModel> get projects => _projects;
  ProjectModel? get currentProject => _currentProject;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get error => _error;
  double get progress => _progress;
  GenerationPhase get currentPhase => _currentPhase;
  Map<String, Uint8List> get generatedImages => _generatedImages;
  Uint8List? get projectAudio => _projectAudio;

  /// آخر مشروع
  ProjectModel? get lastProject {
    if (_projects.isEmpty) return null;
    return _projects.first;
  }

  /// تهيئة المزوّد
  Future<void> initialize() async {
    _storage = await StorageService.getInstance();
    _projects = _storage.getProjects();
    notifyListeners();
  }

  /// إنشاء مشروع جديد
  ProjectModel createNewProject() {
    final project = ProjectModel(
      id: _uuid.v4(),
      name: 'مشروع ${_projects.length + 1}',
    );
    _currentProject = project;
    _error = null;
    _generatedImages = {};
    _projectAudio = null;
    notifyListeners();
    return project;
  }

  /// تعيين المشروع الحالي
  void setCurrentProject(ProjectModel project) {
    _currentProject = project;
    _error = null;
    notifyListeners();
  }

  /// تحديث السكريبت
  void updateScript(String script) {
    if (_currentProject != null) {
      _currentProject = _currentProject!.copyWith(script: script);
      notifyListeners();
    }
  }

  /// تحديث نمط الفيديو
  void updateStyle(String style) {
    if (_currentProject != null) {
      _currentProject = _currentProject!.copyWith(style: style);
      notifyListeners();
    }
  }

  /// تحديث أبعاد الفيديو
  void updateAspectRatio(String aspectRatio) {
    if (_currentProject != null) {
      _currentProject = _currentProject!.copyWith(aspectRatio: aspectRatio);
      notifyListeners();
    }
  }

  /// تحديث بيانات المشروع الحالي
  void updateCurrentProject({
    String? name,
    String? script,
    String? style,
    String? aspectRatio,
    String? voiceId,
    String? captionStyle,
  }) {
    if (_currentProject != null) {
      _currentProject = _currentProject!.copyWith(
        name: name,
        script: script,
        style: style,
        aspectRatio: aspectRatio,
        voiceId: voiceId,
        captionStyle: captionStyle,
      );
      notifyListeners();
    }
  }

  /// تحديث اسم المشروع
  void updateProjectName(String name) {
    if (_currentProject != null) {
      _currentProject = _currentProject!.copyWith(name: name);
      notifyListeners();
    }
  }

  /// تحليل السكريبت
  Future<bool> analyzeScript() async {
    if (_currentProject == null) return false;

    final apiKey = _storage.getGroqApiKey();
    if (apiKey.isEmpty) {
      _error = 'مفتاح Groq API غير موجود. الرجاء إدخاله في الإعدادات.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    _currentProject = _currentProject!.copyWith(
      status: ProjectStatus.analyzing,
    );
    notifyListeners();

    try {
      final result = await _groqService.analyzeScript(
        script: _currentProject!.script,
        style: _currentProject!.style,
        aspectRatio: _currentProject!.aspectRatio,
        apiKey: apiKey,
      );

      final scenes = _groqService.parseScenes(result);
      final summary = result['summary'] as String? ?? '';

      _currentProject = _currentProject!.copyWith(
        scenes: scenes,
        summary: summary,
        status: ProjectStatus.draft,
      );

      // حفظ المشروع
      await _storage.saveProject(_currentProject!);
      _projects = _storage.getProjects();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _currentProject = _currentProject!.copyWith(
        status: ProjectStatus.draft,
      );
      notifyListeners();
      return false;
    }
  }

  /// تحديث مشهد معين
  void updateScene(int index, SceneModel scene) {
    if (_currentProject != null && index < _currentProject!.scenes.length) {
      final scenes = List<SceneModel>.from(_currentProject!.scenes);
      scenes[index] = scene;
      _currentProject = _currentProject!.copyWith(scenes: scenes);
      notifyListeners();
    }
  }

  /// حذف مشهد
  void removeScene(int index) {
    if (_currentProject != null && index < _currentProject!.scenes.length) {
      final scenes = List<SceneModel>.from(_currentProject!.scenes);
      scenes.removeAt(index);
      _currentProject = _currentProject!.copyWith(scenes: scenes);
      notifyListeners();
    }
  }

  /// إعادة ترتيب المشاهد
  void reorderScenes(int oldIndex, int newIndex) {
    if (_currentProject == null) return;
    final scenes = List<SceneModel>.from(_currentProject!.scenes);
    if (newIndex > oldIndex) newIndex--;
    final scene = scenes.removeAt(oldIndex);
    scenes.insert(newIndex, scene);
    _currentProject = _currentProject!.copyWith(scenes: scenes);
    notifyListeners();
  }

  /// بدء عملية التوليد الكاملة
  Future<bool> startGeneration() async {
    if (_currentProject == null || _currentProject!.scenes.isEmpty) return false;

    final imageApiKey = _storage.getImageApiKey();
    if (imageApiKey.isEmpty) {
      _error = 'مفتاح توليد الصور غير موجود. الرجاء إدخاله في الإعدادات.';
      notifyListeners();
      return false;
    }

    _isGenerating = true;
    _isCancelled = false;
    _progress = 0.0;
    _error = null;
    _generatedImages = {};
    _projectAudio = null;
    _currentProject = _currentProject!.copyWith(
      status: ProjectStatus.generating,
      errorLog: [],
    );
    notifyListeners();

    try {
      // المرحلة 1: تحليل النص (10%)
      _currentPhase = GenerationPhase.analyzing;
      _progress = 0.05;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 800));

      if (_isCancelled) return false;

      // المرحلة 2: إنشاء المشاهد (15%)
      _currentPhase = GenerationPhase.creatingScenes;
      _progress = 0.15;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));

      if (_isCancelled) return false;

      // المرحلة 3: توليد الصور (50%)
      _currentPhase = GenerationPhase.generatingImages;
      notifyListeners();

      final totalScenes = _currentProject!.scenes.length;
      final errorLog = <String>[];

      for (int i = 0; i < totalScenes; i++) {
        if (_isCancelled) return false;

        final scene = _currentProject!.scenes[i];
        try {
          final imageBytes = await _imageService.generateImage(
            prompt: scene.visualPrompt,
            apiKey: imageApiKey,
            aspectRatio: _currentProject!.aspectRatio,
          );

          _generatedImages[scene.id] = imageBytes;

          // تحديث المشهد
          final updatedScene = scene.copyWith(imageGenerated: true);
          updateScene(i, updatedScene);
        } catch (e) {
          final errorMsg = 'فشل توليد صورة المشهد ${i + 1}: ${e.toString().replaceAll('Exception: ', '')}';
          errorLog.add(errorMsg);

          // استخدام placeholder
          _generatedImages[scene.id] = _imageService.getPlaceholderImage();
          final updatedScene = scene.copyWith(
            imageFailed: true,
            retryCount: scene.retryCount + 1,
          );
          updateScene(i, updatedScene);
        }

        // تحديث التقدم
        _progress = 0.15 + (0.50 * (i + 1) / totalScenes);
        notifyListeners();
      }

      if (_isCancelled) return false;

      // المرحلة 4: تركيب الفيديو وتوليد الصوت (20%)
      _currentPhase = GenerationPhase.composingVideo;
      _progress = 0.75;
      notifyListeners();
      
      try {
        final audioApiKey = _storage.getAudioApiKey();
        if (audioApiKey.isNotEmpty) {
          _projectAudio = await _audioService.generateAudio(
            text: _currentProject!.script,
            apiKey: audioApiKey,
            voiceId: _currentProject!.voiceId,
          );
        } else {
          errorLog.add('لم يتم توليد الصوت: مفتاح ElevenLabs غير موجود');
        }
      } catch (e) {
        errorLog.add('فشل توليد الصوت: ${e.toString().replaceAll('Exception: ', '')}');
      }

      await Future.delayed(const Duration(seconds: 1));

      if (_isCancelled) return false;

      // توليد الكابشنز باستخدام Groq (إذا كان مفعل)
      if (_currentProject!.captionStyle != 'none') {
        try {
          final groqKey = _storage.getGroqApiKey();
          if (groqKey.isNotEmpty) {
            final captionsData = await _groqService.generateCaptions(
              script: _currentProject!.script,
              totalDuration: _currentProject!.totalDuration,
              apiKey: groqKey,
            );
            
            final captions = captionsData.map((c) => CaptionModel.fromJson(c)).toList();
            _currentProject = _currentProject!.copyWith(captions: captions);
          }
        } catch (e) {
          errorLog.add('فشل توليد الكابشنز: ${e.toString()}');
        }
      }

      // المرحلة 5: تجهيز التصدير (5%)
      _currentPhase = GenerationPhase.preparingExport;
      _progress = 0.95;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));

      // اكتمال
      _currentPhase = GenerationPhase.done;
      _progress = 1.0;
      _isGenerating = false;
      _currentProject = _currentProject!.copyWith(
        status: ProjectStatus.completed,
        progress: 1.0,
        errorLog: errorLog,
      );

      // حفظ المشروع
      await _storage.saveProject(_currentProject!);
      _projects = _storage.getProjects();

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isGenerating = false;
      _currentProject = _currentProject!.copyWith(
        status: ProjectStatus.failed,
      );
      await _storage.saveProject(_currentProject!);
      _projects = _storage.getProjects();
      notifyListeners();
      return false;
    }
  }

  /// إلغاء التوليد
  void cancelGeneration() {
    _isCancelled = true;
    _isGenerating = false;
    _currentProject = _currentProject?.copyWith(
      status: ProjectStatus.draft,
    );
    notifyListeners();
  }

  /// حفظ المشروع الحالي كمسودة
  Future<void> saveDraft() async {
    if (_currentProject != null) {
      _currentProject = _currentProject!.copyWith(
        status: ProjectStatus.draft,
      );
      await _storage.saveProject(_currentProject!);
      _projects = _storage.getProjects();
      await _storage.saveLastProjectId(_currentProject!.id);
      notifyListeners();
    }
  }

  /// حذف مشروع
  Future<void> deleteProject(String projectId) async {
    await _storage.deleteProject(projectId);
    _projects = _storage.getProjects();
    if (_currentProject?.id == projectId) {
      _currentProject = null;
    }
    notifyListeners();
  }

  /// فتح مشروع موجود
  void openProject(String projectId) {
    final project = _storage.getProject(projectId);
    if (project != null) {
      _currentProject = project;
      _error = null;
      notifyListeners();
    }
  }

  /// مسح الخطأ
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// الحصول على صورة مشهد
  Uint8List? getSceneImage(String sceneId) {
    return _generatedImages[sceneId];
  }
}
