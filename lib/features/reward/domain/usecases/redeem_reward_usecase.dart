import '../entities/reward_entity.dart';
import '../repositories/reward_repository.dart';

class RedeemRewardUseCase {
  final RewardRepository repository;
  RedeemRewardUseCase(this.repository);

  Future<void> call({required String userId, required RewardEntity reward}) {
    return repository.redeemReward(userId: userId, reward: reward);
  }
}
