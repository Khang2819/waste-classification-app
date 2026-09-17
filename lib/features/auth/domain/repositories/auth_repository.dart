import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<User> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  });

  Future<User> signInWithGoogle();

  Future<void> logout();

  Stream<User?> getCurrentUser();
}
