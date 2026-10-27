import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/location_entity.dart';
import '../../domain/entities/waste_point_entity.dart';
import '../../domain/usecase/add_waste_point.dart';
import '../../domain/usecase/get_current_location.dart';
import '../../domain/usecase/get_nearby_waste_points.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final GetCurrentLocation getCurrentLocation;
  final GetNearbyWastePoints getNearbyWastePoints;
  final AddWastePoint addWastePointUseCase;

  MapCubit({
    required this.getCurrentLocation,
    required this.getNearbyWastePoints,
    required this.addWastePointUseCase,
  }) : super(MapInitial());

  Future<void> getLocation() async {
    emit(MapLoading());
    try {
      final location = await getCurrentLocation();
      List<WastePointEntity> wastePoints = [];
      try {
        wastePoints = await getNearbyWastePoints(
          lat: location.latitude,
          lng: location.longitude,
        );
      } catch (_) {}
      emit(MapLoaded(location: location, wastePoints: wastePoints));
    } catch (e) {
      String errorMessage = 'Không thể lấy vị trí hiện tại';
      if (e is LocationServiceDisabledException) {
        errorMessage =
            'Dịch vụ định vị (GPS) đang tắt. Vui lòng bật GPS trên thiết bị để tiếp tục.';
      } else if (e is PermissionDeniedException) {
        errorMessage =
            e.message ?? 'Ứng dụng chưa được cấp quyền truy cập vị trí.';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      emit(MapError(errorMessage));
    }
  }

  /// Lọc các điểm đổ rác theo loại rác
  Future<void> filterWastePoints(String? wasteType) async {
    final currentState = state;
    if (currentState is! MapLoaded) return;

    try {
      final targetFilter =
          (wasteType == null || wasteType == 'Tất cả') ? null : wasteType;
      final points = await getNearbyWastePoints(
        lat: currentState.location.latitude,
        lng: currentState.location.longitude,
        wasteType: targetFilter,
      );
      emit(
        currentState.copyWith(
          wastePoints: points,
          selectedWasteType: targetFilter,
          clearFilter: targetFilter == null,
        ),
      );
    } catch (_) {}
  }

  /// Thêm điểm đổ rác mới và cập nhật bản đồ
  Future<void> addNewWastePoint(WastePointEntity point) async {
    final currentState = state;
    if (currentState is! MapLoaded) return;

    try {
      await addWastePointUseCase(point);
      final updatedList = List<WastePointEntity>.from(currentState.wastePoints)
        ..insert(0, point);
      emit(currentState.copyWith(wastePoints: updatedList));
    } catch (e) {
      rethrow;
    }
  }

  /// Tải lại danh sách điểm rác
  Future<void> refreshWastePoints() async {
    final currentState = state;
    if (currentState is! MapLoaded) return;

    try {
      final points = await getNearbyWastePoints(
        lat: currentState.location.latitude,
        lng: currentState.location.longitude,
        wasteType: currentState.selectedWasteType,
      );
      emit(currentState.copyWith(wastePoints: points));
    } catch (_) {}
  }

  void useDefaultLocation() async {
    const defaultLoc = LocationEntity(latitude: 13.7700, longitude: 109.2300);
    List<WastePointEntity> wastePoints = [];
    try {
      wastePoints = await getNearbyWastePoints(
        lat: defaultLoc.latitude,
        lng: defaultLoc.longitude,
      );
    } catch (_) {}
    emit(MapLoaded(location: defaultLoc, wastePoints: wastePoints));
  }
}
