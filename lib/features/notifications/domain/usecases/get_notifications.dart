import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

class GetNotifications {
  final NotificationRepository repository;

  GetNotifications(this.repository);

  Stream<List<AppNotification>> call(String uid) {
    return repository.watchNotifications(uid);
  }
}
