import 'package:flutter/material.dart';

/// App Colors based on POS Mobile Figma Template
/// Adapted for HRIS Mobile Application
class AppColors {
  // === BLUE FROST THEME (RECOMMENDED) ===

  // Background Gradient
  static const liquidGlassBackdrop = Color(0xFF4A90E2);
  static const gradientStart = Color(0xFF4A90E2); // Professional blue
  static const gradientEnd = Color(0xFFE8F4F8); // Ice blue

  // Glass Overlay
  static final glassOverlayTop = Colors.white.withValues(alpha: 0.6);
  static final glassOverlayBottom = Colors.white.withValues(alpha: 0.15);

  // Primary Colors
  static const primary = Color(0xFF2C5AA0); // Deep blue
  // static const primary = Color(0xFF2D9B94); // TEAL

  static const primaryLight = Color(0xFF64B5F6); // Light blue
  static const primaryDark = Color(0xFF1A3A6B); // Darker blue

  // Secondary Colors
  static const secondary = Color(0xFF64B5F6); // Accent blue
  // static const secondary = Color(0xFF80CBC4); // Mint
  static const secondaryLight = Color(0xFF90CAF9);

  // Surface & Background
  static const surface = Color(0xFFF5FBFF); // Almost white
  static const surfaceVariant = Color(0xFFE1F5FE);
  static const background = Color(0xFFFFFFFF);

  // Text Colors
  static const textPrimary = Color(0xFF1A3A6B); // Dark blue
  static const textSecondary = Color(0xFF546E7A); // Gray blue
  static const textTertiary = Color(0xFF90A4AE); // Light gray

  // Status Colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFA726);
  static const error = Color(0xFFEF5350);
  static const info = Color(0xFF29B6F6);

  // Glass Effect Colors
  static final glassBorder = Colors.white.withValues(alpha: 0.3);
  static final glassShadow = Colors.black.withValues(alpha: 0.1);

  // Secondary Colors
  static const Color secondaryDark = Color(0xFF2A8DB3);

  // Accent Colors
  static const Color accent = Color(0xFFFFA726);
  static const Color accentLight = Color(0xFFFFB951);
  static const Color accentDark = Color(0xFFCC8520);

  // Background Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFFF1F3F4);

  /// Selaras dengan ujung gradien [LiquidGlassScaffold]; dipakai agar overscroll
  /// / pull-to-refresh tidak memunculkan putih Material yang kontras dengan gradien.

  // Text Colors
  static const Color textLight = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

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
