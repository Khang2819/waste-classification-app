import 'package:equatable/equatable.dart';

class ScanHistoryEntity extends Equatable {
  final String id;
  final String userId;
  final String label;
  final String category;
  final double confidence;
  final String instruction;
  final String imagePath;
  final int pointsEarned;
  final DateTime createdAt;
  const ScanHistoryEntity({
    required this.id,
    required this.userId,
    required this.label,
    required this.category,
    required this.confidence,
    required this.instruction,
    required this.imagePath,
    required this.pointsEarned,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    label,
    category,
    confidence,
    instruction,
    imagePath,
    pointsEarned,
    createdAt,
  ];
}
