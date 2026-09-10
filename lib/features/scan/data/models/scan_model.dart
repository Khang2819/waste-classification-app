import 'package:waste_classification_app/features/scan/domain/entities/scan_entities.dart';

class ScanModel extends ScanEntities {
  const ScanModel({
    required super.label,
    required super.imagePath,
    required super.confidence,
    required super.instruction,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      label: json['label'] as String? ?? 'Chưa xác định',
      imagePath: json['imagePath'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      instruction:
          json['instruction'] as String? ?? 'Không có hướng dẫn cụ thể.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'imagePath': imagePath,
      'confidence': confidence,
      'instruction': instruction,
    };
  }
}
