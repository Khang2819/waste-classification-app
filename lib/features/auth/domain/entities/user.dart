import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? avatar;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatar,
  });
  @override
  List<Object?> get props => [id, fullName, email, avatar];
}
