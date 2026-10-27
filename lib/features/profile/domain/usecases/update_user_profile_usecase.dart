import '../repositories/profile_repository.dart';

class UpdateUserProfileUsecase {
  final ProfileRepository repository;

  UpdateUserProfileUsecase(this.repository);

  Future<void> call({
    required String userId,
    required String fullName,
    String? email,
    String? avatarUrl,
  }) {
    return repository.updateUserProfile(
      userId: userId,
      fullName: fullName,
      email: email,
      avatarUrl: avatarUrl,
    );
  }
}
