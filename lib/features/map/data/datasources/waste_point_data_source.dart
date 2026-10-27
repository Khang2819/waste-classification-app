import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/waste_point_entity.dart';
import '../models/waste_point_model.dart';

abstract class WastePointDataSource {
  Future<List<WastePointModel>> getNearbyWastePoints({
    required double lat,
    required double lng,
    String? wasteType,
  });

  Future<void> addWastePoint(WastePointModel wastePoint);
}

class WastePointRemoteDataSourceImpl implements WastePointDataSource {
  final FirebaseFirestore _firestore;

  WastePointRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<WastePointModel>> getNearbyWastePoints({
    required double lat,
    required double lng,
    String? wasteType,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('waste_points')
          .get()
          .timeout(const Duration(seconds: 8));

      List<WastePointModel> points =
          snapshot.docs
              .map((doc) => WastePointModel.fromFirestore(doc))
              .toList();

      // Nếu Firestore chưa có điểm nào, tự tạo các điểm mẫu xung quanh vị trí người dùng
      if (points.isEmpty) {
        points = _generateInitialPoints(lat, lng);
        _seedInitialPoints(points);
      }

      // Lọc theo loại rác nếu có yêu cầu
      if (wasteType != null && wasteType.isNotEmpty && wasteType != 'Tất cả') {
        points =
            points
                .where(
                  (p) => p.wasteTypes.any(
                    (t) => t.toLowerCase().contains(wasteType.toLowerCase()),
                  ),
                )
                .toList();
      }

      return points;
    } catch (_) {
      // Fallback về các điểm mẫu quanh vị trí hiện tại nếu gặp lỗi mạng hoặc Firestore rỗng
      final fallback = _generateInitialPoints(lat, lng);
      if (wasteType != null && wasteType.isNotEmpty && wasteType != 'Tất cả') {
        return fallback
            .where(
              (p) => p.wasteTypes.any(
                (t) => t.toLowerCase().contains(wasteType.toLowerCase()),
              ),
            )
            .toList();
      }
      return fallback;
    }
  }

  @override
  Future<void> addWastePoint(WastePointModel wastePoint) async {
    await _firestore.collection('waste_points').add(wastePoint.toFirestore());
  }

  void _seedInitialPoints(List<WastePointModel> points) {
    try {
      final batch = _firestore.batch();
      final collection = _firestore.collection('waste_points');
      for (final p in points) {
        batch.set(collection.doc(), p.toFirestore());
      }
      batch.commit().catchError((_) {});
    } catch (_) {}
  }

  List<WastePointModel> _generateInitialPoints(double lat, double lng) {
    return [
      WastePointModel(
        id: 'seed_1',
        name: 'Trạm thu gom rác tái chế Xanh',
        latitude: lat + 0.0032,
        longitude: lng + 0.0025,
        wasteTypes: const ['Rác tái chế', 'Chai nhựa', 'Giấy'],
        address: 'Số 12 Đường Hoa Phượng, gần công viên',
        status: WastePointStatus.active,
      ),
      WastePointModel(
        id: 'seed_2',
        name: 'Điểm tập kết rác sinh hoạt Phường',
        latitude: lat - 0.0028,
        longitude: lng - 0.0035,
        wasteTypes: const ['Rác hữu cơ', 'Rác vô cơ'],
        address: 'Khu dân cư số 4, gần chợ dân sinh',
        status: WastePointStatus.active,
      ),
      WastePointModel(
        id: 'seed_3',
        name: 'Thùng rác phân loại thông minh Co.opmart',
        latitude: lat + 0.0018,
        longitude: lng - 0.0038,
        wasteTypes: const ['Rác tái chế', 'Rác nguy hại (Pin, bóng đèn)'],
        address: 'Trước sảnh siêu thị Co.opmart',
        status: WastePointStatus.active,
      ),
      WastePointModel(
        id: 'seed_4',
        name: 'Trạm tiếp nhận rác điện tử & tái chế',
        latitude: lat - 0.0042,
        longitude: lng + 0.0032,
        wasteTypes: const ['Rác tái chế', 'Rác nguy hại', 'Kim loại'],
        address: 'Cổng phụ Nhà văn hóa thanh niên',
        status: WastePointStatus.active,
      ),
      WastePointModel(
        id: 'seed_5',
        name: 'Điểm thu gom rác công cộng ngã tư',
        latitude: lat + 0.0042,
        longitude: lng - 0.0016,
        wasteTypes: const ['Rác hữu cơ', 'Rác tái chế'],
        address: 'Góc ngã tư đường chính',
        status: WastePointStatus.full,
      ),
    ];
  }
}
