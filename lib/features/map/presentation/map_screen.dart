import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../../core/di/injection.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../data/models/route_model.dart';
import '../domain/entities/route_entity.dart';
import '../domain/entities/waste_point_entity.dart';
import '../domain/usecase/get_route.dart';
import 'cubit/map_cubit.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSatellite = false;
  bool _isLoadingRoute = false;

  // Đổi thành null để không hiển thị ghim đỏ mặc định ban đầu
  LatLng? _destinationPoint;

  // Phương tiện di chuyển được chọn (mặc định: Xe máy)
  TravelMode _selectedMode = TravelMode.motorcycle;

  // Tuyến đường thực tế được tính bởi GetRoute use case
  RouteEntity? _currentRoute;

  @override
  void initState() {
    super.initState();
    context.read<MapCubit>().getLocation();
  }

  bool _isSearching = false;

  Future<void> _searchAddress(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    final mapState = context.read<MapCubit>().state;
    if (mapState is! MapLoaded) {
      _showErrorSnackBar("Chưa xác định được vị trí của bạn.");
      return;
    }
    final startPoint = LatLng(
      mapState.location.latitude,
      mapState.location.longitude,
    );

    setState(() => _isSearching = true);
    FocusScope.of(context).unfocus();

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'q=${Uri.encodeComponent(cleanQuery)}&format=json&limit=5&addressdetails=1',
      );

      final response = await http
          .get(
            url,
            headers: {
              // Bắt buộc: Nominatim chặn 403 nếu User-Agent chung chung hoặc rỗng.
              // Cần định dạng: TênApp/PhiênBản (email@domain.com)
              'User-Agent':
                  'SmartWasteClassificationProject/1.0.0 (contact@smartwaste.edu.vn)',
              'Accept': 'application/json',
              'Accept-Language': 'vi-VN,vi;q=0.9,en;q=0.8',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data.isNotEmpty) {
          final double? lat = double.tryParse(data[0]['lat'].toString());
          final double? lon = double.tryParse(data[0]['lon'].toString());

          if (lat != null && lon != null) {
            final targetPoint = LatLng(lat, lon);

            setState(() {
              _destinationPoint = targetPoint;
            });

            // Di chuyển bản đồ đến điểm đến
            _mapController.move(targetPoint, 15.5);

            // Vẽ tuyến đường
            await _fetchRoute(startPoint, targetPoint);
            return;
          }
        }
        _showErrorSnackBar("Không tìm thấy địa điểm: \"$cleanQuery\"");
      } else if (response.statusCode == 403) {
        // Dự phòng nếu IP mạng WiFi/4G bị rate-limit của OSM: Gọi sang fallback Photon
        await _searchFallback(cleanQuery, startPoint);
      } else {
        _showErrorSnackBar("Máy chủ phản hồi lỗi: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Lỗi tìm kiếm: $e");
      // Thử fallback nếu mất kết nối
      await _searchFallback(cleanQuery, startPoint);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // Hàm dự phòng (Fallback) khi mạng bị chặn 403
  Future<void> _searchFallback(String query, LatLng startPoint) async {
    try {
      final fallbackUrl = Uri.parse(
        'https://photon.komoot.io/api/?q=${Uri.encodeComponent(query)}&limit=3',
      );

      final res = await http
          .get(
            fallbackUrl,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        final List<dynamic> features = data['features'] ?? [];
        if (features.isNotEmpty) {
          final List<dynamic> coords = features[0]['geometry']['coordinates'];
          final double lon = (coords[0] as num).toDouble();
          final double lat = (coords[1] as num).toDouble();

          final targetPoint = LatLng(lat, lon);
          setState(() {
            _destinationPoint = targetPoint;
          });

          _mapController.move(targetPoint, 15.5);
          await _fetchRoute(startPoint, targetPoint);
          return;
        }
      }
      _showErrorSnackBar("Không tìm thấy địa điểm phù hợp.");
    } catch (err) {
      _showErrorSnackBar("Lỗi mạng khi tìm kiếm. Vui lòng thử lại!");
    }
  }

  /// Xóa điểm đến và tuyến đường
  void _clearDestination() {
    setState(() {
      _destinationPoint = null;
      _currentRoute = null;
    });
  }

  Future<void> _fetchRoute(
    LatLng start,
    LatLng destination, {
    TravelMode? mode,
  }) async {
    final targetMode = mode ?? _selectedMode;
    setState(() => _isLoadingRoute = true);

    try {
      final route = await getIt<GetRoute>()(
        startLat: start.latitude,
        startLng: start.longitude,
        endLat: destination.latitude,
        endLng: destination.longitude,
        mode: targetMode,
      );
      if (mounted) {
        setState(() {
          _currentRoute = route;
        });
      }
    } catch (e) {
      _showErrorSnackBar("Không thể tìm tuyến đường: $e");
    } finally {
      if (mounted) setState(() => _isLoadingRoute = false);
    }
  }

  /// Đổi phương tiện di chuyển và tự động tính lại lộ trình nếu đã chọn điểm đến
  void _changeTravelMode(TravelMode mode) {
    if (_selectedMode == mode) return;
    setState(() {
      _selectedMode = mode;
    });

    final mapState = context.read<MapCubit>().state;
    if (mapState is MapLoaded && _destinationPoint != null) {
      final startPoint = LatLng(
        mapState.location.latitude,
        mapState.location.longitude,
      );
      _fetchRoute(startPoint, _destinationPoint!, mode: mode);
    }
  }

  IconData _getModeIcon(TravelMode mode) {
    switch (mode) {
      case TravelMode.motorcycle:
        return Icons.two_wheeler_rounded;
      case TravelMode.driving:
        return Icons.directions_car_rounded;
      case TravelMode.bicycle:
        return Icons.directions_bike_rounded;
      case TravelMode.walking:
        return Icons.directions_walk_rounded;
    }
  }

  Color _getRouteColor(TravelMode mode) {
    switch (mode) {
      case TravelMode.motorcycle:
        return const Color(0xFF2E7D32); // Xanh lá cây (Xe máy)
      case TravelMode.driving:
        return const Color(0xFF1976D2); // Xanh dương (Ô tô)
      case TravelMode.bicycle:
        return const Color(0xFF00897B); // Xanh ngọc (Xe đạp)
      case TravelMode.walking:
        return const Color(0xFFFF6D00); // Cam (Đi bộ)
    }
  }

  /// Thanh chọn phương tiện di chuyển dạng thẻ nổi (hiển thị dưới thanh tìm kiếm)
  Widget _buildFloatingModeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children:
                TravelMode.values.map((mode) {
                  final isSelected = _selectedMode == mode;
                  final modeColor = _getRouteColor(mode);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () => _changeTravelMode(mode),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? modeColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getModeIcon(mode),
                              size: 16,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              mode.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  /// Thanh chọn phương tiện trong Card thông tin lộ trình bên dưới
  Widget _buildModeSelectorInCard() {
    return Row(
      children:
          TravelMode.values.map((mode) {
            final isSelected = _selectedMode == mode;
            final modeColor = _getRouteColor(mode);
            final estMins =
                _currentRoute != null
                    ? RouteModel.calculateEstimatedMinutes(
                      distanceMeters: _currentRoute!.distanceMeters,
                      mode: mode,
                    )
                    : null;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => _changeTravelMode(mode),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? modeColor.withValues(alpha: 0.12)
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? modeColor : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getModeIcon(mode),
                          color: isSelected ? modeColor : Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          mode.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color:
                                isSelected ? modeColor : Colors.grey.shade700,
                          ),
                        ),
                        if (estMins != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            estMins < 60
                                ? '$estMins p'
                                : '${estMins ~/ 60}h${estMins % 60}p',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color:
                                  isSelected ? modeColor : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  /// Bộ lọc nhanh loại rác (hiển thị dưới thanh phương tiện)
  Widget _buildWasteTypeFilter(String? selectedFilter) {
    const types = [
      'Tất cả',
      'Rác tái chế',
      'Rác hữu cơ',
      'Rác vô cơ',
      'Rác nguy hại',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: types.map((type) {
          final isSelected =
              (selectedFilter == null && type == 'Tất cả') ||
              (selectedFilter == type);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: FilterChip(
              selected: isSelected,
              label: Text(type),
              labelStyle: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
              selectedColor: const Color(0xFF2E7D32),
              backgroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color:
                      isSelected
                          ? const Color(0xFF2E7D32)
                          : Colors.grey.shade300,
                ),
              ),
              showCheckmark: false,
              onSelected: (_) {
                context.read<MapCubit>().filterWastePoints(
                  type == 'Tất cả' ? null : type,
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Marker hiển thị từng điểm đổ rác trên bản đồ
  Marker _buildWastePointMarker(WastePointEntity point, LatLng startPoint) {
    Color markerColor;
    IconData markerIcon;
    switch (point.status) {
      case WastePointStatus.active:
        markerColor = const Color(0xFF2E7D32); // Xanh lá
        markerIcon = Icons.recycling_rounded;
        break;
      case WastePointStatus.full:
        markerColor = const Color(0xFFD32F2F); // Đỏ (thùng đầy)
        markerIcon = Icons.delete_forever_rounded;
        break;
      case WastePointStatus.inactive:
        markerColor = const Color(0xFF757575); // Xám
        markerIcon = Icons.pause_circle_outline_rounded;
        break;
    }

    return Marker(
      point: LatLng(point.latitude, point.longitude),
      width: 46,
      height: 46,
      child: GestureDetector(
        onTap: () => _showWastePointDetailModal(point, startPoint),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                markerIcon,
                color: Colors.white,
                size: 20,
              ),
            ),
            if (point.status == WastePointStatus.full)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade900,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Text(
                    'ĐẦY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Modal xem chi tiết thông tin điểm đổ rác & nút Chỉ đường
  void _showWastePointDetailModal(WastePointEntity point, LatLng startPoint) {
    final distanceMeters = Geolocator.distanceBetween(
      startPoint.latitude,
      startPoint.longitude,
      point.latitude,
      point.longitude,
    );

    final String distanceText =
        distanceMeters < 1000
            ? '${distanceMeters.round()} m'
            : '${(distanceMeters / 1000).toStringAsFixed(1)} km';

    Color statusColor;
    switch (point.status) {
      case WastePointStatus.active:
        statusColor = const Color(0xFF2E7D32);
        break;
      case WastePointStatus.full:
        statusColor = const Color(0xFFD32F2F);
        break;
      case WastePointStatus.inactive:
        statusColor = const Color(0xFF757575);
        break;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: statusColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          point.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            point.statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (point.address != null && point.address!.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        point.address!,
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  const Icon(Icons.straighten_rounded, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Cách bạn khoảng: $distanceText',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Các loại rác tiếp nhận:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: point.wasteTypes.map((type) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final dest = LatLng(point.latitude, point.longitude);
                    setState(() {
                      _destinationPoint = dest;
                    });
                    _mapController.move(dest, 16.0);
                    _fetchRoute(startPoint, dest, mode: _selectedMode);
                  },
                  icon: const Icon(Icons.directions_rounded),
                  label: const Text(
                    'Chỉ đường đến điểm này',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
      body: Stack(
        children: [
          BlocBuilder<MapCubit, MapState>(
            builder: (context, state) {
              if (state is MapLoading || state is MapInitial) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF2E7D32)),
                      SizedBox(height: 16),
                      Text(
                        'Đang xác định vị trí...',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (state is MapError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_off_rounded,
                            size: 48,
                            color: Colors.red.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Không thể xác định vị trí',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                context.read<MapCubit>().useDefaultLocation();
                              },
                              icon: const Icon(Icons.map_rounded, size: 18),
                              label: const Text('Vị trí mặc định'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2E7D32),
                                side: const BorderSide(
                                  color: Color(0xFF2E7D32),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<MapCubit>().getLocation();
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Thử lại'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () async {
                            await Geolocator.openAppSettings();
                          },
                          child: const Text(
                            'Mở cài đặt quyền ứng dụng',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (state is MapLoaded) {
                final location = state.location;
                final startPoint = LatLng(
                  location.latitude,
                  location.longitude,
                );
                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      location.latitude,
                      location.longitude,
                    ),
                    initialZoom: 14.5,
                    minZoom: 3.0,
                    maxZoom: 20.0,
                    onTap: (tapPosition, point) {
                      setState(() => _destinationPoint = point);
                      _fetchRoute(startPoint, point);
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
                      userAgentPackageName:
                          'com.example.wasteClassificationApp',
                    ),
                    // Vẽ tuyến đường
                    if (_currentRoute != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _currentRoute!.polyline,
                            strokeWidth: 5.0,
                            color: _getRouteColor(_currentRoute!.mode),
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        // Vị trí người dùng
                        Marker(
                          point: startPoint,
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // ignore: deprecated_member_use
                              color: Colors.blueAccent.withOpacity(0.2),
                            ),
                            child: Center(
                              child: Container(
                                height: 16,
                                width: 16,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Marker điểm đích (nút đỏ)
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
                        // Markers các điểm đổ rác xung quanh
                        ...state.wastePoints.map(
                          (point) => _buildWastePointMarker(point, startPoint),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Search bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                      child: CustomTextField(
                        hintText: 'Tìm kiếm địa chỉ...',
                        controller: _searchController,
                        prefixIcon: Icons.search_rounded,
                        onChanged: (p0) {
                          setState(() {
                            _searchQuery = p0;
                          });
                        },
                        onSubmitted: (value) => _searchAddress(value),
                        suffixIcon:
                            _isSearching
                                ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                )
                                : _searchQuery.isNotEmpty
                                ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 18,
                                  ),
                                )
                                : null,
                      ),
                    ),
                    if (_currentRoute == null) ...[
                      const SizedBox(height: 8),
                      _buildFloatingModeSelector(),
                      const SizedBox(height: 8),
                      BlocBuilder<MapCubit, MapState>(
                        builder: (context, mapState) {
                          if (mapState is MapLoaded) {
                            return _buildWasteTypeFilter(
                              mapState.selectedWasteType,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Nút vệ tinh
          Positioned(
            bottom: _currentRoute != null ? 220 : 160,
            right: 12,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() => _isSatellite = !_isSatellite);
                },
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.layers, color: Color(0xFF2E7D32)),
                ),
              ),
            ),
          ),
          // Nút vị trí của tôi
          Positioned(
            bottom: _currentRoute != null ? 160 : 100,
            right: 12,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  final state = context.read<MapCubit>().state;
                  if (state is MapLoaded) {
                    _mapController.move(
                      LatLng(state.location.latitude, state.location.longitude),
                      17.0,
                    );
                  } else {
                    context.read<MapCubit>().getLocation();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.my_location, color: Color(0xFF2E7D32)),
                ),
              ),
            ),
          ),
          // Loading route indicator
          if (_isLoadingRoute)
            Positioned(
              top: 150,
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
          // Card thông tin tuyến đường và bộ chọn phương tiện
          if (_currentRoute != null)
            Positioned(
              bottom: 16,
              left: 14,
              right: 14,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bộ chọn phương tiện (Xe máy, Ô tô, Xe đạp, Đi bộ)
                      _buildModeSelectorInCard(),
                      const Divider(height: 20),
                      // Hàng thông tin chi tiết
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getRouteColor(
                                _currentRoute!.mode,
                              ).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getModeIcon(_currentRoute!.mode),
                              color: _getRouteColor(_currentRoute!.mode),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Điểm đến (${_currentRoute!.mode.label})",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (_isLoadingRoute) ...[
                                      const SizedBox(width: 8),
                                      const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Khoảng cách: ${_currentRoute!.formattedDistance}  •  ${_currentRoute!.formattedDuration}",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: "Xóa điểm & hủy chỉ đường",
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.redAccent,
                            ),
                            onPressed: _clearDestination,
                          ),
                        ],
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
