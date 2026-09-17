import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_classification_app/features/reward/domain/entities/reward_entity.dart';

class RewardModels extends RewardEntity {
  const RewardModels({
    required super.id,
    required super.title,
    required super.name,
    required super.points,
    required super.description,
    required super.stock,
    super.imageUrl,
  });

  factory RewardModels.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RewardModels(
      id: doc.id,
      title: data['title'] as String? ?? '',
      name: data['name'] as String? ?? '',
      points: (data['points'] as num?)?.toInt() ?? 0,
      description: data['description'] as String? ?? "",
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      imageUrl: data['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'name': name,
      'points': points,
      'description': description,
      'stock': stock,
      'imageUrl': imageUrl,
    };
  }
}
