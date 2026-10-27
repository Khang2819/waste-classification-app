import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/waste_point_entity.dart';

class WastePointModel extends WastePointEntity {
  const WastePointModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.wasteTypes,
    super.address,
    required super.status,
  });

  factory WastePointModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return WastePointModel.fromJson(data, id: doc.id);
  }

  factory WastePointModel.fromJson(Map<String, dynamic> json, {String? id}) {
    // Parse status
    WastePointStatus status = WastePointStatus.active;
    final statusStr = json['status']?.toString().toLowerCase();
    if (statusStr == 'full') {
      status = WastePointStatus.full;
    } else if (statusStr == 'inactive') {
      status = WastePointStatus.inactive;
    }

    // Parse wasteTypes
    List<String> types = [];
    if (json['wasteTypes'] is List) {
      types = (json['wasteTypes'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (json['wasteType'] != null) {
      types = [json['wasteType'].toString()];
    }

    // Parse coordinates (support both GeoPoint and double)
    double lat = 0.0;
    double lng = 0.0;
    if (json['position'] is GeoPoint) {
      final geo = json['position'] as GeoPoint;
      lat = geo.latitude;
      lng = geo.longitude;
    } else {
      lat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
      lng = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    }

    return WastePointModel(
      id: id ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Điểm tập kết rác',
      latitude: lat,
      longitude: lng,
      wasteTypes: types.isNotEmpty ? types : const ['Rác tái chế'],
      address: json['address']?.toString(),
      status: status,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'wasteTypes': wasteTypes,
      'address': address ?? '',
      'status': status.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'wasteTypes': wasteTypes,
      'address': address ?? '',
      'status': status.name,
    };
  }
}
