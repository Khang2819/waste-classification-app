import '../../domain/entities/scan_history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_data_sources.dart';
import '../models/history_models.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSources remoteDataSources;

  HistoryRepositoryImpl({required this.remoteDataSources});

  @override
  Stream<List<ScanHistoryEntity>> getScanHistories(String userId) {
    return remoteDataSources.getAllHistory(userId);
  }

  @override
  Future<void> deleteScanHistory(String userId, String historyId) {
    return remoteDataSources.deleteHistory(userId, historyId);
  }

  @override
  Future<void> saveHistory(
    String userId,
    String label,
    String instruction,
    double confidence,
    String imagePath,
    String? category,
    int? pointsEarned,
  ) {
    final history = HistoryModels(
      id: '',
      userId: userId,
      label: label,
      category: category ?? 'Rác tái chế',
      confidence: confidence,
      instruction: instruction,
      imagePath: imagePath,
      pointsEarned: pointsEarned ?? 10,
      createdAt: DateTime.now(),
    );
    return remoteDataSources.saveHistory(userId, history);
  }
}
