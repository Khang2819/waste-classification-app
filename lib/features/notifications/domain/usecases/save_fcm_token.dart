import '../repositories/notification_repository.dart';

class SaveFcmToken {
  final NotificationRepository repository;

  SaveFcmToken(this.repository);

  Future<void> call(String uid, String token) async {
    return repository.saveToken(uid, token);
  }
}
