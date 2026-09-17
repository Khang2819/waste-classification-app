import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_classification_app/features/history/domain/entities/scan_history_entity.dart';

class HistoryModels extends ScanHistoryEntity {
  const HistoryModels({
    required super.id,
    required super.userId,
    required super.label,
    required super.category,
    required super.confidence,
    required super.instruction,
    required super.imagePath,
    required super.pointsEarned,
    required super.createdAt,
  });

  factory HistoryModels.fromToFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return HistoryModels(
      id: doc.id,
      userId: data['userId'] ?? '',
      label: data['label'] ?? '',
      category: data['category'] ?? '',
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
      instruction: data['instruction'] ?? '',
      imagePath: data['imagePath'] ?? '',
      pointsEarned: (data['pointsEarned'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'label': label,
      'category': category,
      'confidence': confidence,
      'instruction': instruction,
      'imagePath': imagePath,
      'pointsEarned': pointsEarned,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
