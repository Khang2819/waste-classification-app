import '../repositories/profile_repository.dart';

class CreatePasswordUseCase {
  final ProfileRepository repository;

  CreatePasswordUseCase(this.repository);

  Future<void> call({required String newPassword}) {
    return repository.createPassword(newPassword: newPassword);
  }
}
