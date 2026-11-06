import '../../../auth/domain/entities/user.dart';
import '../../../map/domain/entities/waste_point_entity.dart';
import '../../../reward/domain/entities/reward_entity.dart';
import '../entities/redeem_history_entity.dart';

abstract class AdminRepository {
  // Users
  Future<List<User>> getAllUsers();
  Future<void> adjustUserPointsAndXp({
    required String userId,
    required int greenPointsDelta,
    required int xpDelta,
    required String reason,
    String notificationType = 'reward',
    bool incrementScanCount = false,
  });

  // Waste Points
  Future<List<WastePointEntity>> getAllWastePoints();
  Future<void> addWastePoint(WastePointEntity point);
  Future<void> updateWastePoint(WastePointEntity point);
  Future<void> updateWastePointStatus(String pointId, WastePointStatus status);
  Future<void> deleteWastePoint(String pointId);

  // Rewards & Redeem Histories
  Future<List<RewardEntity>> getAllRewards();
  Future<void> addReward(RewardEntity reward);
  Future<void> updateReward(RewardEntity reward);
  Future<void> updateRewardStock(String rewardId, int newStock);
  Future<void> deleteReward(String rewardId);
  Future<List<RedeemHistoryEntity>> getAllRedeemHistories();
  Future<void> updateRedeemStatus({
    required String userId,
    required String historyId,
    required String status,
  });

  // Notifications
  Future<void> sendNotification({
    required String title,
    required String body,
    required String type,
    String? targetUserId,
  });
}

