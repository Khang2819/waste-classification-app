part of 'reward_cubit.dart';

sealed class RewardState extends Equatable {
  const RewardState();

  @override
  List<Object> get props => [];
}

final class RewardInitial extends RewardState {}

final class RewardLoading extends RewardState {}

final class RewardLoaded extends RewardState {
  final List<RewardEntity> rewards;

  const RewardLoaded(this.rewards);

  @override
  List<Object> get props => [rewards];
}

final class RewardError extends RewardState {
  final String error;

  const RewardError(this.error);

  @override
  List<Object> get props => [error];
}
