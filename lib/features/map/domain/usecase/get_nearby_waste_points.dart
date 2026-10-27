import '../entities/waste_point_entity.dart';
import '../repositories/map_repository.dart';

class GetNearbyWastePoints {
  final LocationRepository _repository;

  GetNearbyWastePoints(this._repository);

  Future<List<WastePointEntity>> call({
    required double lat,
    required double lng,
    String? wasteType,
  }) {
    return _repository.getNearbyWastePoints(
      lat: lat,
      lng: lng,
      wasteType: wasteType,
    );
  }
}
