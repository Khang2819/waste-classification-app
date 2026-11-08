import 'package:equatable/equatable.dart';

class UserRewardItemEntity extends Equatable {
  final String id;
  final String rewardId;
  final String title;
  final String name;
  final int pointsSpent;
  final DateTime? redeemedAt;
  final String status; // 'success' | 'pending' | 'used'
  final String? imageUrl;
  final String? description;

  const UserRewardItemEntity({
    required this.id,
    required this.rewardId,
    required this.title,
    required this.name,
    required this.pointsSpent,
    this.redeemedAt,
    required this.status,
    this.imageUrl,
    this.description,
  });

  bool get isUsed => status.toLowerCase() == 'used';

  String get voucherCode {
    final clean = id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    final shortCode = clean.length >= 6 ? clean.substring(0, 6) : clean;
    return 'SW-$shortCode';
  }

  @override
  List<Object?> get props => [
    id,
    rewardId,
    title,
    name,
    pointsSpent,
    redeemedAt,
    status,
    imageUrl,
    description,
  ];
}

