import 'dart:ui';

import 'package:flutter/material.dart';

/// Reusable surface untuk tampilan Liquid Glass (blur + border tipis + gradient).
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 24,
    this.padding,
    this.blurSigma = 20,
    this.borderAlpha = 0.30,
    this.topAlpha = 0.26,
    this.bottomAlpha = 0.14,
    this.shadowAlpha = 0.03,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsets? padding;
  final double blurSigma;
  final double borderAlpha;
  final double topAlpha;
  final double bottomAlpha;
  final double shadowAlpha;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withValues(alpha: 0.06),
            highlightColor: Colors.white.withValues(alpha: 0.03),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: borderAlpha),
                  width: 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: topAlpha),
                    Colors.white.withValues(alpha: bottomAlpha),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: shadowAlpha),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
