import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/redeem_history_entity.dart';

class RedeemHistoryModel extends RedeemHistoryEntity {
  const RedeemHistoryModel({
    required super.id,
    required super.userId,
    required super.rewardId,
    required super.title,
    required super.name,
    required super.pointsSpent,
    super.redeemedAt,
    required super.status,
  });

  factory RedeemHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    // Lấy userId từ đường dẫn cha: users/{userId}/redeem_histories/{docId}
    final parentUserDoc = doc.reference.parent.parent;
    final extractedUserId =
        parentUserDoc?.id ?? data['userId']?.toString() ?? '';

    DateTime? parsedDate;
    final rawDate = data['redeemedAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate != null) {
      parsedDate = DateTime.tryParse(rawDate.toString());
    }

    return RedeemHistoryModel(
      id: doc.id,
      userId: extractedUserId,
      rewardId: data['rewardId']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Quà tặng Xanh',
      name: data['name']?.toString() ?? 'Voucher',
      pointsSpent: (data['pointsSpent'] as num?)?.toInt() ?? 0,
      redeemedAt: parsedDate,
      status: data['status']?.toString() ?? 'success',
    );
  }
}

