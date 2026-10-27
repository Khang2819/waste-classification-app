import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource remoteDatasource;

  NotificationRepositoryImpl({required this.remoteDatasource});
  @override
  Stream<List<NotificationModel>> watchNotifications(String uid) {
    return remoteDatasource.watchNotifications(uid);
  }

  @override
  Future<void> markAsRead(String uid, String id) async {
    return await remoteDatasource.markAsRead(uid, id);
  }

  @override
  Future<void> markAllAsRead(String uid) async {
    return await remoteDatasource.markAllAsRead(uid);
  }

  @override
  Future<void> saveToken(String uid, String token) async {
    return await remoteDatasource.saveFcmToken(uid, token);
  }
}
