import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_reward_item_entity.dart';

class UserRewardItemModel extends UserRewardItemEntity {
  const UserRewardItemModel({
    required super.id,
    required super.rewardId,
    required super.title,
    required super.name,
    required super.pointsSpent,
    super.redeemedAt,
    required super.status,
    super.imageUrl,
    super.description,
  });

  factory UserRewardItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    DateTime? parsedDate;
    final rawDate = data['redeemedAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate != null) {
      parsedDate = DateTime.tryParse(rawDate.toString());
    }

    return UserRewardItemModel(
      id: doc.id,
      rewardId: data['rewardId']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Quà tặng Xanh',
      name: data['name']?.toString() ?? 'Voucher',
      pointsSpent: (data['pointsSpent'] as num?)?.toInt() ?? 0,
      redeemedAt: parsedDate,
      status: data['status']?.toString() ?? 'success',
      imageUrl: data['imageUrl']?.toString(),
      description: data['description']?.toString(),
    );
  }
}

