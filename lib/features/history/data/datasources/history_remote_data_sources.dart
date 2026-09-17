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
    final batch = _firestore.batch();

    final historyDoc =
        _firestore
            .collection('users')
            .doc(userId)
            .collection('scan_histories')
            .doc();

    batch.set(historyDoc, history.toFirestore());
    final userDocRef = _firestore.collection('users').doc(userId);
    batch.set(userDocRef, {
      'totalXP': FieldValue.increment(
        history.pointsEarned > 0 ? history.pointsEarned : 10,
      ),
      'totalScanned': FieldValue.increment(1),
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }
}
