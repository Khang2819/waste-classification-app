import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Palette (Green Theme for Smart Waste App)
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4CAF50);

  // Background & Surface
  static const Color background = Color(0xFFF4F7F5);
  static const Color surface = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textHint = Colors.grey;

  // Border Colors
  static final Color border = Colors.grey.withValues(alpha: 0.3);

  // Status Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Colors.orange;
  static const Color success = Color(0xFF2E7D32);
}
