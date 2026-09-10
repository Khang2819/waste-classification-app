import 'package:waste_classification_app/features/reward/domain/entities/reward_entity.dart';

import '../repositories/reward_repository.dart';

class Reward {
  final RewardRepository repository;

  Reward(this.repository);

  Future<List<RewardEntity>> call() {
    return repository.getRewards();
  }
}
