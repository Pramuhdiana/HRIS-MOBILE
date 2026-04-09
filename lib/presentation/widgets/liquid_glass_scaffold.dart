import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Reusable scaffold dengan background gradient Liquid Glass.
class LiquidGlassScaffold extends StatelessWidget {
  const LiquidGlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.liquidGlassBackdrop,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6FB1FC), Color(0xFFEAF3FF)],
                stops: [0.0, 1.0],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.55),
                  Colors.white.withValues(alpha: 0.18),
                ],
              ),
            ),
          ),
          body,
        ],
      ),
    );
  }
}
