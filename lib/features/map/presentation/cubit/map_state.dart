part of 'map_cubit.dart';

sealed class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

final class MapInitial extends MapState {}

final class MapLoading extends MapState {}

final class MapLoaded extends MapState {
  final LocationEntity location;
  final List<WastePointEntity> wastePoints;
  final String? selectedWasteType;

  const MapLoaded({
    required this.location,
    this.wastePoints = const [],
    this.selectedWasteType,
  });

  MapLoaded copyWith({
    LocationEntity? location,
    List<WastePointEntity>? wastePoints,
    String? selectedWasteType,
    bool clearFilter = false,
  }) {
    return MapLoaded(
      location: location ?? this.location,
      wastePoints: wastePoints ?? this.wastePoints,
      selectedWasteType:
          clearFilter ? null : (selectedWasteType ?? this.selectedWasteType),
    );
  }

  @override
  List<Object?> get props => [location, wastePoints, selectedWasteType];
}

final class MapError extends MapState {
  final String message;
  const MapError(this.message);
  @override
  List<Object?> get props => [message];
}
