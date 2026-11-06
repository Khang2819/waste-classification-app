import 'package:bloc/bloc.dart';

import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/create_password_usecase.dart';
import '../../domain/usecases/send_password_reset_email_usecase.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ChangePasswordUseCase changePasswordUseCase;
  final CreatePasswordUseCase createPasswordUseCase;
  final SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase;
  final ProfileRepository profileRepository;

  ChangePasswordCubit({
    required this.changePasswordUseCase,
    required this.createPasswordUseCase,
    required this.sendPasswordResetEmailUseCase,
    required this.profileRepository,
  }) : super(const ChangePasswordInitial());

  bool get isPasswordLinked => profileRepository.isPasswordLinked;
  bool get isGoogleLinked => profileRepository.isGoogleLinked;
  String? get currentUserEmail => profileRepository.currentUserEmail;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(const ChangePasswordLoading());
    try {
      await changePasswordUseCase(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(const ChangePasswordSuccess('Đổi mật khẩu thành công!'));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(ChangePasswordFailure(msg));
    }
  }

  Future<void> createPassword({
    required String newPassword,
  }) async {
    emit(const ChangePasswordLoading());
    try {
      await createPasswordUseCase(
        newPassword: newPassword,
      );
      emit(const ChangePasswordSuccess('Tạo mật khẩu cho tài khoản thành công!'));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(ChangePasswordFailure(msg));
    }
  }

  Future<void> sendPasswordResetEmail() async {
    emit(const ChangePasswordLoading());
    try {
      await sendPasswordResetEmailUseCase();
      final email = currentUserEmail ?? '';
      emit(
        PasswordResetEmailSent(
          email.isNotEmpty
              ? 'Đã gửi liên kết đặt lại mật khẩu đến: $email'
              : 'Đã gửi email đặt lại mật khẩu thành công.',
        ),
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(ChangePasswordFailure(msg));
    }
  }

  void resetState() {
    emit(const ChangePasswordInitial());
  }
}
