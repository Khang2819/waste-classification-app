import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  Future<User> call({
    required String email,
    required String password,
    required String fullName,
  }) {
    return repository.registerWithEmailAndPassword(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}
