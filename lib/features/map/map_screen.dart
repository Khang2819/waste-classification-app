import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  bool _isSatellite = false;
  bool _isLoadingRoute = false;

  // Điểm xuất phát mẫu (Vị trí hiện tại của người dùng)
  final LatLng _startPoint = const LatLng(13.7563, 109.2197);

  // Điểm đến mẫu (Điểm tập kết thu gom rác)
  LatLng? _destinationPoint = const LatLng(13.7700, 109.2300);

  // Danh sách các tọa độ tạo thành tuyến đường nối liền
  List<LatLng> _routeCoordinates = [];

  // Thông số hành trình
  double _distanceKm = 0.0;
  double _durationMinutes = 0.0;

  @override
  void initState() {
    super.initState();
    // Tự động tìm đường đến điểm đích mặc định khi khởi tạo màn hình
    if (_destinationPoint != null) {
      _fetchRoute(_startPoint, _destinationPoint!);
    }
  }

  /// Gọi API OSRM để lấy đường dẫn thực tế bám sát giao thông
  Future<void> _fetchRoute(LatLng start, LatLng destination) async {
    setState(() => _isLoadingRoute = true);

    // OSRM nhận định dạng: {kinh_độ},{vĩ_độ} (longitude,latitude)
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List<dynamic>;

        if (routes.isNotEmpty) {
          final geometry =
              routes[0]['geometry']['coordinates'] as List<dynamic>;
          final double distance =
              (routes[0]['distance'] as num).toDouble(); // mét
          final double duration =
              (routes[0]['duration'] as num).toDouble(); // giây

          setState(() {
            _routeCoordinates =
                geometry
                    .map(
                      (coord) => LatLng(coord[1] as double, coord[0] as double),
                    )
                    .toList();
            _distanceKm = distance / 1000.0;
            _durationMinutes = duration / 60.0;
          });
        }
      } else {
        _showErrorSnackBar(
          "Không thể tải tuyến đường (Mã: ${response.statusCode})",
        );
      }
    } catch (e) {
      _showErrorSnackBar("Lỗi kết nối định tuyến: $e");
    } finally {
      setState(() => _isLoadingRoute = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Định tuyến & Thu gom rác"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _startPoint,
              initialZoom: 14.5,
              minZoom: 3.0,
              maxZoom: 20.0,
              // Cho phép chạm vào điểm bất kỳ trên bản đồ để đổi đích đến
              onTap: (tapPosition, point) {
                setState(() => _destinationPoint = point);
                _fetchRoute(_startPoint, point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    _isSatellite
                        ? 'https://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}'
                        : 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                subdomains:
                    _isSatellite
                        ? const ['mt0', 'mt1', 'mt2', 'mt3']
                        : const ['a', 'b'],
                userAgentPackageName: 'com.example.wasteClassificationApp',
              ),

              // Vẽ tuyến đường định tuyến
              if (_routeCoordinates.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routeCoordinates,
                      strokeWidth: 5.0,
                      color: const Color(
                        0xFF1976D2,
                      ), // Màu xanh dương dẫn đường
                    ),
                  ],
                ),

              // Marker hiển thị điểm đi và điểm đến
              MarkerLayer(
                markers: [
                  // Marker điểm xuất phát (Người dùng)
                  Marker(
                    point: _startPoint,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blueAccent,
                      size: 36,
                    ),
                  ),

                  // Marker điểm đến (Điểm thu gom)
                  if (_destinationPoint != null)
                    Marker(
                      point: _destinationPoint!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.redAccent,
                        size: 44,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Nút chuyển đổi kiểu bản đồ
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.extended(
              heroTag: 'toggle_map_mode',
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2E7D32),
              elevation: 4,
              onPressed: () {
                setState(() => _isSatellite = !_isSatellite);
              },
              icon: Icon(
                _isSatellite ? Icons.map_outlined : Icons.satellite_alt_rounded,
                color: const Color(0xFF2E7D32),
              ),
              label: Text(
                _isSatellite ? "Đường phố" : "Vệ tinh",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Vòng xoay tiến trình khi đang tính toán lộ trình
          if (_isLoadingRoute)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Đang tìm đường...",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          if (_routeCoordinates.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_car_filled_rounded,
                          color: Color(0xFF2E7D32),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Điểm tập kết rác thải",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Khoảng cách: ${_distanceKm.toStringAsFixed(1)} km  •  Khoảng ${_durationMinutes.toStringAsFixed(0)} phút",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: "Căn giữa tuyến đường",
                        icon: const Icon(
                          Icons.center_focus_strong,
                          color: Color(0xFF2E7D32),
                        ),
                        onPressed: () {
                          if (_destinationPoint != null) {
                            _mapController.move(_destinationPoint!, 14.5);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
