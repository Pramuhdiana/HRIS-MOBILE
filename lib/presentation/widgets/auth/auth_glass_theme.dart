import 'package:flutter/material.dart';

import '../liquid_glass_scaffold.dart';

/// Shared auth visual tokens supaya login/onboarding/session-expired konsisten.
abstract final class AuthGlassTheme {
  static const LiquidGlassTheme scaffoldTheme = LiquidGlassTheme.oceanBlue;

  static const Color inkPrimary = Color(0xFF0F2741);
  static const Color inkSecondary = Color(0xFF2E4C6B);
  static const Color inkIcon = Color(0xFF123459);

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color accentCyan = Color(0xFF38BDF8);
  static const Color panelTint = Color(0xFFE9F5FF);
}
