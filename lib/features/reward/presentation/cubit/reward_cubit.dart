import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:waste_classification_app/features/reward/domain/entities/reward_entity.dart';

import '../../domain/usecases/redeem_reward_usecase.dart';
import '../../domain/usecases/reward.dart';

part 'reward_state.dart';

class RewardCubit extends Cubit<RewardState> {
  final Reward rewardUsecase;
  final RedeemRewardUseCase redeemRewardUseCase;
  RewardCubit({required this.rewardUsecase, required this.redeemRewardUseCase})
    : super(RewardInitial());

  Future<void> getReward() async {
    emit(RewardLoading());
    try {
      final result = await rewardUsecase();
      emit(RewardLoaded(result));
    } catch (e) {
      emit(RewardError(e.toString()));
    }
  }

  Future<void> redeem({
    required String userId,
    required RewardEntity reward,
  }) async {
    emit(RewardRedeeming());
    try {
      await redeemRewardUseCase(userId: userId, reward: reward);
      emit(RewardRedeemSuccess('Đổi quà thành công!'));
      await getReward();
    } catch (e) {
      emit(RewardError(e.toString().replaceAll('Exception: ', '')));
      await getReward();
    }
  }
}
