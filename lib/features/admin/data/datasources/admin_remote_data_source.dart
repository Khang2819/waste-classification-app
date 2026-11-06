import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../map/data/models/waste_point_model.dart';
import '../../../map/domain/entities/waste_point_entity.dart';
import '../../../reward/data/models/reward_models.dart';
import '../models/redeem_history_model.dart';

abstract class AdminRemoteDataSource {
  // Users
  Future<List<UserModel>> getAllUsers();
  Future<void> adjustUserPointsAndXp({
    required String userId,
    required int greenPointsDelta,
    required int xpDelta,
    required String reason,
    String notificationType = 'reward',
    bool incrementScanCount = false,
  });

  // Waste Points
  Future<List<WastePointModel>> getAllWastePoints();
  Future<void> addWastePoint(WastePointModel point);
  Future<void> updateWastePoint(WastePointModel point);
  Future<void> updateWastePointStatus(String pointId, WastePointStatus status);
  Future<void> deleteWastePoint(String pointId);

  // Rewards & Redeem Histories
  Future<List<RewardModels>> getAllRewards();
  Future<void> addReward(RewardModels reward);
  Future<void> updateReward(RewardModels reward);
  Future<void> updateRewardStock(String rewardId, int newStock);
  Future<void> deleteReward(String rewardId);
  Future<List<RedeemHistoryModel>> getAllRedeemHistories();
  Future<void> updateRedeemStatus({
    required String userId,
    required String historyId,
    required String status,
  });

  // System Notifications
  Future<void> sendNotification({
    required String title,
    required String body,
    required String type,
    String? targetUserId,
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore _firestore;

  AdminRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    final users =
        snapshot.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return UserModel.fromJson(data);
        }).toList();

