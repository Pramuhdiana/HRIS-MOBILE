import 'package:flutter/material.dart';

/// App Colors based on POS Mobile Figma Template
/// Adapted for HRIS Mobile Application
class AppColors {
  // Primary Colors (Updated to match Figma POS Mobile template)
  static const Color primary = Color(0xFF2196F3); // More vibrant blue like POS
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);

  // Secondary Colors
  static const Color secondary = Color(0xFF3EBAE0);
  static const Color secondaryLight = Color(0xFF66C8E5);
  static const Color secondaryDark = Color(0xFF2A8DB3);

  // Accent Colors
  static const Color accent = Color(0xFFFFA726);
  static const Color accentLight = Color(0xFFFFB951);
  static const Color accentDark = Color(0xFFCC8520);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFFF1F3F4);

  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textLight = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);

  // Border Colors
  static const Color border = Color(0xFFE9ECEF);
  static const Color borderLight = Color(0xFFF8F9FA);
  static const Color borderDark = Color(0xFFDEE2E6);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x26000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  // Chart Colors (for dashboard/analytics)
  static const List<Color> chartColors = [
    primary,
    secondary,
    accent,
    success,
    warning,
    error,
    info,
  ];
}
