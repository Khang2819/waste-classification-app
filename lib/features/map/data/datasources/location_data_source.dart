import 'package:geolocator/geolocator.dart';

import '../models/location_model.dart';

abstract class LocationDataSource {
  Future<LocationModel> getCurrentLocation();
}

class LocationRemoteDataSourceImpl implements LocationDataSource {
  final GeolocatorPlatform _geolocator;
  LocationRemoteDataSourceImpl({GeolocatorPlatform? geolocator})
    : _geolocator = geolocator ?? GeolocatorPlatform.instance;
  @override
  Future<LocationModel> getCurrentLocation() async {
    final serviceEnabled = await _geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException();
    }
    LocationPermission permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw PermissionDeniedException('Quyền truy cập vị trí bị từ chối');
    }

    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException(
        'Quyền truy cập vị trí bị từ chối vĩnh viễn. '
        'Vui lòng mở Cài đặt để cấp quyền.',
      );
    }
    final position = await _geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return LocationModel.fromPosition(position);
  }
}
