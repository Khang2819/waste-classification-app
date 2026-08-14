import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userModel = await remoteDataSource.loginWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userModel;
  }

  @override
  Future<User> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final userModel = await remoteDataSource.registerWithEmailAndPassword(
      email: email,
      password: password,
      fullName: fullName,
    );
    return userModel;
  }

  @override
  Future<User> signInWithGoogle() async {
    return await remoteDataSource.loginWithGoogle();
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Stream<User?> getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }
}
