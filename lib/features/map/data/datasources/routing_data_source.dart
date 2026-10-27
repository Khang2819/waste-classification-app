import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/route_entity.dart';
import '../models/route_model.dart';

abstract class RoutingDataSource {
  Future<RouteModel> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    TravelMode mode = TravelMode.motorcycle,
  });
}

class RoutingRemoteDataSourceImpl implements RoutingDataSource {
  final http.Client _client;

  RoutingRemoteDataSourceImpl({http.Client? client})
    : _client = client ?? http.Client();

  @override
  Future<RouteModel> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    TravelMode mode = TravelMode.motorcycle,
  }) async {
    final profile = mode.profile;
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/$profile/'
      '$startLng,$startLat;$endLng,$endLat'
      '?overview=full&geometries=geojson',
    );

    final response = await _client
        .get(url)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Lỗi OSRM: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List;

    if (routes.isEmpty) {
      throw Exception('Không tìm thấy tuyến đường');
    }

    return RouteModel.fromOsrmJson(data, mode: mode);
  }
}
