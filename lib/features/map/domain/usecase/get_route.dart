import '../entities/route_entity.dart';
import '../repositories/map_repository.dart';

class GetRoute {
  final LocationRepository _repository;

  GetRoute(this._repository);

  Future<RouteEntity> call({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    TravelMode mode = TravelMode.motorcycle,
  }) {
    return _repository.getRoute(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      mode: mode,
    );
  }
}
