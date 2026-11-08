import 'package:waste_classification_app/features/reward/domain/entities/reward_entity.dart';
import 'package:waste_classification_app/features/reward/domain/entities/user_reward_item_entity.dart';

abstract class RewardRepository {
  Future<List<RewardEntity>> getRewards();
  Future<void> redeemReward({
    required String userId,
    required RewardEntity reward,
  });
  Stream<List<UserRewardItemEntity>> watchUserRedeemHistories(String userId);
  Future<void> markVoucherAsUsed({
    required String userId,
    required String historyId,
  });
}
