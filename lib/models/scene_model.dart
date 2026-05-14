// ============================================================================
// MAHMOUD TECH - Scene Model
// نموذج المشهد الواحد داخل المشروع
// ============================================================================

class SceneModel {
  final String id;
  String title;
  String description;
  String visualPrompt;
  double duration;
  int importance; // 1-5
  String? imageUrl;
  String? localImagePath;
  bool imageGenerated;
  bool imageFailed;
  int retryCount;
  String transition; // e.g., 'fade', 'slide', 'zoom', 'none'

  SceneModel({
    required this.id,
    required this.title,
    required this.description,
    required this.visualPrompt,
    this.duration = 4.0,
    this.importance = 3,
    this.imageUrl,
    this.localImagePath,
    this.imageGenerated = false,
    this.imageFailed = false,
    this.retryCount = 0,
    this.transition = 'fade',
  });

  /// تحويل المشهد إلى Map للتخزين
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'visualPrompt': visualPrompt,
      'duration': duration,
      'importance': importance,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'imageGenerated': imageGenerated,
      'imageFailed': imageFailed,
      'retryCount': retryCount,
      'transition': transition,
    };
  }

  /// إنشاء مشهد من Map مخزّن
  factory SceneModel.fromJson(Map<String, dynamic> json) {
    return SceneModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      visualPrompt: json['visualPrompt'] ?? '',
      duration: (json['duration'] ?? 4.0).toDouble(),
      importance: json['importance'] ?? 3,
      imageUrl: json['imageUrl'],
      localImagePath: json['localImagePath'],
      imageGenerated: json['imageGenerated'] ?? false,
      imageFailed: json['imageFailed'] ?? false,
      retryCount: json['retryCount'] ?? 0,
      transition: json['transition'] ?? 'fade',
    );
  }

  /// نسخة معدّلة من المشهد
  SceneModel copyWith({
    String? title,
    String? description,
    String? visualPrompt,
    double? duration,
    int? importance,
    String? imageUrl,
    String? localImagePath,
    bool? imageGenerated,
    bool? imageFailed,
    int? retryCount,
    String? transition,
  }) {
    return SceneModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      visualPrompt: visualPrompt ?? this.visualPrompt,
      duration: duration ?? this.duration,
      importance: importance ?? this.importance,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      imageGenerated: imageGenerated ?? this.imageGenerated,
      imageFailed: imageFailed ?? this.imageFailed,
      retryCount: retryCount ?? this.retryCount,
      transition: transition ?? this.transition,
    );
  }
}
