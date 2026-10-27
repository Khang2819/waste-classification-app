import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Stream<List<AppNotification>> watchNotifications(String uid);
  Future<void> markAsRead(String uid, String notificationId);
  Future<void> markAllAsRead(String uid);
  Future<void> saveToken(String uid, String token);
}
