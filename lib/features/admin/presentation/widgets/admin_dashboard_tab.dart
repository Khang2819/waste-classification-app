import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../map/domain/entities/waste_point_entity.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminDashboardTab extends StatelessWidget {
  final ValueChanged<int> onSwitchTab;

  const AdminDashboardTab({super.key, required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        return RefreshIndicator(
          color: const Color(0xFF2E7D32),
          onRefresh:
              () => context.read<AdminCubit>().loadAllData(showLoading: false),
          child: ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Lưới KPI Cards hiện đại, màu sắc trung tính & hài hòa
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.28,
                children: [
                  _buildKpiCard(
                    icon: Icons.people_alt_rounded,
                    iconColor: const Color(0xFF2563EB),
                    bgColor: const Color(0xFFEFF6FF),
                    title: 'Tổng Người Dùng',
                    value: '${state.totalUsers}',
                    subtitle: 'Tài khoản hệ thống',
                    onTap: () => onSwitchTab(3),
                  ),
                  _buildKpiCard(
                    icon: Icons.qr_code_scanner_rounded,
                    iconColor: const Color(0xFF0D9488),
                    bgColor: const Color(0xFFF0FDFA),
                    title: 'Lượt Phân Loại',
                    value: '${state.totalScanned}',
                    subtitle:
                        '~${state.totalRecycledKg.toStringAsFixed(1)} kg rác tái chế',
                    onTap: () => onSwitchTab(3),
                  ),
                  _buildKpiCard(
                    icon: Icons.location_on_rounded,
                    iconColor: const Color(0xFFEA580C),
                    bgColor: const Color(0xFFFFF7ED),
                    title: 'Điểm Thu Gom',
                    value: '${state.wastePoints.length}',
                    subtitle:
                        '${state.activePointsCount} mở • ${state.fullPointsCount} đầy • ${state.inactivePointsCount} ngưng',
                    onTap: () => onSwitchTab(1),
                  ),
                  _buildKpiCard(
                    icon: Icons.card_giftcard_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF5F3FF),
                    title: 'Kho Quà Tặng',
                    value: '${state.rewards.length}',
                    subtitle:
                        state.lowStockRewards.isNotEmpty
                            ? '⚠️ ${state.lowStockRewards.length} món sắp hết'
                            : 'Tồn kho ổn định',
                    onTap: () => onSwitchTab(2),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Khu vực Cảnh báo Thùng rác Đầy (Quick Action)
              _buildFullBinsSection(context, state),
              const SizedBox(height: 16),

              // Khu vực Cảnh báo Quà tặng sắp hết kho (stock <= 5)
              _buildLowStockRewardsSection(context, state),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String value,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullBinsSection(BuildContext context, AdminState state) {
    final fullBins = state.fullWastePoints;

    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thùng Rác Đang Đầy Cần Thu Gom',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      fullBins.isEmpty
                          ? 'Tất cả các trạm đều đang thông thoáng'
                          : 'Có ${fullBins.length} trạm đang báo đầy',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (fullBins.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFF16A34A),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Không có điểm thu gom nào bị quá tải',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            ...fullBins.map(
              (point) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            point.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            point.address?.isNotEmpty == true
                                ? point.address!
                                : 'Tọa độ: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AdminCubit>().changeWastePointStatus(
                          point.id,
                          WastePointStatus.active,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        Icons.cleaning_services_rounded,
                        size: 15,
                      ),
                      label: const Text(
                        'Làm trống',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLowStockRewardsSection(BuildContext context, AdminState state) {
    final lowRewards = state.lowStockRewards;

    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cảnh Báo Tồn Kho Quà Tặng (≤ 5)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      lowRewards.isEmpty
                          ? 'Mọi phần thưởng đều còn đủ số lượng'
                          : 'Có ${lowRewards.length} món quà sắp hết hàng',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (lowRewards.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_outlined,
                    color: Color(0xFF16A34A),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Kho quà tặng đang ổn định',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            ...lowRewards.map(
              (reward) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reward.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${reward.name} • ${reward.points} GP',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            reward.stock == 0
                                ? const Color(0xFFFEE2E2)
                                : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reward.stock == 0 ? 'Hết hàng' : 'Còn ${reward.stock}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              reward.stock == 0
                                  ? const Color(0xFFB91C1C)
                                  : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    TextButton.icon(
                      onPressed: () {
                        context.read<AdminCubit>().updateRewardStock(
                          reward.id,
                          reward.stock + 10,
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 16),
                      label: const Text(
                        '+10',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
