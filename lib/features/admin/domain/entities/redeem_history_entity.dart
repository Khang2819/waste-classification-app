import 'package:equatable/equatable.dart';

class RedeemHistoryEntity extends Equatable {
  final String id;
  final String userId;
  final String rewardId;
  final String title;
  final String name;
  final int pointsSpent;
  final DateTime? redeemedAt;
  final String status; // 'success' | 'pending' | 'used'

  const RedeemHistoryEntity({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.title,
    required this.name,
    required this.pointsSpent,
    this.redeemedAt,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Chờ duyệt';
      case 'used':
        return 'Đã sử dụng';
      case 'success':
      default:
        return 'Thành công';
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    rewardId,
    title,
    name,
    pointsSpent,
    redeemedAt,
    status,
  ];
}

