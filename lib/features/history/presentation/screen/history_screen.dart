import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waste_classification_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:waste_classification_app/features/history/domain/entities/scan_history_entity.dart';
import 'package:waste_classification_app/features/history/presentation/cubit/history_cubit.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedCategoryTab = 0;
  int _selectedTimeFilter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistoryIfAuthenticated();
    });
  }

  void _loadHistoryIfAuthenticated() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<HistoryCubit>().listenHistory(authState.user.id);
    }
  }

  List<ScanHistoryEntity> _filterHistory(List<ScanHistoryEntity> items) {
    final now = DateTime.now();
    var filtered =
        items.where((item) {
          if (_selectedTimeFilter == 1) {
            return item.createdAt.year == now.year &&
                item.createdAt.month == now.month &&
                item.createdAt.day == now.day;
          } else if (_selectedTimeFilter == 2) {
            // 7 ngày qua
            return now.difference(item.createdAt).inDays <= 7;
          } else if (_selectedTimeFilter == 3) {
            // 30 ngày qua
            return now.difference(item.createdAt).inDays <= 30;
          }
          return true;
        }).toList();

    // Lọc theo danh mục
    if (_selectedCategoryTab == 1) {
      // Quét AI
      filtered = filtered.toList();
    } else if (_selectedCategoryTab == 2) {
      // Giao nộp trạm / Tái chế
      filtered =
          filtered
              .where(
                (item) =>
                    item.category.toLowerCase().contains('tái chế') ||
                    item.category.toLowerCase().contains('trạm'),
              )
              .toList();
    } else if (_selectedCategoryTab == 3) {
      // Tích điểm cao
      filtered = filtered.where((item) => item.pointsEarned > 0).toList();
    }

    return filtered;
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$hour:$minute - $day/$month';
  }

  void _confirmDelete(BuildContext context, String userId, String historyId) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.delete_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Xóa lịch sử', style: TextStyle(fontSize: 18)),
              ],
            ),
            content: const Text(
              'Bạn có chắc chắn muốn xóa bản ghi lịch sử quét này không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<HistoryCubit>().deleteHistory(userId, historyId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa lịch sử quét thành công'),
                      backgroundColor: Color(0xFF2E7D32),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'Tất cả', 'icon': Icons.grid_view_rounded},
      {'title': 'Quét AI', 'icon': Icons.center_focus_strong_rounded},
      {'title': 'Giao nộp trạm', 'icon': Icons.local_shipping_rounded},
      {'title': 'Tích & Đổi điểm', 'icon': Icons.card_giftcard_rounded},
    ];
    final times = ['Tất cả thời gian', 'Hôm nay', '7 ngày qua', '30 ngày qua'];

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          context.read<HistoryCubit>().listenHistory(authState.user.id);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF4F7F5),
          elevation: 0,
          title: const Text(
            "Nhật ký phân loại 🌿",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final userId =
                authState is AuthAuthenticated ? authState.user.id : '';

            return BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, historyState) {
                final allHistory =
                    historyState is HistoryLoaded
                        ? historyState.history
                        : <ScanHistoryEntity>[];
                final filteredList = _filterHistory(allHistory);

                final totalScans = allHistory.length;
                final totalPoints = allHistory.fold<int>(
                  0,
                  (sum, item) => sum + item.pointsEarned,
                );
                final totalRecycled =
                    allHistory
                        .where(
                          (item) =>
                              item.category.toLowerCase().contains('tái chế'),
                        )
                        .length;

                return RefreshIndicator(
                  color: const Color(0xFF2E7D32),
                  onRefresh: () async {
                    if (userId.isNotEmpty) {
                      context.read<HistoryCubit>().listenHistory(userId);
                    }
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Banner thống kê thành tích
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1B5E20),
                              Color(0xFF2E7D32),
                              Color(0xFF388E3C),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF2E7D32,
                              ).withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Thành Tích Phân Loại Xanh",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.recycling_rounded,
                                        color: Color(0xFFC8E6C9),
                                        size: 22,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$totalScans lượt",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        "Đã phân loại",
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
                                      const Icon(
                                        Icons.card_giftcard_rounded,
                                        color: Color(0xFFC8E6C9),
                                        size: 22,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "+$totalPoints",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        "Điểm tích lũy",
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
                                      const Icon(
                                        Icons.eco_rounded,
                                        color: Color(0xFFC8E6C9),
                                        size: 22,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$totalRecycled món",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        "Rác tái chế",
                                        style: TextStyle(
                                          color: Color(0xFFE8F5E9),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tabs chọn danh mục
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          itemCount: categories.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final isSelected = _selectedCategoryTab == index;
                            final item = categories[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                showCheckmark: false,
                                avatar: Icon(
                                  item['icon'] as IconData,
                                  size: 16,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : const Color(0xFF2E7D32),
                                ),
                                label: Text(
                                  item['title'] as String,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: const Color(0xFF2E7D32),
                                backgroundColor: Colors.white,
                                elevation: isSelected ? 2 : 0,
                                side: BorderSide(
                                  color:
                                      isSelected
                                          ? const Color(0xFF2E7D32)
                                          : Colors.grey.shade300,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _selectedCategoryTab = index;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Filter thời gian
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Colors.grey,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "Thời gian:",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(times.length, (index) {
                                  final isSelected =
                                      _selectedTimeFilter == index;
                                  return InkWell(
                                    onTap:
                                        () => setState(
                                          () => _selectedTimeFilter = index,
                                        ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? const Color(0xFFE8F5E9)
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? const Color(0xFF2E7D32)
                                                  : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        times[index],
                                        style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              isSelected
                                                  ? const Color(0xFF1B5E20)
                                                  : Colors.grey,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (historyState is HistoryLoading && allHistory.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        )
                      else if (historyState is HistoryError &&
                          allHistory.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red.shade700,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Không thể tải lịch sử: ${historyState.error}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _loadHistoryIfAuthenticated,
                                child: const Text("Thử lại"),
                              ),
                            ],
                          ),
                        )
                      else if (filteredList.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 40,
                            horizontal: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.history_toggle_off_rounded,
                                  color: Color(0xFF2E7D32),
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Chưa có lịch sử phân loại nào",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Hãy dùng camera Quét rác để nhận diện và tích lũy điểm thưởng nhé!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...filteredList.map((item) {
                          final hasImage =
                              item.imagePath.isNotEmpty &&
                              File(item.imagePath).existsSync();
                          final confidencePct = (item.confidence <= 1
                                  ? (item.confidence * 100).toInt()
                                  : item.confidence.toInt())
                              .clamp(0, 100);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail ảnh hoặc Icon
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child:
                                      hasImage
                                          ? Image.file(
                                            File(item.imagePath),
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                          )
                                          : Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F5E9),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.center_focus_strong_rounded,
                                              color: Color(0xFF2E7D32),
                                            ),
                                          ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.label,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF1B5E20,
                                              ).withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item.category.isNotEmpty
                                                  ? item.category
                                                  : "Rác tái chế",
                                              style: const TextStyle(
                                                color: Color(0xFF1B5E20),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        item.instruction.isNotEmpty
                                            ? item.instruction
                                            : "Quét tự động qua AI Camera",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 12,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDateTime(item.createdAt),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(
                                            Icons.verified_outlined,
                                            size: 12,
                                            color: Color(0xFF2E7D32),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "$confidencePct%",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF2E7D32),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "+ ${item.pointsEarned} điểm",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () {
                                        if (userId.isNotEmpty) {
                                          _confirmDelete(
                                            context,
                                            userId,
                                            item.id,
                                          );
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(6),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.delete_outline_rounded,
                                          size: 18,
                                          color: Colors.red.shade400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
