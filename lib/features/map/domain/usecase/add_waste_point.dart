import '../entities/waste_point_entity.dart';
import '../repositories/map_repository.dart';

class AddWastePoint {
  final LocationRepository _repository;

  AddWastePoint(this._repository);

  Future<void> call(WastePointEntity wastePoint) {
    return _repository.addWastePoint(wastePoint);
  }
}
