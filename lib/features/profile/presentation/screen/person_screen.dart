import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/level_calculator.dart';
import '../../domain/badge_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/badges_bottom_sheet.dart';
import '../widgets/green_points_wallet_card.dart';
import '../widgets/logout_dialog.dart';
import '../widgets/personal_qr_bottom_sheet.dart';
import '../widgets/profile_account_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_quick_actions.dart';
import '../widgets/user_level_card.dart';

class PersonScreen extends StatelessWidget {
  const PersonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        final user = profileState is ProfileLoaded ? profileState.user : null;
        final avatarUrl =
            (user?.avatar?.isNotEmpty ?? false) ? user!.avatar! : null;
        final displayName =
            (user?.fullName.isNotEmpty == true)
                ? user!.fullName
                : ((user?.email.isNotEmpty == true) ? user!.email : "Bạn");
        final totalXp = user?.totalXP ?? 0;
        final rankTitle = LevelCalculator.getRankBadge(totalXp);
        final scanned = user?.totalScanned ?? 0;
        final points = user?.greenPoints ?? 0;
        final xp = user?.totalXP ?? 0;

        final unlockedCount =
            SystemBadges.allBadges
                .where((b) => b.isUnlocked(scanned, points, xp))
                .length;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F5),
          body: SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(
                  rankTitle: rankTitle,
                  avatarUrl: avatarUrl ?? '',
                  displayName: displayName,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      UserLevelCard(totalXp: user?.totalXP ?? 0),
                      const SizedBox(height: 10),
                      GreenPointsWalletCard(
                        points: user?.greenPoints ?? 0,
                        onRedeemTap: () => context.push('/redeem'),
                      ),
                      const SizedBox(height: 10),
                      ProfileQuickActions(
                        unlockedBadgesText:
                            "$unlockedCount/${SystemBadges.allBadges.length} Đạt được",
                        onBadgesTap:
                            () => BadgesBottomSheet.show(context, user),
                        onQrTap:
                            () => PersonalQrBottomSheet.show(context, user),
                      ),
                      const SizedBox(height: 10),
                      const ProfileAccountSection(
                        title: 'Tài khoản và Địa chỉ',
                      ),
                      const SizedBox(height: 20),
                      const ProfileAccountSection(
                        title: 'Hoạt động và Nhật ký',
                      ),
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
