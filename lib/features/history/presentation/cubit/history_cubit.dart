import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/scan_history_entity.dart';
import '../../domain/usecases/history_usecases.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final DeleteHistoryUsecases deleteHistoryUsecases;
  final GetScanHistoriesUseCase getScanHistoriesUseCase;
  final SaveHistoryUsecases? saveHistoryUsecases;

  StreamSubscription<List<ScanHistoryEntity>>? _streamSubscription;

  HistoryCubit({
    required this.deleteHistoryUsecases,
    required this.getScanHistoriesUseCase,
    this.saveHistoryUsecases,
  }) : super(HistoryInitial());

  void listenHistory(String userId) {
    emit(HistoryLoading());
    _streamSubscription?.cancel();
    _streamSubscription = getScanHistoriesUseCase(userId).listen(
      (history) {
        emit(HistoryLoaded(history));
      },
      onError: (e) {
        emit(HistoryError(e.toString()));
      },
    );
  }

  Future<void> deleteHistory(String userId, String historyId) async {
    try {
      await deleteHistoryUsecases(userId, historyId);
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> saveHistory({
    required String userId,
    required String label,
    required String instruction,
    required double confidence,
    required String imagePath,
    String? category,
    int? pointsEarned,
  }) async {
    try {
      await saveHistoryUsecases?.saveHistory(
        userId,
        label,
        instruction,
        confidence,
        imagePath,
        category,
        pointsEarned,
      );
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
