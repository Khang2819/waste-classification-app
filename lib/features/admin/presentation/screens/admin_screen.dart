import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../profile/presentation/widgets/logout_dialog.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/admin_dashboard_tab.dart';
import '../widgets/admin_notifications_tab.dart';
import '../widgets/admin_rewards_tab.dart';
import '../widgets/admin_users_tab.dart';
import '../widgets/admin_waste_points_tab.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _switchToTab(int index) {
    if (index >= 0 && index < _tabController.length) {
      _tabController.animateTo(index);
    }
  }

  bool _checkIsAdmin(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final profileState = context.watch<ProfileCubit>().state;
    final isAuthAdmin =
        authState is AuthAuthenticated && authState.user.isAdmin;
    final isProfileAdmin =
        profileState is ProfileLoaded && profileState.user.isAdmin;
    return isAuthAdmin || isProfileAdmin;
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _checkIsAdmin(context);

    // Chặn người dùng thường nếu cố tình truy cập vào /admin
    if (!isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Không có quyền truy cập',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.gpp_bad_rounded,
                  size: 64,
                  color: Color(0xFFDC2626),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Khu vực dành riêng cho Quản trị viên',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tài khoản của bạn không có quyền truy cập vào phân hệ Quản trị hệ thống.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.go('/main'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text(
                    'Quay về Trang chủ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocProvider<AdminCubit>(
      create: (_) => getIt<AdminCubit>()..loadAllData(),
      child: BlocConsumer<AdminCubit, AdminState>(
        listenWhen:
            (prev, curr) =>
                prev.errorMessage != curr.errorMessage ||
                prev.successMessage != curr.successMessage,
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<AdminCubit>().clearMessages();
          } else if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: const Color(0xFF1E293B),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<AdminCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              foregroundColor: const Color(0xFF1E293B),
              elevation: 0,
              centerTitle: false,
              title: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quản Trị Hệ Thống',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'Quản lý người dùng, trạm thu gom & kho quà',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Giao diện Người dùng (/main)',
                  onPressed: () => context.go('/main'),
                  icon: const Icon(
                    Icons.home_outlined,
                    color: Color(0xFF334155),
                  ),
                ),
                IconButton(
                  tooltip: 'Làm mới dữ liệu',
                  onPressed:
                      state.isLoading
                          ? null
                          : () => context.read<AdminCubit>().loadAllData(),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF334155),
                  ),
                ),
                IconButton(
                  tooltip: 'Đăng xuất',
                  onPressed: () => LogoutDialog.show(context),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(54),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: const Color(0xFF2E7D32),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFF2E7D32),
                    unselectedLabelColor: const Color(0xFF64748B),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.grid_view_rounded, size: 19),
                        text: 'Tổng quan',
                      ),
                      Tab(
                        icon: Icon(Icons.location_on_outlined, size: 19),
                        text: 'Điểm thu gom',
                      ),
                      Tab(
                        icon: Icon(Icons.card_giftcard_rounded, size: 19),
                        text: 'Quà & Voucher',
                      ),
                      Tab(
                        icon: Icon(Icons.people_outline_rounded, size: 19),
                        text: 'Người dùng & QR',
                      ),
                      Tab(
                        icon: Icon(Icons.notifications_none_rounded, size: 19),
                        text: 'Thông báo',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: [
                    AdminDashboardTab(onSwitchTab: _switchToTab),
                    const AdminWastePointsTab(),
                    const AdminRewardsTab(),
                    const AdminUsersTab(),
                    const AdminNotificationsTab(),
                  ],
                ),
                if (state.isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.12),
                    child: const Center(
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF2E7D32),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Đang tải dữ liệu...',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
