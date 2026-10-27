import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

import '../../domain/entities/route_entity.dart';

class RouteModel extends RouteEntity {
  const RouteModel({
    required super.polyline,
    required super.distanceMeters,
    required super.durationSeconds,
    super.mode,
  });

  factory RouteModel.fromOsrmJson(
    Map<String, dynamic> json, {
    TravelMode mode = TravelMode.motorcycle,
  }) {
    final route = (json['routes'] as List).first;
    final geometry = route['geometry']['coordinates'] as List;

    final double distance = (route['distance'] as num).toDouble();
    final double osrmDuration = (route['duration'] as num).toDouble();

    // Tính thời gian thực tế phù hợp với từng phương tiện
    final double duration = _calculateRealisticDuration(
      distanceMeters: distance,
      osrmDuration: osrmDuration,
      mode: mode,
    );

    return RouteModel(
      polyline:
          geometry
              .map(
                (c) =>
                    LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
              )
              .toList(),
      distanceMeters: distance,
      durationSeconds: duration,
      mode: mode,
    );
  }

  /// Tính thời gian di chuyển (giây) thực tế theo từng loại phương tiện
  static double _calculateRealisticDuration({
    required double distanceMeters,
    required double osrmDuration,
    required TravelMode mode,
  }) {
    switch (mode) {
      case TravelMode.walking:
        // Đi bộ: tốc độ trung bình 4.5 km/h ≈ 1.25 m/s
        return distanceMeters / 1.25;

      case TravelMode.bicycle:
        // Xe đạp: tốc độ trung bình 14 km/h ≈ 3.89 m/s
        return distanceMeters / 3.89;

      case TravelMode.motorcycle:
        // Xe máy đô thị: trung bình khoảng 32 km/h ≈ 8.89 m/s (linh hoạt trong ngõ phố)
        final speedDuration = distanceMeters / 8.89;
        return osrmDuration > 0
            ? math.max(osrmDuration * 1.05, speedDuration)
            : speedDuration;

      case TravelMode.driving:
        // Ô tô đô thị: trung bình khoảng 24 km/h ≈ 6.67 m/s (chậm hơn xe máy do đèn đỏ, ngã tư, kẹt xe)
        final speedDuration = distanceMeters / 6.67;
        return osrmDuration > 0
            ? math.max(osrmDuration * 1.35, speedDuration)
            : speedDuration;
    }
  }

  /// Tính số phút dự kiến cho giao diện xem trước
  static int calculateEstimatedMinutes({
    required double distanceMeters,
    required TravelMode mode,
  }) {
    final seconds = _calculateRealisticDuration(
      distanceMeters: distanceMeters,
      osrmDuration: 0,
      mode: mode,
    );
    final mins = (seconds / 60).round();
    return mins < 1 ? 1 : mins;
  }
}
