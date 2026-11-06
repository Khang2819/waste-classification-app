import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../map/domain/entities/waste_point_entity.dart';
import '../../../reward/domain/entities/reward_entity.dart';
import '../../domain/entities/redeem_history_entity.dart';

class AdminState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final List<User> users;
  final List<WastePointEntity> wastePoints;
  final List<RewardEntity> rewards;
  final List<RedeemHistoryEntity> redeemHistories;
  final String? errorMessage;
  final String? successMessage;

  const AdminState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.users = const [],
    this.wastePoints = const [],
    this.rewards = const [],
    this.redeemHistories = const [],
    this.errorMessage,
    this.successMessage,
  });

  // KPI Metrics cho Dashboard
  int get totalUsers => users.length;

  int get totalScanned =>
      users.fold(0, (sum, user) => sum + user.totalScanned);

  double get totalRecycledKg => totalScanned * 0.5;

  double get totalCo2SavedKg => totalScanned * 0.3;

  int get activePointsCount =>
      wastePoints.where((p) => p.status == WastePointStatus.active).length;

  int get fullPointsCount =>
      wastePoints.where((p) => p.status == WastePointStatus.full).length;

  int get inactivePointsCount =>
      wastePoints.where((p) => p.status == WastePointStatus.inactive).length;

  List<WastePointEntity> get fullWastePoints =>
      wastePoints.where((p) => p.status == WastePointStatus.full).toList();

  List<RewardEntity> get lowStockRewards =>
      rewards.where((r) => r.stock <= 5).toList();

  AdminState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<User>? users,
    List<WastePointEntity>? wastePoints,
    List<RewardEntity>? rewards,
    List<RedeemHistoryEntity>? redeemHistories,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      users: users ?? this.users,
      wastePoints: wastePoints ?? this.wastePoints,
      rewards: rewards ?? this.rewards,
      redeemHistories: redeemHistories ?? this.redeemHistories,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSubmitting,
    users,
    wastePoints,
    rewards,
    redeemHistories,
    errorMessage,
    successMessage,
  ];
}

