part of 'history_cubit.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

final class HistoryInitial extends HistoryState {}

final class HistoryLoading extends HistoryState {}

final class HistoryLoaded extends HistoryState {
  final List<ScanHistoryEntity> history;

  const HistoryLoaded(this.history);

  @override
  List<Object> get props => [history];
}

final class HistoryError extends HistoryState {
  final String error;

  const HistoryError(this.error);

  @override
  List<Object> get props => [error];
}
