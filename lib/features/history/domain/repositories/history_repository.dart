import '../entities/scan_history_entity.dart';

abstract class HistoryRepository {
  Stream<List<ScanHistoryEntity>> getScanHistories(String userId);

  Future<void> deleteScanHistory(String userId, String historyId);

  Future<void> saveHistory(
    String userId,
    String label,
    String instruction,
    double confidence,
    String imagePath,
    String? category,
    int? pointsEarned,
  );
}
