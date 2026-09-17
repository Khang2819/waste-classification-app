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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      greenPoints: (json['greenPoints'] as num?)?.toInt() ?? 0,
      totalXP: (json['totalXP'] as num?)?.toInt() ?? 0,
      totalScanned: (json['totalScanned'] as num?)?.toInt() ?? 0,
      lastScanDate: json['lastScanDate'] as String? ?? '',
      dailyScanCount: (json['dailyScanCount'] as num?)?.toInt() ?? 0,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'] as String)
              : null,
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
    };
  }
}
