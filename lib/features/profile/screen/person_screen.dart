import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/green_points_wallet_card.dart';
import '../widgets/logout_dialog.dart';
import '../widgets/profile_account_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_quick_actions.dart';
import '../widgets/user_level_card.dart';

class PersonScreen extends StatelessWidget {
  const PersonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final avatarUrl =
            (user?.avatar?.isNotEmpty ?? false)
                ? user!.avatar!
                : "https://jbagy.me/wp-content/uploads/2025/03/Hinh-anh-anime-dang-yeu-khong-the-cuong-duoc-2.jpg";
        final displayName =
            (user?.fullName.isNotEmpty == true)
                ? user!.fullName
                : ((user?.email.isNotEmpty == true)
                    ? user!.email
                    : "Nguyễn Văn Khang");

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F5),
          body: SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(avatarUrl: avatarUrl, displayName: displayName),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const UserLevelCard(),
                      const SizedBox(height: 10),
                      const GreenPointsWalletCard(),
                      const SizedBox(height: 10),
                      const ProfileQuickActions(),
                      const SizedBox(height: 10),
                      const ProfileAccountSection(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => LogoutDialog.show(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: Colors.red.shade200,
                              width: 1.5,
                            ),
                            backgroundColor: Colors.red.shade50.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: const Text(
                            "Đăng xuất",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
}
