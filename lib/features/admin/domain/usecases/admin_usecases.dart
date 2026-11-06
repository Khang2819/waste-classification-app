import '../../../auth/domain/entities/user.dart';
import '../../../map/domain/entities/waste_point_entity.dart';
import '../../../reward/domain/entities/reward_entity.dart';
import '../entities/redeem_history_entity.dart';
import '../repositories/admin_repository.dart';

class AdminUseCases {
  final AdminRepository repository;

  AdminUseCases(this.repository);

  Future<List<User>> getAllUsers() => repository.getAllUsers();

  Future<void> adjustUserPointsAndXp({
    required String userId,
    required int greenPointsDelta,
    required int xpDelta,
    required String reason,
    String notificationType = 'reward',
    bool incrementScanCount = false,
  }) {
    return repository.adjustUserPointsAndXp(
      userId: userId,
      greenPointsDelta: greenPointsDelta,
      xpDelta: xpDelta,
      reason: reason,
      notificationType: notificationType,
      incrementScanCount: incrementScanCount,
    );
  }

  Future<List<WastePointEntity>> getAllWastePoints() =>
      repository.getAllWastePoints();

  Future<void> addWastePoint(WastePointEntity point) =>
      repository.addWastePoint(point);

  Future<void> updateWastePoint(WastePointEntity point) =>
      repository.updateWastePoint(point);

  Future<void> updateWastePointStatus(
    String pointId,
    WastePointStatus status,
  ) => repository.updateWastePointStatus(pointId, status);

  Future<void> deleteWastePoint(String pointId) =>
      repository.deleteWastePoint(pointId);

  Future<List<RewardEntity>> getAllRewards() => repository.getAllRewards();

  Future<void> addReward(RewardEntity reward) => repository.addReward(reward);

  Future<void> updateReward(RewardEntity reward) =>
      repository.updateReward(reward);

  Future<void> updateRewardStock(String rewardId, int newStock) =>
      repository.updateRewardStock(rewardId, newStock);

  Future<void> deleteReward(String rewardId) =>
      repository.deleteReward(rewardId);

  Future<List<RedeemHistoryEntity>> getAllRedeemHistories() =>
      repository.getAllRedeemHistories();

  Future<void> updateRedeemStatus({
    required String userId,
    required String historyId,
    required String status,
  }) => repository.updateRedeemStatus(
    userId: userId,
    historyId: historyId,
    status: status,
  );

  Future<void> sendNotification({
    required String title,
    required String body,
    required String type,
    String? targetUserId,
  }) => repository.sendNotification(
    title: title,
    body: body,
    type: type,
    targetUserId: targetUserId,
  );
}

