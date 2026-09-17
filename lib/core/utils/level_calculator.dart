class LevelCalculator {
  // Mỗi level cần 500 XP
  static const int xpPerLevel = 500;

  static int getLevel(int totalXp) {
    return (totalXp ~/ xpPerLevel) + 1;
  }

  static String getTitle(int level) {
    if (level < 3) return 'Tập Sự Xanh';
    if (level < 6) return 'Chiến Binh Xanh';
    if (level < 10) return 'Đại Sứ Môi Trường';
    return 'Huyền Thoại Xanh';
  }

  static String getRankBadge(int totalXp) {
    final level = getLevel(totalXp);
    final title = getTitle(level);

    if (level < 3) {
      return '$title • Hạng Đồng 🥉';
    } else if (level < 6) {
      return '$title • Hạng Bạc 🥈';
    } else if (level < 10) {
      return '$title • Hạng Vàng 🥇';
    } else {
      return '$title • Hạng Kim Cương 💎';
    }
  }

  // XP tích lũy trong level hiện tại
  static int getCurrentLevelXp(int totalXp) {
    return totalXp % xpPerLevel;
  }

  // XP còn thiếu để lên cấp tiếp theo
  static int getRemainingXp(int totalXp) {
    return xpPerLevel - getCurrentLevelXp(totalXp);
  }

  // Giá trị thanh tiến trình (0.0 đến 1.0)
  static double getProgress(int totalXp) {
    return (getCurrentLevelXp(totalXp) / xpPerLevel).clamp(0.0, 1.0);
  }
}
