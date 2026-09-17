import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? avatar;
  final int greenPoints;
  final int totalXP;
  final int totalScanned;
  final String lastScanDate;
  final int dailyScanCount;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatar,
    this.greenPoints = 0,
    this.totalXP = 0,
    this.totalScanned = 0,
    this.lastScanDate = '',
    this.dailyScanCount = 0,
    this.createdAt,
  });
  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    avatar,
    greenPoints,
    totalXP,
    totalScanned,
    lastScanDate,
    dailyScanCount,
    createdAt,
  ];
}
