import 'package:bloc/bloc.dart';

import '../../../domain/usecases/register_usecase.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase registerUseCase;

  RegisterCubit({required this.registerUseCase}) : super(RegisterInitial());

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(RegisterLoading());
    try {
      final user = await registerUseCase(
        email: email,
        password: password,
        fullName: fullName,
      );
      emit(RegisterSuccess(user));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(RegisterFailure(errorMessage));
    }
  }

  void resetState() {
    emit(RegisterInitial());
  }
}
