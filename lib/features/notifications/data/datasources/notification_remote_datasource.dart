import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDatasource {
  Stream<List<NotificationModel>> watchNotifications(String uid);
  Future<void> markAsRead(String uid, String id);
  Future<void> markAllAsRead(String uid);
  Future<void> saveFcmToken(String uid, String token);
  Future<void> addNotification(String uid, NotificationModel notification);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDatasource {
  final FirebaseFirestore firestore;
  NotificationRemoteDataSourceImpl([FirebaseFirestore? firestore])
    : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _collec(String uid) =>
      firestore.collection('users').doc(uid).collection('notifications');

  @override
  Stream<List<NotificationModel>> watchNotifications(String uid) {
    return _collec(uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(NotificationModel.fromFirestore).toList());
  }

  @override
  Future<void> markAsRead(String uid, String id) async {
    return _collec(uid).doc(id).update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(String uid) async {
    final unread = await _collec(uid).where('isRead', isEqualTo: false).get();
    final batch = firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> saveFcmToken(String uid, String token) async {
    firestore.collection('users').doc(uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> addNotification(
    String uid,
    NotificationModel notification,
  ) async {
    await _collec(uid).add(notification.toFirestore());
  }
}
