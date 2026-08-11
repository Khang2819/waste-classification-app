import '../entities/user.dart';

/// Abstract contract for Authentication operations in the Domain Layer.
abstract class AuthRepository {
  /// Sign in user with [email] and [password].
  Future<User> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register a new user with [email], [password], and [fullName].
  Future<User> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  });

  Future<User> signInWithGoogle();

  /// Sign out the current user.
  Future<void> logout();

  /// Get currently authenticated user, or `null` if unauthenticated.
  Stream<User?> getCurrentUser();
}
