import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/forgot_password_usecase.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordUseCase forgotPasswordUseCase;

  ForgotPasswordCubit({required this.forgotPasswordUseCase})
    : super(const ForgotPasswordInitial());

  Future<void> sendResetEmail(String email) async {
    emit(const ForgotPasswordLoading());
    try {
      await forgotPasswordUseCase(email: email.trim());
      emit(ForgotPasswordSuccess(email.trim()));
    } catch (e) {
      emit(
        ForgotPasswordFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  void reset() {
    emit(const ForgotPasswordInitial());
  }
}

