import '../entities/location_entity.dart';
import '../entities/route_entity.dart';
import '../entities/waste_point_entity.dart';

abstract class LocationRepository {
  Future<LocationEntity> getCurrentLocation();

  Future<RouteEntity> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    TravelMode mode = TravelMode.motorcycle,
  });

  Future<List<WastePointEntity>> getNearbyWastePoints({
    required double lat,
    required double lng,
    String? wasteType,
  });

  Future<void> addWastePoint(WastePointEntity wastePoint);
}
