import '../../../auth/domain/entities/user.dart';

abstract class ProfileRepository {
  Stream<User> getUserProfile(String userId);
}
