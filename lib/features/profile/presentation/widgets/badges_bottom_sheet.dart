import 'package:flutter/material.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/badge_entity.dart';

class BadgesBottomSheet extends StatelessWidget {
  final User? user;

  const BadgesBottomSheet({super.key, required this.user});

  static Future<void> show(BuildContext context, User? user) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BadgesBottomSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanned = user?.totalScanned ?? 0;
    final points = user?.greenPoints ?? 0;
    final xp = user?.totalXP ?? 0;

    final badges = SystemBadges.allBadges;
    final unlockedCount =
        badges.where((b) => b.isUnlocked(scanned, points, xp)).length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Bộ Sưu Tập Huy Hiệu",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$unlockedCount/${badges.length} Đã mở",
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: badges.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = badges[index];
                final isUnlocked = item.isUnlocked(scanned, points, xp);

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        isUnlocked
                            ? const Color(0xFFF9FBE7).withValues(alpha: 0.4)
                            : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isUnlocked
                              ? const Color(0xFFC8E6C9)
                              : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isUnlocked
                                  ? item.color.withValues(alpha: 0.15)
                                  : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          color: isUnlocked ? item.color : Colors.grey.shade400,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color:
                                    isUnlocked
                                        ? const Color(0xFF1B5E20)
                                        : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isUnlocked
                                        ? Colors.black87
                                        : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isUnlocked
                            ? Icons.check_circle_rounded
                            : Icons.lock_outline_rounded,
                        color:
                            isUnlocked
                                ? const Color(0xFF2E7D32)
                                : Colors.grey.shade400,
                        size: 22,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
