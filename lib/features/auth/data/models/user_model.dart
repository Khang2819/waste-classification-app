import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:waste_classification_app/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
    );
  }

  factory UserModel.fromFirebase(firebase_auth.User user) {
    return UserModel(
      id: user.uid,
      fullName: user.displayName ?? '',
      email: user.email ?? '',
      avatar: user.photoURL,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'full_name': fullName, 'email': email, 'avatar': avatar};
  }

  User toEntity() {
    return User(id: id, fullName: fullName, email: email, avatar: avatar);
  }
}
