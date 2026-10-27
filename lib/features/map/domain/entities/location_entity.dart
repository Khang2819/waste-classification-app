import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final double? accuracy;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });
  @override
  List<Object?> get props => [latitude, longitude, accuracy];
}
