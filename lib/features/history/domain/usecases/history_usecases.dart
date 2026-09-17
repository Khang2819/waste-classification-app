import 'package:waste_classification_app/features/history/domain/entities/scan_history_entity.dart';

import '../repositories/history_repository.dart';

class DeleteHistoryUsecases {
  final HistoryRepository repository;

  DeleteHistoryUsecases(this.repository);

  Future<void> call(String userId, String historyId) {
    return repository.deleteScanHistory(userId, historyId);
  }
}

class GetScanHistoriesUseCase {
  final HistoryRepository repository;

  GetScanHistoriesUseCase(this.repository);

  Stream<List<ScanHistoryEntity>> call(String userId) {
    return repository.getScanHistories(userId);
  }
}

class SaveHistoryUsecases {
  final HistoryRepository repository;

  SaveHistoryUsecases(this.repository);

  Future<void> saveHistory(
    String userId,
    String label,
    String instruction,
    double confidence,
    String imagePath,
    String? category,
    int? pointsEarned,
  ) {
    return repository.saveHistory(
      userId,
      label,
      instruction,
      confidence,
      imagePath,
      category,
      pointsEarned,
    );
  }
}
