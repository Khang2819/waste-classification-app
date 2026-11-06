import '../../../auth/domain/entities/user.dart';
import '../../../map/data/models/waste_point_model.dart';
import '../../../map/domain/entities/waste_point_entity.dart';
import '../../../reward/data/models/reward_models.dart';
import '../../../reward/domain/entities/reward_entity.dart';
import '../../domain/entities/redeem_history_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<User>> getAllUsers() => remoteDataSource.getAllUsers();

  @override
  Future<void> adjustUserPointsAndXp({
    required String userId,
    required int greenPointsDelta,
    required int xpDelta,
    required String reason,
    String notificationType = 'reward',
    bool incrementScanCount = false,
  }) {
    return remoteDataSource.adjustUserPointsAndXp(
      userId: userId,
      greenPointsDelta: greenPointsDelta,
      xpDelta: xpDelta,
      reason: reason,
      notificationType: notificationType,
      incrementScanCount: incrementScanCount,
    );
  }

  @override
  Future<List<WastePointEntity>> getAllWastePoints() =>
      remoteDataSource.getAllWastePoints();

  @override
  Future<void> addWastePoint(WastePointEntity point) {
    final model = WastePointModel(
      id: point.id,
      name: point.name,
      latitude: point.latitude,
      longitude: point.longitude,
      wasteTypes: point.wasteTypes,
      address: point.address,
      status: point.status,
    );
    return remoteDataSource.addWastePoint(model);
  }

  @override
  Future<void> updateWastePoint(WastePointEntity point) {
    final model = WastePointModel(
      id: point.id,
      name: point.name,
      latitude: point.latitude,
      longitude: point.longitude,
      wasteTypes: point.wasteTypes,
      address: point.address,
      status: point.status,
    );
    return remoteDataSource.updateWastePoint(model);
  }

  @override
  Future<void> updateWastePointStatus(String pointId, WastePointStatus status) {
    return remoteDataSource.updateWastePointStatus(pointId, status);
  }

  @override
  Future<void> deleteWastePoint(String pointId) {
    return remoteDataSource.deleteWastePoint(pointId);
  }

  @override
  Future<List<RewardEntity>> getAllRewards() =>
      remoteDataSource.getAllRewards();

  @override
  Future<void> addReward(RewardEntity reward) {
    final model = RewardModels(
      id: reward.id,
      title: reward.title,
      name: reward.name,
      points: reward.points,
      description: reward.description,
      stock: reward.stock,
      imageUrl: reward.imageUrl,
    );
    return remoteDataSource.addReward(model);
  }

  @override
  Future<void> updateReward(RewardEntity reward) {
    final model = RewardModels(
      id: reward.id,
      title: reward.title,
      name: reward.name,
      points: reward.points,
      description: reward.description,
      stock: reward.stock,
      imageUrl: reward.imageUrl,
    );
    return remoteDataSource.updateReward(model);
  }

  @override
  Future<void> updateRewardStock(String rewardId, int newStock) {
    return remoteDataSource.updateRewardStock(rewardId, newStock);
  }

  @override
  Future<void> deleteReward(String rewardId) {
    return remoteDataSource.deleteReward(rewardId);
  }

  @override
  Future<List<RedeemHistoryEntity>> getAllRedeemHistories() =>
      remoteDataSource.getAllRedeemHistories();

  @override
  Future<void> updateRedeemStatus({
    required String userId,
    required String historyId,
    required String status,
  }) {
    return remoteDataSource.updateRedeemStatus(
      userId: userId,
      historyId: historyId,
      status: status,
    );
  }

  @override
  Future<void> sendNotification({
    required String title,
    required String body,
    required String type,
    String? targetUserId,
  }) {
    return remoteDataSource.sendNotification(
      title: title,
      body: body,
      type: type,
      targetUserId: targetUserId,
    );
  }
}

