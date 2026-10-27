import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

enum TravelMode {
  motorcycle(profile: 'driving', label: 'Xe máy'),
  driving(profile: 'driving', label: 'Ô tô'),
  bicycle(profile: 'bike', label: 'Xe đạp'),
  walking(profile: 'foot', label: 'Đi bộ');

  final String profile;
  final String label;

  const TravelMode({required this.profile, required this.label});
}

class RouteEntity extends Equatable {
  final List<LatLng> polyline;
  final double distanceMeters;
  final double durationSeconds;
  final TravelMode mode;

  const RouteEntity({
    required this.polyline,
    required this.distanceMeters,
    required this.durationSeconds,
    this.mode = TravelMode.motorcycle,
  });

  double get distanceKm => distanceMeters / 1000;
  double get durationMinutes => durationSeconds / 60;

  String get formattedDuration {
    final int totalMinutes = durationMinutes.round();
    if (totalMinutes < 1) {
      return '< 1 phút';
    } else if (totalMinutes < 60) {
      return '$totalMinutes phút';
    } else {
      final int hours = totalMinutes ~/ 60;
      final int minutes = totalMinutes % 60;
      if (minutes == 0) {
        return '$hours giờ';
      }
      return '$hours giờ $minutes phút';
    }
  }

  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  @override
  List<Object> get props => [polyline, distanceMeters, durationSeconds, mode];
}
