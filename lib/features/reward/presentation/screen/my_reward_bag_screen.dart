import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../domain/entities/user_reward_item_entity.dart';
import '../../domain/repositories/reward_repository.dart';

class MyRewardBagScreen extends StatefulWidget {
  const MyRewardBagScreen({super.key});

  @override
  State<MyRewardBagScreen> createState() => _MyRewardBagScreenState();
}

class _MyRewardBagScreenState extends State<MyRewardBagScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final RewardRepository _rewardRepository = getIt<RewardRepository>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _resolveUserId(BuildContext context) {
    final profileState = context.watch<ProfileCubit>().state;
    if (profileState is ProfileLoaded && profileState.user.id.isNotEmpty) {
      return profileState.user.id;
    }
    final authState = context.watch<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.id;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final userId = _resolveUserId(context);

    return StreamBuilder<List<UserRewardItemEntity>>(
      stream: _rewardRepository.watchUserRedeemHistories(userId),
      builder: (context, snapshot) {
        final allItems = snapshot.data ?? const [];
        final availableItems = allItems.where((e) => !e.isUsed).toList();
        final usedItems = allItems.where((e) => e.isUsed).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F5),
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/redeem');
                }
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1E293B),
                size: 20,
              ),
            ),
            title: const Text(
              'Túi Quà Của Tôi',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF2E7D32),
                  unselectedLabelColor: const Color(0xFF64748B),
                  indicatorColor: const Color(0xFF2E7D32),
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                  tabs: [
                    Tab(
                      text: 'Chưa sử dụng (${availableItems.length})',
                    ),
                    Tab(
                      text: 'Đã sử dụng (${usedItems.length})',
                    ),
                  ],
                ),
              ),
            ),
          ),
          body:
              snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  )
                  : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVoucherList(
                        context,
                        items: availableItems,
                        userId: userId,
                        emptyTitle: 'Túi quà đang trống',
                        emptySubtitle:
                            'Hãy tích cực phân loại rác và dùng Điểm Xanh để đổi các voucher hấp dẫn nhé!',
                        showRedeemButton: true,
                      ),
                      _buildVoucherList(
                        context,
                        items: usedItems,
                        userId: userId,
                        emptyTitle: 'Chưa có voucher đã dùng',
                        emptySubtitle:
                            'Các voucher sau khi bạn quy đổi và sử dụng sẽ được lưu tại đây.',
                        showRedeemButton: false,
                      ),
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildVoucherList(
    BuildContext context, {
    required List<UserRewardItemEntity> items,
    required String userId,
    required String emptyTitle,
    required String emptySubtitle,
    required bool showRedeemButton,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  size: 48,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                emptyTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              if (showRedeemButton) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/redeem');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.card_giftcard_rounded, size: 18),
                  label: const Text(
                    'Khám phá Kho Quà Xanh',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isUsed = item.isUsed;

        return InkWell(
          onTap: () => _showVoucherDetailSheet(context, item, userId),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    isUsed
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFFC8E6C9),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child:
                            (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                                ? CachedNetworkImage(
                                  imageUrl: item.imageUrl!,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  errorWidget:
                                      (_, __, ___) =>
                                          _buildTicketIconBox(isUsed),
                                )
                                : _buildTicketIconBox(isUsed),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isUsed
                                            ? const Color(0xFFF1F5F9)
                                            : const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isUsed
                                              ? const Color(0xFF64748B)
                                              : const Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '-${item.pointsSpent} GP',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isUsed
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color:
                                    isUsed
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF1E293B),
                                decoration:
                                    isUsed ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Đổi lúc: ${item.redeemedAt != null ? dateFmt.format(item.redeemedAt!) : "Vừa xong"}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.qr_code_rounded,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Mã: ${item.voucherCode}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isUsed
                                  ? const Color(0xFFF1F5F9)
                                  : const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isUsed ? 'Đã sử dụng' : 'Dùng ngay',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color:
                                isUsed
                                    ? const Color(0xFF64748B)
                                    : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTicketIconBox(bool isUsed) {
    return Container(
      width: 72,
      height: 72,
      color: isUsed ? const Color(0xFFF1F5F9) : const Color(0xFFE8F5E9),
      child: Icon(
        Icons.card_giftcard_rounded,
        size: 34,
        color: isUsed ? const Color(0xFF94A3B8) : const Color(0xFF2E7D32),
      ),
    );
  }

  void _showVoucherDetailSheet(
    BuildContext context,
    UserRewardItemEntity item,
    String userId,
  ) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final qrData = 'SMARTWASTE_VOUCHER:${item.id}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (item.description != null &&
                    item.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.description!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Khung Mã QR Voucher
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 185,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color:
                              item.isUsed
                                  ? Colors.grey
                                  : const Color(0xFF1E293B),
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color:
                              item.isUsed
                                  ? Colors.grey
                                  : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: item.voucherCode),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đã sao chép mã ${item.voucherCode}',
                              ),
                              backgroundColor: const Color(0xFF2E7D32),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.voucherCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.copy_rounded,
                                size: 16,
                                color: Color(0xFF2E7D32),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Đổi ngày: ${item.redeemedAt != null ? dateFmt.format(item.redeemedAt!) : "Vừa xong"} • ${item.pointsSpent} Điểm Xanh',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),
                if (!item.isUsed && userId.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(sheetCtx);
                        await _rewardRepository.markVoucherAsUsed(
                          userId: userId,
                          historyId: item.id,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đã đánh dấu sử dụng "${item.title}"!',
                              ),
                              backgroundColor: const Color(0xFF2E7D32),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text(
                        'Đánh Dấu Đã Sử Dụng',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetCtx),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Đóng'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

