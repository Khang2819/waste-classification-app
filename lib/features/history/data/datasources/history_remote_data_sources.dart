import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_classification_app/features/history/data/models/history_models.dart';

abstract class HistoryRemoteDataSources {
  Stream<List<HistoryModels>> getAllHistory(String userId);
  Future<void> deleteHistory(String userId, String historyId);
  Future<void> saveHistory(String userId, HistoryModels history);
}

class HistoryRemoteDataSourcesImpl implements HistoryRemoteDataSources {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<HistoryModels>> getAllHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('scan_histories')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => HistoryModels.fromToFirestore(doc))
              .toList();
        });
  }

  @override
  Future<void> deleteHistory(String userId, String historyId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('scan_histories')
        .doc(historyId)
        .delete();
  }

  @override
  Future<void> saveHistory(String userId, HistoryModels history) async {
    final now = DateTime.now();
    // Tạo chuỗi ngày hôm nay dạng: 2026-10-20
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final userDocRef = _firestore.collection('users').doc(userId);
    final historyDocRef = userDocRef.collection('scan_histories').doc();

    await _firestore.runTransaction((transaction) async {
      final userSnap = await transaction.get(userDocRef);
      final userData = userSnap.data() ?? {};

      final lastScanDate = userData['lastScanDate'] as String? ?? '';
      final currentDailyCount =
          (userData['dailyScanCount'] as num?)?.toInt() ?? 0;

      int newDailyCount = 1;
      int pointsToAdd = 10;

      if (lastScanDate == todayStr) {
        if (currentDailyCount >= 20) {
          pointsToAdd = 0;
          newDailyCount = currentDailyCount + 1;
        } else {
          newDailyCount = currentDailyCount + 1;
        }
      } else {
        newDailyCount = 1;
      }
      final historyToSave = HistoryModels(
        id: historyDocRef.id,
        userId: userId,
        label: history.label,
        category: history.category,
        confidence: history.confidence,
        instruction: history.instruction,
        imagePath: history.imagePath,
        pointsEarned: pointsToAdd,
        createdAt: now,
      );
      transaction.set(historyDocRef, historyToSave.toFirestore());

      // 2. Cập nhật thông tin User (chỉ tăng XP & GreenPoints nếu pointsToAdd > 0)
      final Map<String, dynamic> userUpdates = {
        'totalScanned': FieldValue.increment(1),
        'lastScanDate': todayStr,
        'dailyScanCount': newDailyCount,
        'lastActiveAt': FieldValue.serverTimestamp(),
      };

      if (pointsToAdd > 0) {
        userUpdates['totalXP'] = FieldValue.increment(pointsToAdd);
        userUpdates['greenPoints'] = FieldValue.increment(pointsToAdd);
      }

      transaction.set(userDocRef, userUpdates, SetOptions(merge: true));
    });
  }
}
