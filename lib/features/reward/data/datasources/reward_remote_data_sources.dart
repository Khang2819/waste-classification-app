import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_classification_app/features/reward/data/models/reward_models.dart';
import 'package:waste_classification_app/features/reward/data/models/user_reward_item_model.dart';

abstract class RewardRemoteDataSources {
  Future<List<RewardModels>> getReward();
  Future<void> redeemReward({
    required String userId,
    required RewardModels reward,
  });
  Stream<List<UserRewardItemModel>> watchUserRedeemHistories(String userId);
  Future<void> markVoucherAsUsed({
    required String userId,
    required String historyId,
  });
}

class RewardRemoteDataSourcesImpl implements RewardRemoteDataSources {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<RewardModels>> getReward() async {
    try {
      final snapshot = await _firestore.collection('rewards').get();
      return snapshot.docs
          .map((doc) => RewardModels.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch rewards: $e');
    }
  }

  @override
  Future<void> redeemReward({
    required String userId,
    required RewardModels reward,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final rewardRef = _firestore.collection('rewards').doc(reward.id);
    final historyRef = userRef.collection('redeem_histories').doc();
    final notifRef = userRef.collection('notifications').doc();

    await _firestore.runTransaction((transaction) async {
      final userSnap = await transaction.get(userRef);
      final rewardSnap = await transaction.get(rewardRef);

      if (!userSnap.exists) {
        throw Exception('Không tìm thấy thông tin người dùng.');
      }
      if (!rewardSnap.exists) {
        throw Exception('Quà tặng không tồn tại hoặc đã bị xóa.');
      }
      final currentPoints =
          (userSnap.data()?['greenPoints'] as num?)?.toInt() ?? 0;
      final currentStock = (rewardSnap.data()?['stock'] as num?)?.toInt() ?? 0;
      if (currentPoints < reward.points) {
        throw Exception('Bạn không đủ điểm GreenPoints để đổi quà này.');
      }
      if (currentStock <= 0) {
        throw Exception('Sản phẩm này đã hết hàng.');
      }
      transaction.update(userRef, {
        'greenPoints': currentPoints - reward.points,
      });
      transaction.update(rewardRef, {'stock': currentStock - 1});
      transaction.set(historyRef, {
        'rewardId': reward.id,
        'title': reward.title,
        'name': reward.name,
        'pointsSpent': reward.points,
        'imageUrl': reward.imageUrl,
        'description': reward.description,
        'redeemedAt': FieldValue.serverTimestamp(),
        'status': 'success',
      });
      transaction.set(notifRef, {
        'title': 'Đổi quà thành công: ${reward.title}',
        'body':
            'Bạn đã dùng ${reward.points} Điểm Xanh để đổi "${reward.title}". Mở Túi quà để xem mã Voucher!',
        'type': 'reward',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    });
  }

  @override
  Stream<List<UserRewardItemModel>> watchUserRedeemHistories(String userId) {
    if (userId.isEmpty) return Stream.value(const []);
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('redeem_histories')
        .snapshots()
        .map((snap) {
          final items =
              snap.docs.map(UserRewardItemModel.fromFirestore).toList();
          items.sort((a, b) {
            final dA = a.redeemedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final dB = b.redeemedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return dB.compareTo(dA);
          });
          return items;
        });
  }

  @override
  Future<void> markVoucherAsUsed({
    required String userId,
    required String historyId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('redeem_histories')
        .doc(historyId)
        .update({'status': 'used'});
  }
}
