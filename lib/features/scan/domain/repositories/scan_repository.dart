import 'package:waste_classification_app/features/scan/domain/entities/scan_entities.dart';

abstract class ScanRepository {
  Future<ScanEntities> scanWaste(String imagePath);
}
