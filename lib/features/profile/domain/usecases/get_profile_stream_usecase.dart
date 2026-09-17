import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

class GetProfileStreamUseCase {
  final ProfileRepository repository;

  GetProfileStreamUseCase(this.repository);

  Stream<User> call(String userId) {
    return repository.getUserProfile(userId);
  }
}
