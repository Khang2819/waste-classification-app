import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../reward/domain/entities/reward_entity.dart';
import '../../domain/entities/redeem_history_entity.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminRewardsTab extends StatefulWidget {
  const AdminRewardsTab({super.key});

  @override
  State<AdminRewardsTab> createState() => _AdminRewardsTabState();
}

class _AdminRewardsTabState extends State<AdminRewardsTab> {
  bool _showRedeemHistory = false;
  String _selectedCategory = 'Tất cả';

  static const List<String> rewardCategories = [
    'Voucher F&B',
    'Quà tặng Xanh',
    'Thẻ cào',
    'Trồng Cây',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        final filteredRewards =
            _selectedCategory == 'Tất cả'
                ? state.rewards
                : state.rewards
                    .where((r) => r.name == _selectedCategory)
                    .toList();

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFFF5F7FA),
          floatingActionButton:
              _showRedeemHistory
                  ? null
                  : FloatingActionButton.extended(
                    onPressed: () => _showAddEditRewardSheet(context),
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.add_card_rounded),
                    label: const Text(
                      'Thêm quà mới',
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildModeButton(
                            title: 'Kho Quà (${state.rewards.length})',
                            icon: Icons.card_giftcard_rounded,
                            selected: !_showRedeemHistory,
                            onTap:
                                () =>
                                    setState(() => _showRedeemHistory = false),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildModeButton(
                            title:
                                'Lịch Sử Đổi (${state.redeemHistories.length})',
                            icon: Icons.receipt_long_rounded,
                            selected: _showRedeemHistory,
                            onTap:
                                () => setState(() => _showRedeemHistory = true),
                          ),
                        ),
                      ],
                    ),
                    if (!_showRedeemHistory) ...[
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final cat in ['Tất cả', ...rewardCategories])
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  showCheckmark: false,
                                  label: Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          _selectedCategory == cat
                                              ? Colors.white
                                              : const Color(0xFF475569),
                                    ),
                                  ),
                                  selected: _selectedCategory == cat,
                                  selectedColor: const Color(0xFF2E7D32),
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  side: BorderSide.none,
                                  onSelected: (_) {
                                    setState(() => _selectedCategory = cat);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child:
                    _showRedeemHistory
                        ? _buildRedeemHistoryList(context, state)
                        : _buildRewardsList(context, filteredRewards),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeButton({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsList(BuildContext context, List<RewardEntity> rewards) {
    if (rewards.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có phần thưởng nào trong danh mục này.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        final isLowStock = reward.stock <= 5;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        (reward.imageUrl != null && reward.imageUrl!.isNotEmpty)
                            ? CachedNetworkImage(
                              imageUrl: reward.imageUrl!,
                              width: 74,
                              height: 74,
                              fit: BoxFit.cover,
                              placeholder:
                                  (_, __) => Container(
                                    width: 74,
                                    height: 74,
                                    color: const Color(0xFFF1F5F9),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (_, __, ___) => _buildFallbackRewardImage(),
                            )
                            : _buildFallbackRewardImage(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            reward.name,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reward.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          reward.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${reward.points} GreenPoints',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        tooltip: 'Sửa quà',
                        onPressed:
                            () =>
                                _showAddEditRewardSheet(context, reward: reward),
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF475569),
                          size: 20,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Xóa quà',
                        onPressed: () => _confirmDeleteReward(context, reward),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFEF4444),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 18, color: Color(0xFFE2E8F0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color:
                            isLowStock
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Tồn kho: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '${reward.stock}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              isLowStock
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildStockRoundBtn(
                        icon: Icons.remove_rounded,
                        onTap:
                            reward.stock > 0
                                ? () => context
                                    .read<AdminCubit>()
                                    .updateRewardStock(
                                      reward.id,
                                      reward.stock - 1,
                                    )
                                : null,
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showEditStockDialog(context, reward),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Nhập số',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStockRoundBtn(
                        icon: Icons.add_rounded,
                        onTap:
                            () => context.read<AdminCubit>().updateRewardStock(
                              reward.id,
                              reward.stock + 1,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFallbackRewardImage() {
    return Container(
      width: 74,
      height: 74,
      color: const Color(0xFFF1F5F9),
      child: const Icon(
        Icons.card_giftcard_rounded,
        color: Color(0xFF64748B),
        size: 30,
      ),
    );
  }

  Widget _buildStockRoundBtn({required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color:
              onTap != null
                  ? const Color(0xFFF1F5F9)
                  : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color:
              onTap != null
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }

  Widget _buildRedeemHistoryList(BuildContext context, AdminState state) {
    final histories = state.redeemHistories;
    if (histories.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có giao dịch đổi quà nào trên hệ thống.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    final userMap = {for (final u in state.users) u.id: u};
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: histories.length,
      itemBuilder: (context, index) {
        final item = histories[index];
        final user = userMap[item.userId];
        final userName =
            (user?.fullName.isNotEmpty == true)
                ? user!.fullName
                : (user?.email.isNotEmpty == true ? user!.email : item.userId);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Text(
                    '-${item.pointsSpent} GP',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Người đổi: $userName',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Danh mục: ${item.name} • ${item.redeemedAt != null ? dateFmt.format(item.redeemedAt!) : "Vừa xong"}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const Divider(height: 18, color: Color(0xFFE2E8F0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Trạng thái Voucher:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  Wrap(
                    spacing: 6,
                    children: [
                      _buildHistoryStatusChip(
                        context,
                        item,
                        'pending',
                        'Chờ duyệt',
                        const Color(0xFFD97706),
                      ),
                      _buildHistoryStatusChip(
                        context,
                        item,
                        'success',
                        'Hợp lệ',
                        const Color(0xFF16A34A),
                      ),
                      _buildHistoryStatusChip(
                        context,
                        item,
                        'used',
                        'Đã dùng',
                        const Color(0xFF475569),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryStatusChip(
    BuildContext context,
    RedeemHistoryEntity item,
    String statusValue,
    String label,
    Color activeColor,
  ) {
    final isSelected = item.status == statusValue;
    return InkWell(
      onTap:
          isSelected || item.userId.isEmpty
              ? null
              : () {
                context.read<AdminCubit>().updateRedeemHistoryStatus(
                  userId: item.userId,
                  historyId: item.id,
                  status: statusValue,
                );
              },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  void _showEditStockDialog(BuildContext context, RewardEntity reward) {
    final adminCubit = context.read<AdminCubit>();
    final ctrl = TextEditingController(text: '${reward.stock}');
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              'Cập nhật kho: ${reward.title}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            content: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số lượng tồn kho mới',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newStock = int.tryParse(ctrl.text.trim());
                  if (newStock != null && newStock >= 0) {
                    Navigator.pop(ctx);
                    adminCubit.updateRewardStock(reward.id, newStock);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Lưu'),
              ),
            ],
          ),
    );
  }

  void _confirmDeleteReward(BuildContext context, RewardEntity reward) {
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
              'Xóa phần thưởng?',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Bạn có chắc chắn muốn xóa quà tặng "${reward.title}" khỏi kho đổi thưởng không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  adminCubit.deleteReward(reward.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  void _showAddEditRewardSheet(BuildContext context, {RewardEntity? reward}) {
    final adminCubit = context.read<AdminCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RewardFormSheet(reward: reward, adminCubit: adminCubit),
    );
  }
}

class _RewardFormSheet extends StatefulWidget {
  final RewardEntity? reward;
  final AdminCubit adminCubit;

  const _RewardFormSheet({required this.reward, required this.adminCubit});

  @override
  State<_RewardFormSheet> createState() => _RewardFormSheetState();
}

class _RewardFormSheetState extends State<_RewardFormSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _pointsCtrl;
  late final TextEditingController _stockCtrl;
  late String _selectedCategory;
  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final r = widget.reward;
    _titleCtrl = TextEditingController(text: r?.title ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _pointsCtrl = TextEditingController(text: r != null ? '${r.points}' : '200');
    _stockCtrl = TextEditingController(text: r != null ? '${r.stock}' : '20');
    _selectedCategory =
        (r != null && _AdminRewardsTabState.rewardCategories.contains(r.name))
            ? r.name
            : _AdminRewardsTabState.rewardCategories.first;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _pointsCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.88,
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
              widget.reward == null
                  ? 'Thêm Phần Thưởng Mới'
                  : 'Chỉnh Sửa Phần Thưởng',
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
                Center(
                  child: InkWell(
                    onTap: () async {
                      final xfile = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      if (xfile != null && mounted) {
                        setState(() {
                          _pickedImageFile = File(xfile.path);
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child:
                            _pickedImageFile != null
                                ? Image.file(
                                  _pickedImageFile!,
                                  fit: BoxFit.cover,
                                )
                                : (widget.reward?.imageUrl?.isNotEmpty == true)
                                ? CachedNetworkImage(
                                  imageUrl: widget.reward!.imageUrl!,
                                  fit: BoxFit.cover,
                                )
                                : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 34,
                                      color: Color(0xFF475569),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Chọn ảnh quà tặng',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Danh mục phần thưởng:',
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
                      _AdminRewardsTabState.rewardCategories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          showCheckmark: false,
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: const Color(0xFF1E293B),
                          backgroundColor: const Color(0xFFF1F5F9),
                          side: BorderSide.none,
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            color:
                                isSelected
                                    ? Colors.white
                                    : const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedCategory = cat);
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _titleCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Tên quà tặng / Voucher *',
                    hintText: 'VD: Voucher Highlands 50.000đ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Mô tả chi tiết & điều kiện áp dụng',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pointsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Điểm đổi (GP) *',
                          prefixIcon: const Icon(Icons.eco_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Số lượng kho *',
                          prefixIcon: const Icon(Icons.inventory_2_outlined),
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
                  onPressed: _submitReward,
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
                    widget.reward == null
                        ? 'Lưu Phần Thưởng'
                        : 'Cập Nhật Phần Thưởng',
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

  void _submitReward() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên phần thưởng!')),
      );
      return;
    }
    final pts = int.tryParse(_pointsCtrl.text.trim()) ?? 100;
    final stk = int.tryParse(_stockCtrl.text.trim()) ?? 10;

    Navigator.pop(context);
    widget.adminCubit.saveReward(
      id: widget.reward?.id,
      title: _titleCtrl.text,
      categoryName: _selectedCategory,
      points: pts,
      description: _descCtrl.text,
      stock: stk,
      existingImageUrl: widget.reward?.imageUrl,
      newImageFile: _pickedImageFile,
    );
  }
}
