import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:waste_classification_app/features/reward/domain/entities/reward_entity.dart';

import '../../domain/usecases/reward.dart';

part 'reward_state.dart';

class RewardCubit extends Cubit<RewardState> {
  final Reward rewardUsecase;
  RewardCubit({required this.rewardUsecase}) : super(RewardInitial());

  Future<void> getReward() async {
    emit(RewardLoading());
    try {
      final result = await rewardUsecase();
      emit(RewardLoaded(result));
    } catch (e) {
      emit(RewardError(e.toString()));
    }
  }
}
