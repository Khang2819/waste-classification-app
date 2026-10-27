import 'package:equatable/equatable.dart';

enum WastePointStatus { active, full, inactive }

class WastePointEntity extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final List<String> wasteTypes;
  final String? address;
  final WastePointStatus status;

  const WastePointEntity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.wasteTypes,
    this.address,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case WastePointStatus.active:
        return 'Đang hoạt động';
      case WastePointStatus.full:
        return 'Thùng đã đầy';
      case WastePointStatus.inactive:
        return 'Tạm ngưng tiếp nhận';
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    latitude,
    longitude,
    wasteTypes,
    address,
    status,
  ];
}
