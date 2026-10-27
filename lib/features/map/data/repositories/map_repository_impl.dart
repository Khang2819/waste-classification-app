import '../../domain/entities/route_entity.dart';
import '../../domain/entities/waste_point_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/location_data_source.dart';
import '../datasources/routing_data_source.dart';
import '../datasources/waste_point_data_source.dart';
import '../models/location_model.dart';
import '../models/route_model.dart';
import '../models/waste_point_model.dart';

class MapRepositoryImpl implements LocationRepository {
  final LocationDataSource remoteDataSource;
  final RoutingDataSource _routingDataSource;
  final WastePointDataSource _wastePointDataSource;

  MapRepositoryImpl(
    this._routingDataSource,
    this.remoteDataSource,
    this._wastePointDataSource,
  );

  @override
  Future<LocationModel> getCurrentLocation() async {
    return await remoteDataSource.getCurrentLocation();
  }

  @override
  Future<RouteModel> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    TravelMode mode = TravelMode.motorcycle,
  }) {
    return _routingDataSource.getRoute(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      mode: mode,
    );
  }

  @override
  Future<List<WastePointEntity>> getNearbyWastePoints({
    required double lat,
    required double lng,
    String? wasteType,
  }) {
    return _wastePointDataSource.getNearbyWastePoints(
      lat: lat,
      lng: lng,
      wasteType: wasteType,
    );
  }

  @override
  Future<void> addWastePoint(WastePointEntity wastePoint) async {
    final model = WastePointModel(
      id: wastePoint.id,
      name: wastePoint.name,
      latitude: wastePoint.latitude,
      longitude: wastePoint.longitude,
      wasteTypes: wastePoint.wasteTypes,
      address: wastePoint.address,
      status: wastePoint.status,
    );
    await _wastePointDataSource.addWastePoint(model);
  }
}
