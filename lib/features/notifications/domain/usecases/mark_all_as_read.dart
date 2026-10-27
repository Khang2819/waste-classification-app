import '../repositories/notification_repository.dart';

class MarkAllAsRead {
  final NotificationRepository repository;
  MarkAllAsRead(this.repository);

  Future<void> call(String uid) async {
    return repository.markAllAsRead(uid);
  }
}
