import 'package:equatable/equatable.dart';
import '../../../../features/auth/domain/entities/user.dart';

abstract class ProfileState extends Equatable {
  final User? user;
  const ProfileState({this.user});

  @override
  List<Object?> get props => [user];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial({super.user});
}

class ProfileLoading extends ProfileState {
  const ProfileLoading({super.user});
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(User user) : super(user: user);

  @override
  User get user => super.user!;
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating({super.user});
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  const ProfileUpdateSuccess(this.message, {super.user});

  @override
  List<Object?> get props => [message, user];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message, {super.user});

  @override
  List<Object?> get props => [message, user];
}
