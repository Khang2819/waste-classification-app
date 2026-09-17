import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../history/presentation/cubit/history_cubit.dart';
import '../../main/cubit/main_cubit.dart';
import '../../profile/presentation/cubit/profile_cubit.dart';
import '../../profile/presentation/cubit/profile_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<HistoryCubit>().listenHistory(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final user = state is ProfileLoaded ? state.user : null;
            final displayname =
                (user?.fullName.isNotEmpty == true)
                    ? user!.fullName
                    : ((user?.email.isNotEmpty == true)
                        ? user!.email.split('@').first
                        : 'Bạn');

            final avatar =
                user?.avatar?.isNotEmpty == true ? user?.avatar! : null;

            final totalScanned = user?.totalScanned ?? 0;
            final recycledKg = (totalScanned * 0.5).toStringAsFixed(1);
            final co2Reduced = (totalScanned * 0.3).toStringAsFixed(1);

            final points = user?.greenPoints ?? 0;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF2E7D32),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundImage:
                              avatar != null ? NetworkImage(avatar) : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xin chào, $displayname',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Cùng chung tay bảo vệ môi trường!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                color: Color(0xFF1B5E20),
                                size: 24,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 8),
                          blurRadius: 10,
                          color: Colors.black.withValues(alpha: 0.04),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ĐIỂM THƯỞNG XANH",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      _formatNumber(points),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Icons.eco_rounded,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                context.go('/redeem');
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9800),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.card_giftcard_rounded,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Đổi quà",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.qr_code_scanner_rounded,
                                      color: const Color(0xFFC8E6C9),
                                      size: 22,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "$totalScanned",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      "Lượt quét rác",
                                      style: TextStyle(
                                        color: Color(0xFFE8F5E9),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 35,
                                color: Colors.white24,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.scale_rounded,
                                      color: const Color(0xFFC8E6C9),
                                      size: 22,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "$recycledKg kg",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Rác tái chế",
                                      style: const TextStyle(
                                        color: Color(0xFFE8F5E9),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 35,
                                color: Colors.white24,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.eco_rounded,
                                      color: const Color(0xFFC8E6C9),
                                      size: 22,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "$co2Reduced kg",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Giảm CO₂",
                                      style: const TextStyle(
                                        color: Color(0xFFE8F5E9),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Dịch vụ xanh",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildActionCard(
                        title: 'Quét rác AI',
                        subtitle: 'Phân loại tự động',
                        icon: Icons.center_focus_strong_rounded,
                        color: const Color(0xFF2E7D32),
                        bg: const Color(0xFFE8F5E9),
                        onTap: () {
                          context.read<MainCubit>().chage(2);
                        },
                      ),
                      _buildActionCard(
                        title: 'Lịch thu gom',
                        subtitle: 'Xem giờ xe rác',
                        icon: Icons.calendar_month_rounded,
                        color: const Color(0xFF0288D1),
                        bg: const Color(0xFFE1F5FE),
                        onTap: () {},
                      ),
                      _buildActionCard(
                        title: 'Bản đồ trạm',
                        subtitle: 'Điểm tái chế',
                        icon: Icons.map_rounded,
                        color: const Color(0xFFED6C02),
                        bg: const Color(0xFFFFF3E0),
                        onTap: () {
                          context.read<MainCubit>().chage(1);
                        },
                      ),
                      _buildActionCard(
                        title: 'Đổi quà xanh',
                        subtitle: 'Voucher & Cây',
                        icon: Icons.card_giftcard_rounded,
                        color: const Color(0xFF9C27B0),
                        bg: const Color(0xFFF3E5F5),
                        onTap: () {
                          context.go('/redeem');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFFE8F5E9),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_rounded,
                          color: Color(0xFF2E7D32),
                          size: 32,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mẹo vặt sống xanh",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Rửa sạch chai nhựa trước khi cho vào thùng rác tái chế giúp quá trình xử lý nhanh hơn 40%.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade800,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Hoạt động gần đây",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<MainCubit>().chage(3);
                        },
                        child: const Text(
                          "Xem tất cả",
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<HistoryCubit, HistoryState>(
                    builder: (context, state) {
                      if (state is HistoryLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        );
                      }
                      final items =
                          state is HistoryLoaded
                              ? state.history.take(5).toList()
                              : [];

                      if (items.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              "Chưa có hoạt động nào gần đây",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: items.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = items[index];

                          final bool isLocalImage =
                              item.imagePath.isNotEmpty &&
                              File(item.imagePath).existsSync();
                          final bool isNetworkImage =
                              item.imagePath.startsWith('http://') ||
                              item.imagePath.startsWith('https://');
                          final bool hasImage = isLocalImage || isNetworkImage;

                          final createdAt = item.createdAt;
                          final hour = createdAt.hour.toString().padLeft(
                            2,
                            '0',
                          );
                          final minute = createdAt.minute.toString().padLeft(
                            2,
                            '0',
                          );
                          final day = createdAt.day.toString().padLeft(2, '0');
                          final month = createdAt.month.toString().padLeft(
                            2,
                            '0',
                          );
                          final year = createdAt.year;
                          final formattedTime =
                              '$hour:$minute - $day/$month/$year';

                          // 3. Phân biệt trạng thái cộng (+) hoặc trừ (-) điểm
                          final bool isPositive = item.pointsEarned >= 0;
                          final Color pointsColor =
                              isPositive
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFD32F2F);
                          final String pointsText =
                              '${isPositive ? '+' : ''}${item.pointsEarned} điểm';

                          return Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 54,
                                    height: 54,
                                    child:
                                        hasImage
                                            ? (isLocalImage
                                                ? Image.file(
                                                  File(item.imagePath),
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (_, __, ___) =>
                                                          _buildFallbackHistoryIcon(),
                                                )
                                                : Image.network(
                                                  item.imagePath,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (_, __, ___) =>
                                                          _buildFallbackHistoryIcon(),
                                                ))
                                            : _buildFallbackHistoryIcon(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Thông tin nhãn, danh mục và ngày giờ
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.label,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B5E20),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        item.category.isNotEmpty
                                            ? item.category
                                            : 'Rác tái chế',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 13,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            formattedTime,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: pointsColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    pointsText,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: pointsColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 10,
                color: Colors.black.withValues(alpha: 0.04),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 25),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackHistoryIcon() {
    return Container(
      color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
      child: const Center(
        child: Icon(
          Icons.recycling_rounded,
          color: Color(0xFF2E7D32),
          size: 24,
        ),
      ),
    );
  }
}
