import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

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
}
