import 'package:equatable/equatable.dart';

sealed class ChangePasswordState extends Equatable {
  const ChangePasswordState();

  @override
  List<Object?> get props => [];
}

final class ChangePasswordInitial extends ChangePasswordState {
  const ChangePasswordInitial();
}

final class ChangePasswordLoading extends ChangePasswordState {
  const ChangePasswordLoading();
}

final class ChangePasswordSuccess extends ChangePasswordState {
  final String message;
  const ChangePasswordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

final class ChangePasswordFailure extends ChangePasswordState {
  final String message;
  const ChangePasswordFailure(this.message);

  @override
  List<Object?> get props => [message];
}

final class PasswordResetEmailSent extends ChangePasswordState {
  final String message;
  const PasswordResetEmailSent(this.message);

  @override
  List<Object?> get props => [message];
}

