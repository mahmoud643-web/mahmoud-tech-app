// ============================================================================
// MAHMOUD TECH - Caption Model
// نموذج الكابشن (النص المتزامن مع الزمن)
// ============================================================================

class CaptionModel {
  final String text;
  final double startTime;
  final double endTime;

  CaptionModel({
    required this.text,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory CaptionModel.fromJson(Map<String, dynamic> json) {
    return CaptionModel(
      text: json['text'] ?? '',
      startTime: (json['startTime'] ?? 0.0).toDouble(),
      endTime: (json['endTime'] ?? 0.0).toDouble(),
    );
  }

  CaptionModel copyWith({
    String? text,
    double? startTime,
    double? endTime,
  }) {
    return CaptionModel(
      text: text ?? this.text,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
