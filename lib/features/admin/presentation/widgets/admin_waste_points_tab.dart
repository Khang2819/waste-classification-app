import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../map/domain/entities/waste_point_entity.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminWastePointsTab extends StatefulWidget {
  const AdminWastePointsTab({super.key});

  @override
  State<AdminWastePointsTab> createState() => _AdminWastePointsTabState();
}

class _AdminWastePointsTabState extends State<AdminWastePointsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'all';
  String _selectedWasteTypeFilter = 'Tất cả';

  static const List<String> availableWasteTypes = [
    'Rác tái chế',
    'Rác hữu cơ',
    'Rác vô cơ',
    'Rác nguy hại',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        final query = _searchController.text.trim().toLowerCase();
        final filtered =
            state.wastePoints.where((point) {
              final matchSearch =
                  query.isEmpty ||
                  point.name.toLowerCase().contains(query) ||
                  (point.address?.toLowerCase().contains(query) ?? false);

              final matchStatus =
                  _selectedStatusFilter == 'all' ||
                  point.status.name == _selectedStatusFilter;

              final matchType =
                  _selectedWasteTypeFilter == 'Tất cả' ||
                  point.wasteTypes.any(
                    (t) => t.toLowerCase().contains(
                      _selectedWasteTypeFilter.toLowerCase(),
                    ),
                  );

              return matchSearch && matchStatus && matchType;
            }).toList();

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFFF5F7FA),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddEditWastePointSheet(context),
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_location_alt_rounded),
            label: const Text(
              'Thêm trạm mới',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Tìm tên trạm hoặc địa chỉ...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF64748B),
                        ),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                                : null,
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatusChip('Tất cả', 'all'),
                          const SizedBox(width: 8),
                          _buildStatusChip('Đang hoạt động', 'active'),
                          const SizedBox(width: 8),
                          _buildStatusChip('Thùng đầy', 'full'),
                          const SizedBox(width: 8),
                          _buildStatusChip('Tạm ngưng', 'inactive'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final type in ['Tất cả', ...availableWasteTypes])
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                showCheckmark: false,
                                label: Text(
                                  type,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        _selectedWasteTypeFilter == type
                                            ? Colors.white
                                            : const Color(0xFF475569),
                                  ),
                                ),
                                selected: _selectedWasteTypeFilter == type,
                                selectedColor: const Color(0xFF2E7D32),
                                backgroundColor: const Color(0xFFF1F5F9),
                                side: BorderSide.none,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedWasteTypeFilter = type;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    filtered.isEmpty
                        ? const Center(
                          child: Text(
                            'Không tìm thấy điểm thu gom phù hợp.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _buildWastePointCard(
                              context,
                              filtered[index],
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String label, String value) {
    final isSelected = _selectedStatusFilter == value;
    return ChoiceChip(
      showCheckmark: false,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF475569),
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF1E293B),
      backgroundColor: const Color(0xFFF1F5F9),
      side: BorderSide.none,
      onSelected: (_) {
        setState(() {
          _selectedStatusFilter = value;
        });
      },
    );
  }

  Widget _buildWastePointCard(BuildContext context, WastePointEntity point) {
    Color statusColor;
    Color statusBg;
    switch (point.status) {
      case WastePointStatus.active:
        statusColor = const Color(0xFF16A34A);
        statusBg = const Color(0xFFF0FDF4);
        break;
      case WastePointStatus.full:
        statusColor = const Color(0xFFDC2626);
        statusBg = const Color(0xFFFEF2F2);
        break;
      case WastePointStatus.inactive:
        statusColor = const Color(0xFF64748B);
        statusBg = const Color(0xFFF1F5F9);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      point.address?.isNotEmpty == true
                          ? point.address!
                          : 'Chưa cập nhật địa chỉ chi tiết',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tọa độ: ${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Chỉnh sửa',
                onPressed:
                    () => _showAddEditWastePointSheet(context, point: point),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF475569),
                  size: 20,
                ),
              ),
              IconButton(
                tooltip: 'Xóa trạm',
                onPressed: () => _confirmDeletePoint(context, point),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                point.wasteTypes
                    .map(
                      (t) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const Divider(height: 20, color: Color(0xFFE2E8F0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trạng thái:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Wrap(
                spacing: 6,
                children: [
                  _buildQuickStatusBtn(
                    context: context,
                    point: point,
                    target: WastePointStatus.active,
                    label: 'Hoạt động',
                    activeColor: const Color(0xFF16A34A),
                  ),
                  _buildQuickStatusBtn(
                    context: context,
                    point: point,
                    target: WastePointStatus.full,
                    label: 'Đầy',
                    activeColor: const Color(0xFFDC2626),
                  ),
                  _buildQuickStatusBtn(
                    context: context,
                    point: point,
                    target: WastePointStatus.inactive,
                    label: 'Tạm ngưng',
                    activeColor: const Color(0xFF475569),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatusBtn({
    required BuildContext context,
    required WastePointEntity point,
    required WastePointStatus target,
    required String label,
    required Color activeColor,
  }) {
    final isCurrent = point.status == target;
    return InkWell(
      onTap:
          isCurrent
              ? null
              : () => context.read<AdminCubit>().changeWastePointStatus(
                point.id,
                target,
              ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isCurrent ? activeColor : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrent ? activeColor : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isCurrent ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  void _confirmDeletePoint(BuildContext context, WastePointEntity point) {
    final adminCubit = context.read<AdminCubit>();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              'Xóa điểm thu gom?',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Bạn có chắc chắn muốn xóa trạm "${point.name}" khỏi hệ thống bản đồ không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  adminCubit.deleteWastePoint(point.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Xóa vĩnh viễn'),
              ),
            ],
          ),
    );
  }

  void _showAddEditWastePointSheet(
    BuildContext context, {
    WastePointEntity? point,
  }) {
    final adminCubit = context.read<AdminCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _WastePointFormSheet(point: point, adminCubit: adminCubit),
    );
  }
}

/// Tách riêng thành StatefulWidget độc lập và bọc FlutterMap trong RepaintBoundary
/// giúp bàn phím trượt lên mượt mà 60fps, không bị lag hay rebuild lại Map mỗi frame.
class _WastePointFormSheet extends StatefulWidget {
  final WastePointEntity? point;
  final AdminCubit adminCubit;

  const _WastePointFormSheet({required this.point, required this.adminCubit});

  @override
  State<_WastePointFormSheet> createState() => _WastePointFormSheetState();
}

class _WastePointFormSheetState extends State<_WastePointFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late List<String> _selectedTypes;
  late WastePointStatus _selectedStatus;
  late LatLng _pinnedLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    final p = widget.point;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _addressCtrl = TextEditingController(text: p?.address ?? '');
    final initLat = p?.latitude ?? 10.7769;
    final initLng = p?.longitude ?? 106.7009;
    _latCtrl = TextEditingController(text: initLat.toStringAsFixed(6));
    _lngCtrl = TextEditingController(text: initLng.toStringAsFixed(6));
    _selectedTypes = List<String>.from(p?.wasteTypes ?? ['Rác tái chế']);
    _selectedStatus = p?.status ?? WastePointStatus.active;
    _pinnedLocation = LatLng(initLat, initLng);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              widget.point == null
                  ? 'Thêm Điểm Thu Gom Mới'
                  : 'Chỉnh Sửa Điểm Thu Gom',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Tên điểm thu gom *',
                    hintText: 'VD: Trạm thu gom rác tái chế Quận 1',
                    prefixIcon: const Icon(Icons.storefront_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _addressCtrl,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ chi tiết *',
                    hintText: 'Số nhà, tên đường, phường/xã...',
                    prefixIcon: const Icon(Icons.place_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Loại rác tiếp nhận (chọn nhiều):',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _AdminWastePointsTabState.availableWasteTypes.map((type) {
                        final isSelected = _selectedTypes.contains(type);
                        return FilterChip(
                          label: Text(
                            type,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : const Color(0xFF334155),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF2E7D32),
                          checkmarkColor: Colors.white,
                          backgroundColor: const Color(0xFFF1F5F9),
                          side: BorderSide.none,
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedTypes.add(type);
                              } else if (_selectedTypes.length > 1) {
                                _selectedTypes.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Trạng thái hoạt động:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                // Dùng Wrap thay vì Row để không bao giờ bị tràn lề phải (overflow)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      WastePointStatus.values.map((st) {
                        final isSelected = _selectedStatus == st;
                        String label =
                            st == WastePointStatus.active
                                ? 'Đang hoạt động'
                                : st == WastePointStatus.full
                                ? 'Thùng đầy'
                                : 'Tạm ngưng';
                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          selectedColor: const Color(0xFF1E293B),
                          backgroundColor: const Color(0xFFF1F5F9),
                          side: BorderSide.none,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            color:
                                isSelected
                                    ? Colors.white
                                    : const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedStatus = st;
                            });
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chạm vào bản đồ để ghim tọa độ trạm:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                RepaintBoundary(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 190,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _pinnedLocation,
                          initialZoom: 15.0,
                          onTap: (tapPosition, latlng) {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _pinnedLocation = latlng;
                              _latCtrl.text = latlng.latitude.toStringAsFixed(
                                6,
                              );
                              _lngCtrl.text = latlng.longitude.toStringAsFixed(
                                6,
                              );
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.smartwaste.waste_classification_app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _pinnedLocation,
                                width: 44,
                                height: 44,
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFFDC2626),
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        onSubmitted: (v) {
                          final parsed = double.tryParse(v);
                          if (parsed != null) {
                            setState(() {
                              _pinnedLocation = LatLng(
                                parsed,
                                _pinnedLocation.longitude,
                              );
                            });
                            _mapController.move(_pinnedLocation, 15);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Vĩ độ (Latitude)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _lngCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        onSubmitted: (v) {
                          final parsed = double.tryParse(v);
                          if (parsed != null) {
                            setState(() {
                              _pinnedLocation = LatLng(
                                _pinnedLocation.latitude,
                                parsed,
                              );
                            });
                            _mapController.move(_pinnedLocation, 15);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Kinh độ (Longitude)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded),
                  label: Text(
                    widget.point == null
                        ? 'Tạo Điểm Thu Gom'
                        : 'Lưu Thay Đổi',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên điểm thu gom!')),
      );
      return;
    }
    final lat =
        double.tryParse(_latCtrl.text.trim()) ?? _pinnedLocation.latitude;
    final lng =
        double.tryParse(_lngCtrl.text.trim()) ?? _pinnedLocation.longitude;

    Navigator.pop(context);
    widget.adminCubit.saveWastePoint(
      id: widget.point?.id,
      name: _nameCtrl.text,
      address: _addressCtrl.text,
      latitude: lat,
      longitude: lng,
      wasteTypes: _selectedTypes,
      status: _selectedStatus,
    );
  }
}
