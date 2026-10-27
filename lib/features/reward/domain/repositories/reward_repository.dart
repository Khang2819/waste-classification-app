import 'package:waste_classification_app/features/reward/domain/entities/reward_entity.dart';

abstract class RewardRepository {
  Future<List<RewardEntity>> getRewards();
  Future<void> redeemReward({
    required String userId,
    required RewardEntity reward,
  });
}
