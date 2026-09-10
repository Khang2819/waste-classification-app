import '../../domain/entities/reward_entity.dart';
import '../../domain/repositories/reward_repository.dart';
import '../datasources/reward_remote_data_sources.dart';

class RewardRepositoryImpl implements RewardRepository {
  final RewardRemoteDataSources remoteDataSource;

  RewardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RewardEntity>> getRewards() async {
    return await remoteDataSource.getReward();
  }
}
