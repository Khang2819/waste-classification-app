import 'package:flutter/material.dart';

class BadgeItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool Function(int totalScanned, int greenPoints, int totalXp)
  isUnlocked;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });
}

class SystemBadges {
  static final List<BadgeItem> allBadges = [
    BadgeItem(
      id: 'first_scan',
      title: 'Khởi Đầu Xanh',
      description: 'Thực hiện phân loại rác lần đầu tiên',
      icon: Icons.eco_rounded,
      color: Colors.green,
      isUnlocked: (scanned, points, xp) => scanned >= 1,
    ),
    BadgeItem(
      id: 'scanner_10',
      title: 'Người Gom Rác',
      description: 'Phân loại thành công 10 món rác',
      icon: Icons.recycling_rounded,
      color: Colors.teal,
      isUnlocked: (scanned, points, xp) => scanned >= 10,
    ),
    BadgeItem(
      id: 'scanner_50',
      title: 'Dũng Sĩ Tái Chế',
      description: 'Đạt mốc 50 lần phân loại rác',
      icon: Icons.military_tech_rounded,
      color: Colors.amber.shade700,
      isUnlocked: (scanned, points, xp) => scanned >= 50,
    ),
    BadgeItem(
      id: 'points_100',
      title: 'Nhà Tích Điểm',
      description: 'Tích lũy đạt 100 GreenPoints',
      icon: Icons.monetization_on_rounded,
      color: Colors.orange,
      isUnlocked: (scanned, points, xp) => points >= 100,
    ),
    BadgeItem(
      id: 'xp_500',
      title: 'Chiến Binh Bền Bỉ',
      description: 'Đạt từ 500 XP kinh nghiệm trở lên',
      icon: Icons.bolt_rounded,
      color: Colors.blueAccent,
      isUnlocked: (scanned, points, xp) => xp >= 500,
    ),
    BadgeItem(
      id: 'master_eco',
      title: 'Bậc Thầy Môi Trường',
      description: 'Cán mốc 100 lần quét rác thông minh',
      icon: Icons.workspace_premium_rounded,
      color: Colors.purple,
      isUnlocked: (scanned, points, xp) => scanned >= 100,
    ),
  ];
}
