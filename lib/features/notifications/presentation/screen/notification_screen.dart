import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/app_notification.dart';
import '../cubit/notification_cubit.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Đọc tất cả',
              style: TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryGreen,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Tất cả',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  // Badge hiển thị sau khi load xong
                  BlocBuilder<NotificationCubit, NotificationState>(
                    builder: (_, state) {
                      if (state is NotificationLoaded) {
                        return _buildBadge(state.items.length);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Chưa đọc',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  BlocBuilder<NotificationCubit, NotificationState>(
                    builder: (_, state) {
                      if (state is NotificationLoaded) {
                        final unread =
                            state.items.where((n) => !n.isRead).length;
                        return _buildBadge(unread);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationError) {
            return Center(child: Text(state.message));
          }
          if (state is NotificationLoaded) {
            final unreadItems = state.items.where((n) => !n.isRead).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Tất cả
                state.items.isEmpty
                    ? _buildEmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: 'Chưa có thông báo',
                      description:
                          'Các thông báo về phân loại rác, điểm xanh '
                          'và phần thưởng sẽ xuất hiện tại đây.',
                    )
                    : _buildNotificationList(state.items),

                // Tab 2: Chưa đọc
                unreadItems.isEmpty
                    ? _buildEmptyState(
                      icon: Icons.mark_email_read_outlined,
                      title: 'Bạn đã đọc tất cả',
                      description: 'Không có thông báo chưa đọc nào.',
                    )
                    : _buildNotificationList(unreadItems),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ─── List ────────────────────────────────────────────────────────────────

  Widget _buildNotificationList(List<AppNotification> items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder:
          (_, __) => const Divider(
            height: 1,
            indent: 72,
            endIndent: 16,
            color: Color(0xFFE6EAE7),
          ),
      itemBuilder: (context, index) => _buildNotificationTile(items[index]),
    );
  }

  Widget _buildNotificationTile(AppNotification notification) {
    final icon = _iconForType(notification.type);
    final timeLabel = _formatTime(notification.createdAt);

    return InkWell(
      onTap: () {},
      child: Container(
        color: notification.isRead ? Colors.white : const Color(0xFFEDF7EE),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon vòng tròn
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32), size: 24),
            ),
            const SizedBox(width: 12),
            // Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight:
                                notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                            fontSize: 14,
                            color: const Color(0xFF1B1B1B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // Chấm chưa đọc
            if (!notification.isRead)
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 8),
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Color(0xFF2E7D32),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Empty state ─────────────────────────────────────────────────────────

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(icon, size: 56, color: const Color(0xFF66BB6A)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Badge ───────────────────────────────────────────────────────────────

  Widget _buildBadge(int count) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  IconData _iconForType(String type) {
    switch (type) {
      case 'reward':
        return Icons.card_giftcard_rounded;
      case 'scan':
        return Icons.qr_code_scanner_rounded;
      case 'map':
        return Icons.location_on_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    if (diff.inDays < 7) return '${diff.inDays} ngày';
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  void _markAllAsRead() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc.')),
    );
  }
}
