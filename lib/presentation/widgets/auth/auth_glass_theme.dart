import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../liquid_glass_scaffold.dart';

/// Shared auth visual tokens supaya login/onboarding/session-expired konsisten.
abstract final class AuthGlassTheme {
  static const LiquidGlassTheme scaffoldTheme = LiquidGlassTheme.oceanBlue;

  static const Color inkPrimary = AppColors.textPrimary;
  static const Color inkSecondary = AppColors.textSecondary;
  static const Color inkIcon = AppColors.textPrimary;

  static const Color primaryBlue = AppColors.primary;
  static const Color accentCyan = AppColors.secondary;
  static const Color panelTint = Color(0xFFE9F5FF);
}
