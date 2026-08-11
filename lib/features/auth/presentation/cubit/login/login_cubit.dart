import 'package:bloc/bloc.dart';
import 'package:waste_classification_app/features/auth/domain/usecases/google_usecase.dart';

import '../../../domain/usecases/login_usecase.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;
  final GoogleUsecase googleUsecase;

  LoginCubit({required this.loginUseCase, required this.googleUsecase})
    : super(LoginInitial());

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());
    try {
      final user = await loginUseCase(email: email, password: password);
      emit(LoginSuccess(user));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(LoginFailure(errorMessage));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(LoginLoading());
    try {
      final user = await googleUsecase();
      emit(LoginSuccess(user));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(LoginFailure(errorMessage));
    }
  }

  void resetState() {
    emit(LoginInitial());
  }
}
