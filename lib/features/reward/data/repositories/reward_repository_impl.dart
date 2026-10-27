import '../../domain/entities/reward_entity.dart';
import '../../domain/repositories/reward_repository.dart';
import '../datasources/reward_remote_data_sources.dart';
import '../models/reward_models.dart';

class RewardRepositoryImpl implements RewardRepository {
  final RewardRemoteDataSources remoteDataSource;

  RewardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RewardEntity>> getRewards() async {
    return await remoteDataSource.getReward();
  }

  @override
  Future<void> redeemReward({
    required String userId,
    required RewardEntity reward,
  }) async {
    final model = RewardModels(
      id: reward.id,
      title: reward.title,
      name: reward.name,
      points: reward.points,
      description: reward.description,
      stock: reward.stock,
      imageUrl: reward.imageUrl,
    );
    return await remoteDataSource.redeemReward(userId: userId, reward: model);
  }
}