    users.sort((a, b) => b.greenPoints.compareTo(a.greenPoints));
    return users;
  }

  @override
  Future<void> adjustUserPointsAndXp({
    required String userId,
    required int greenPointsDelta,
    required int xpDelta,
    required String reason,
    String notificationType = 'reward',
    bool incrementScanCount = false,
  }) async {
    final cleanId =
        userId.startsWith('SMARTWASTE_USER:')
            ? userId.replaceFirst('SMARTWASTE_USER:', '').trim()
            : userId.trim();

    if (cleanId.isEmpty) {
      throw Exception('Mã người dùng không hợp lệ.');
    }

    final userRef = _firestore.collection('users').doc(cleanId);
    final notifRef = userRef.collection('notifications').doc();

    await _firestore.runTransaction((transaction) async {
      final userSnap = await transaction.get(userRef);
      if (!userSnap.exists) {
        throw Exception('Không tìm thấy người dùng với ID: $cleanId');
      }

      final data = userSnap.data() ?? {};
      final currentPoints = (data['greenPoints'] as num?)?.toInt() ?? 0;
      final currentXp = (data['totalXP'] as num?)?.toInt() ?? 0;
      final currentScanned = (data['totalScanned'] as num?)?.toInt() ?? 0;

      final updatedPoints = (currentPoints + greenPointsDelta).clamp(0, 9999999);
      final updatedXp = (currentXp + xpDelta).clamp(0, 9999999);

      final updates = <String, dynamic>{
        'greenPoints': updatedPoints,
        'totalXP': updatedXp,
      };
      if (incrementScanCount) {
        updates['totalScanned'] = currentScanned + 1;
      }

      transaction.update(userRef, updates);

      final signPoints =
          greenPointsDelta >= 0 ? '+$greenPointsDelta' : '$greenPointsDelta';
      final signXp = xpDelta >= 0 ? '+$xpDelta' : '$xpDelta';
      final notifTitle =
          greenPointsDelta >= 0
              ? 'Cộng điểm thưởng Xanh ($signPoints GP)'
              : 'Điều chỉnh điểm Xanh ($signPoints GP)';
      final notifBody =
          reason.trim().isNotEmpty
              ? '$reason (GreenPoints: $signPoints, XP: $signXp)'
              : 'Quản trị viên đã cập nhật điểm của bạn: $signPoints GreenPoints, $signXp XP.';

      transaction.set(notifRef, {
        'title': notifTitle,
        'body': notifBody,
        'type': notificationType,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    });
  }

  @override
  Future<List<WastePointModel>> getAllWastePoints() async {
    final snapshot = await _firestore.collection('waste_points').get();
    return snapshot.docs
        .map((doc) => WastePointModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> addWastePoint(WastePointModel point) async {
    await _firestore.collection('waste_points').add(point.toFirestore());
  }

  @override
  Future<void> updateWastePoint(WastePointModel point) async {
    await _firestore.collection('waste_points').doc(point.id).update({
      'name': point.name,
      'latitude': point.latitude,
      'longitude': point.longitude,
      'wasteTypes': point.wasteTypes,
      'address': point.address ?? '',
      'status': point.status.name,
    });
  }

  @override
  Future<void> updateWastePointStatus(
    String pointId,
    WastePointStatus status,
  ) async {
    await _firestore.collection('waste_points').doc(pointId).update({
      'status': status.name,
    });
  }

  @override
  Future<void> deleteWastePoint(String pointId) async {
    await _firestore.collection('waste_points').doc(pointId).delete();
  }

  @override
  Future<List<RewardModels>> getAllRewards() async {
    final snapshot = await _firestore.collection('rewards').get();
    return snapshot.docs.map((doc) => RewardModels.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addReward(RewardModels reward) async {
    await _firestore.collection('rewards').add(reward.toFirestore());
  }

  @override
  Future<void> updateReward(RewardModels reward) async {
    await _firestore
        .collection('rewards')
        .doc(reward.id)
        .update(reward.toFirestore());
  }

  @override
  Future<void> updateRewardStock(String rewardId, int newStock) async {
    await _firestore.collection('rewards').doc(rewardId).update({
      'stock': newStock.clamp(0, 999999),
    });
  }

  @override
  Future<void> deleteReward(String rewardId) async {
    await _firestore.collection('rewards').doc(rewardId).delete();
  }

  @override
  Future<List<RedeemHistoryModel>> getAllRedeemHistories() async {
    try {
      final snapshot =
          await _firestore.collectionGroup('redeem_histories').get();
      final list =
          snapshot.docs
              .map((doc) => RedeemHistoryModel.fromFirestore(doc))
              .toList();
      list.sort((a, b) {
        final dateA = a.redeemedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.redeemedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });
      return list;
    } catch (_) {
      // Fallback: duyệt qua danh sách users nếu chưa tạo quyền/index cho collectionGroup
      final usersSnap = await _firestore.collection('users').get();
      final List<RedeemHistoryModel> fallbackList = [];
      for (final userDoc in usersSnap.docs) {
        final histSnap =
            await userDoc.reference.collection('redeem_histories').get();
        for (final doc in histSnap.docs) {
          fallbackList.add(RedeemHistoryModel.fromFirestore(doc));
        }
      }
      fallbackList.sort((a, b) {
        final dateA = a.redeemedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.redeemedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });
      return fallbackList;
    }
  }

  @override
  Future<void> updateRedeemStatus({
    required String userId,
    required String historyId,
    required String status,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('redeem_histories')
        .doc(historyId)
        .update({'status': status});
  }

  @override
  Future<void> sendNotification({
    required String title,
    required String body,
    required String type,
    String? targetUserId,
  }) async {
    final payload = {
      'title': title.trim(),
      'body': body.trim(),
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    if (targetUserId != null && targetUserId.trim().isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(targetUserId.trim())
          .collection('notifications')
          .add(payload);
      return;
    }

    // Gửi cho tất cả người dùng bằng WriteBatch (chia nhỏ tối đa 450 docs/batch)
    final usersSnapshot = await _firestore.collection('users').get();
    final docs = usersSnapshot.docs;
    const int batchLimit = 450;

    for (int i = 0; i < docs.length; i += batchLimit) {
      final batch = _firestore.batch();
      final end = (i + batchLimit < docs.length) ? i + batchLimit : docs.length;
      for (int j = i; j < end; j++) {
        final notifDoc = docs[j].reference.collection('notifications').doc();
        batch.set(notifDoc, payload);
      }
      await batch.commit();
    }
  }
}

