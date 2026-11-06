import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/level_calculator.dart';
import '../../../auth/domain/entities/user.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import 'admin_qr_scanner_modal.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'greenPoints'; // 'greenPoints' | 'totalScanned' | 'totalXP'

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
        final filteredUsers =
            state.users.where((u) {
              if (query.isEmpty) return true;
              return u.fullName.toLowerCase().contains(query) ||
                  u.email.toLowerCase().contains(query) ||
                  u.id.toLowerCase().contains(query);
            }).toList();

        filteredUsers.sort((a, b) {
          if (_sortBy == 'totalScanned') {
            return b.totalScanned.compareTo(a.totalScanned);
          } else if (_sortBy == 'totalXP') {
            return b.totalXP.compareTo(a.totalXP);
          }
          return b.greenPoints.compareTo(a.greenPoints);
        });

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFFF5F7FA),
          floatingActionButton: FloatingActionButton.extended(
            onPressed:
                () => AdminQrScannerModal.show(
                  context,
                  adminCubit: context.read<AdminCubit>(),
                  users: state.users,
                ),
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text(
              'Quét QR Cộng Điểm',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              // Thanh tìm kiếm và sắp xếp (Đã bọc SingleChildScrollView chống tràn màn hình)
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tên, email hoặc UID...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.person_search_rounded,
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
                                : IconButton(
                                  tooltip: 'Mở camera quét mã QR cư dân',
                                  icon: const Icon(
                                    Icons.qr_code_scanner_rounded,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  onPressed:
                                      () => AdminQrScannerModal.show(
                                        context,
                                        adminCubit: context.read<AdminCubit>(),
                                        users: state.users,
                                      ),
                                ),
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
                          const Text(
                            'Sắp xếp theo:',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildSortChip('Điểm Xanh (GP)', 'greenPoints'),
                          const SizedBox(width: 8),
                          _buildSortChip('Lượt phân loại', 'totalScanned'),
                          const SizedBox(width: 8),
                          _buildSortChip('Kinh nghiệm (XP)', 'totalXP'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child:
                    filteredUsers.isEmpty
                        ? const Center(
                          child: Text(
                            'Không tìm thấy người dùng phù hợp.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return _buildUserCard(context, user);
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
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
      onSelected: (_) => setState(() => _sortBy = value),
    );
  }

  Widget _buildUserCard(BuildContext context, User user) {
    final displayName =
        user.fullName.isNotEmpty
            ? user.fullName
            : (user.email.isNotEmpty ? user.email : 'Cư dân SmartWaste');
    final level = LevelCalculator.getLevel(user.totalXP);
    final rankBadge = LevelCalculator.getRankBadge(user.totalXP);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFFF1F5F9),
                    backgroundImage:
                        (user.avatar != null && user.avatar!.isNotEmpty)
                            ? CachedNetworkImageProvider(user.avatar!)
                            : null,
                    child:
                        (user.avatar == null || user.avatar!.isEmpty)
                            ? Text(
                              displayName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            )
                            : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Lv.$level',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (user.email.isNotEmpty)
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    const SizedBox(height: 3),
                    Text(
                      rankBadge,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: () => _showAdjustUserPointsDialog(context, user),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.tune_rounded, size: 15),
                label: const Text(
                  'Cộng/Trừ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUserMetric(
                  label: 'GreenPoints',
                  value: '${user.greenPoints} GP',
                  color: const Color(0xFF16A34A),
                ),
                _buildUserMetric(
                  label: 'Tổng XP',
                  value: '${user.totalXP} XP',
                  color: const Color(0xFF2563EB),
                ),
                _buildUserMetric(
                  label: 'Đã phân loại',
                  value: '${user.totalScanned} lần',
                  color: const Color(0xFFEA580C),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  void _showAdjustUserPointsDialog(BuildContext context, User user) {
    final adminCubit = context.read<AdminCubit>();
    showDialog(
      context: context,
      builder: (_) => _AdjustUserPointsDialog(user: user, adminCubit: adminCubit),
    );
  }
}

class _AdjustUserPointsDialog extends StatefulWidget {
  final User user;
  final AdminCubit adminCubit;

  const _AdjustUserPointsDialog({
    required this.user,
    required this.adminCubit,
  });

  @override
  State<_AdjustUserPointsDialog> createState() =>
      _AdjustUserPointsDialogState();
}

class _AdjustUserPointsDialogState extends State<_AdjustUserPointsDialog> {
  final TextEditingController _gpCtrl = TextEditingController(text: '50');
  final TextEditingController _xpCtrl = TextEditingController(text: '100');
  final TextEditingController _reasonCtrl = TextEditingController(
    text: 'Thưởng nộp rác tái chế tại trạm thu gom',
  );
  bool _isAddition = true;
  bool _incrementScan = false;

  @override
  void dispose() {
    _gpCtrl.dispose();
    _xpCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name =
        widget.user.fullName.isNotEmpty
            ? widget.user.fullName
            : widget.user.email;
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'Điều Chỉnh Điểm: $name',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    showCheckmark: false,
                    label: const Text('Cộng điểm (+)'),
                    selected: _isAddition,
                    selectedColor: const Color(0xFF16A34A),
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                      color:
                          _isAddition ? Colors.white : const Color(0xFF334155),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                    onSelected: (_) => setState(() => _isAddition = true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    showCheckmark: false,
                    label: const Text('Trừ điểm (-)'),
                    selected: !_isAddition,
                    selectedColor: const Color(0xFFDC2626),
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                      color:
                          !_isAddition ? Colors.white : const Color(0xFF334155),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                    onSelected: (_) => setState(() => _isAddition = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _gpCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số GreenPoints (GP)',
                prefixIcon: const Icon(Icons.eco_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _xpCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số điểm kinh nghiệm (XP)',
                prefixIcon: const Icon(Icons.bolt_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Nội dung thông báo gửi User',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_isAddition)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _incrementScan,
                activeColor: const Color(0xFF2E7D32),
                title: const Text(
                  'Cộng +1 lượt phân loại rác (totalScanned)',
                  style: TextStyle(fontSize: 12.5),
                ),
                onChanged: (v) => setState(() => _incrementScan = v ?? false),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            final rawGp = (int.tryParse(_gpCtrl.text.trim()) ?? 0).abs();
            final rawXp = (int.tryParse(_xpCtrl.text.trim()) ?? 0).abs();
            final gpDelta = _isAddition ? rawGp : -rawGp;
            final xpDelta = _isAddition ? rawXp : -rawXp;

            Navigator.pop(context);
            widget.adminCubit.adjustUserPointsAndXp(
              userIdOrQr: widget.user.id,
              greenPointsDelta: gpDelta,
              xpDelta: xpDelta,
              reason: _reasonCtrl.text,
              notificationType: _incrementScan ? 'scan' : 'reward',
              incrementScanCount: _isAddition && _incrementScan,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isAddition
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFDC2626),
            foregroundColor: Colors.white,
          ),
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}
