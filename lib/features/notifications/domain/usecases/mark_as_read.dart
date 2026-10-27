import '../repositories/notification_repository.dart';

class MarkAsRead {
  final NotificationRepository repository;
  MarkAsRead(this.repository);

  Future<void> call(String uid, String notificationId) {
    return repository.markAsRead(uid, notificationId);
  }
}
