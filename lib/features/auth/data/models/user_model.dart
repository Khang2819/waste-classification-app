import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:waste_classification_app/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.avatar,
    super.greenPoints,
    super.totalXP,
    super.totalScanned,
    super.lastScanDate,
    super.dailyScanCount,
    super.createdAt,
    super.role = 'user',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final parsedRole =
        json['role']?.toString().trim().isNotEmpty == true
            ? json['role'].toString().trim()
            : (json['isAdmin'] == true ? 'admin' : 'user');

    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName:
          (json['full_name'] ?? json['fullName'] ?? json['name'])?.toString() ??
          '',
      email: json['email']?.toString() ?? '',
      avatar:
          (json['avatar'] ?? json['photoUrl'] ?? json['photoURL'])?.toString(),
      greenPoints: (json['greenPoints'] as num?)?.toInt() ?? 0,
      totalXP: (json['totalXP'] as num?)?.toInt() ?? 0,
      totalScanned: (json['totalScanned'] as num?)?.toInt() ?? 0,
      lastScanDate: json['lastScanDate']?.toString() ?? '',
      dailyScanCount: (json['dailyScanCount'] as num?)?.toInt() ?? 0,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
      role: parsedRole,
    );
  }

  factory UserModel.fromFirebase(
    firebase_auth.User user, {
    String role = 'user',
  }) {
    return UserModel(
      id: user.uid,
      fullName: user.displayName ?? '',
      email: user.email ?? '',
      avatar: user.photoURL,
      role: role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'avatar': avatar,
      'greenPoints': greenPoints,
      'totalXP': totalXP,
      'totalScanned': totalScanned,
      'lastScanDate': lastScanDate,
      'dailyScanCount': dailyScanCount,
      'createdAt': createdAt?.toIso8601String(),
      'role': role,
    };
  }
}
