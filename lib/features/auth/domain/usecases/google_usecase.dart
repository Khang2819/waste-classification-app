import 'package:waste_classification_app/features/auth/domain/entities/user.dart';

import '../repositories/auth_repository.dart';

class GoogleUsecase {
  final AuthRepository repository;
  const GoogleUsecase(this.repository);
  Future<User> call() async {
    return repository.signInWithGoogle();
  }
}
