import '../../../auth/domain/entities/user.dart';

abstract class ProfileRepository {
  Stream<User> getUserProfile(String userId);
  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    String? email,
    String? avatarUrl,
  });
}
