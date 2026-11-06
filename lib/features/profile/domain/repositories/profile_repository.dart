import '../../../auth/domain/entities/user.dart';

abstract class ProfileRepository {
  Stream<User> getUserProfile(String userId);
  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    String? email,
    String? avatarUrl,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> createPassword({
    required String newPassword,
  });
  Future<void> sendPasswordResetEmail();
  bool get isPasswordLinked;
  bool get isGoogleLinked;
  String? get currentUserEmail;
}
