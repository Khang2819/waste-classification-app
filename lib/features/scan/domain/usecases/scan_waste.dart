import 'package:waste_classification_app/features/scan/domain/entities/scan_entities.dart';
import 'package:waste_classification_app/features/scan/domain/repositories/scan_repository.dart';

class ScanWaste {
  final ScanRepository repository;

  ScanWaste(this.repository);

  Future<ScanEntities> call(String imagePath) {
    return repository.scanWaste(imagePath);
  }
}
