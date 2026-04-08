import 'package:flutter/material.dart';

/// Data satu sesi ripple air (dipicu dari [GlassCard]).
class WaterRipple {
  const WaterRipple({
    required this.position,
    required this.controller,
    required this.color,
  });

  final Offset position;
  final AnimationController controller;
  final Color color;
}

/// Ripple berlapis untuk efek air.
class WaterRippleWidget extends StatelessWidget {
  const WaterRippleWidget({super.key, required this.ripple});

  final WaterRipple ripple;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ripple.controller,
      builder: (context, child) {
        final progress = ripple.controller.value;
        final eased = Curves.easeOutCubic.transform(progress);
        final scale = eased * 3.8;
        final opacity = (1 - eased).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(-50 * scale, -50 * scale),
          child: Stack(
            children: [
              Container(
                width: 100 * scale * 1.2,
                height: 100 * scale * 1.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ripple.color.withValues(
                        alpha: ripple.color.a * opacity * 0.6,
                      ),
                      ripple.color.withValues(
                        alpha: ripple.color.a * opacity * 0.3,
                      ),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: (100 * scale * 1.2 - 100 * scale) / 2,
                top: (100 * scale * 1.2 - 100 * scale) / 2,
                child: Container(
                  width: 100 * scale,
                  height: 100 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ripple.color.withValues(
                          alpha: ripple.color.a * opacity * 0.8,
                        ),
                        ripple.color.withValues(
                          alpha: ripple.color.a * opacity * 0.4,
                        ),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: (100 * scale * 1.2 - 60 * scale) / 2,
                top: (100 * scale * 1.2 - 60 * scale) / 2,
                child: Container(
                  width: 60 * scale,
                  height: 60 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ripple.color.withValues(
                          alpha: ripple.color.a * opacity,
                        ),
                        ripple.color.withValues(
                          alpha: ripple.color.a * opacity * 0.5,
                        ),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
