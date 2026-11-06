import '../repositories/profile_repository.dart';

class SendPasswordResetEmailUseCase {
  final ProfileRepository repository;

  SendPasswordResetEmailUseCase(this.repository);

  Future<void> call() {
    return repository.sendPasswordResetEmail();
  }
}

