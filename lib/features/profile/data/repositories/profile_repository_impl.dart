import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  bool get isPasswordLinked => remoteDataSource.isPasswordLinked;

  @override
  bool get isGoogleLinked => remoteDataSource.isGoogleLinked;

  @override
  String? get currentUserEmail => remoteDataSource.currentUserEmail;

  @override
  Stream<User> getUserProfile(String userId) {
    return remoteDataSource.getUserProfile(userId);
  }

  @override
  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    String? email,
    String? avatarUrl,
  }) {
    return remoteDataSource.updateUserProfile(
      userId: userId,
      fullName: fullName,
      email: email,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> createPassword({
    required String newPassword,
  }) {
    return remoteDataSource.createPassword(
      newPassword: newPassword,
    );
  }

  @override
  Future<void> sendPasswordResetEmail() {
    return remoteDataSource.sendPasswordResetEmail();
  }
}
