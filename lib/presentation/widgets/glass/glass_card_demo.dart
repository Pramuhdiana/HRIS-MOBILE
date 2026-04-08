import 'package:flutter/material.dart';

import 'glass_card.dart';

/// Demo [GlassCard] dengan beberapa kartu dan latar gradien.
class GlassCardExample extends StatelessWidget {
  const GlassCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GlassCard demo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.black.withValues(alpha: 0.15),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
              Color(0xFF4facfe),
            ],
            stops: [0.0, 0.33, 0.66, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '💧 Water Glass Effect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sentuh kartu untuk melihat efek ripple air dan animasi 3D',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Focal point mengikuti sentuhan • Push effect di area sentuh • Water ripple realistis',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(24),
                    onTap: () {},
                    enableWaterRipple: true,
                    enableShimmer: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.water_drop,
                            color: Color(0xFF1565C0),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Water Ripple Effect',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0A0A0A),
                                letterSpacing: -0.3,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sentuh kartu ini untuk melihat efek ripple air dengan multiple layers yang realistis. Animasi mengikuti posisi sentuhan Anda.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color(0xFF1A1A1A),
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1565C0,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 16,
                                    color: Color(0xFF0D47A1),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Shimmer Active',
                                    style: TextStyle(
                                      color: Color(0xFF0D47A1),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(24),
                    onTap: () {},
                    pressTilt: 0.15,
                    pressScale: 0.95,
                    pressSlidePixels: 10,
                    waterRippleColor: Colors.cyan.withValues(alpha: 0.6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.threesixty,
                            color: Color(0xFF00ACC1),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Enhanced 3D Tilt',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0A0A0A),
                                letterSpacing: -0.3,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kartu ini memiliki efek tilt 3D yang lebih kuat. Coba tekan di berbagai posisi untuk melihat perspective yang berbeda.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color(0xFF1A1A1A),
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF00ACC1,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.threed_rotation,
                                    size: 16,
                                    color: Color(0xFF006064),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    '3D Perspective',
                                    style: TextStyle(
                                      color: Color(0xFF006064),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(24),
                    onTap: () {},
                    waterRippleColor: Colors.pink.withValues(alpha: 0.7),
                    waterRippleDuration: const Duration(milliseconds: 1500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.palette,
                            color: Color(0xFFE91E63),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Custom Ripple Color',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0A0A0A),
                                letterSpacing: -0.3,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Efek ripple dengan warna custom dan durasi yang lebih panjang. Push effect terlihat lebih jelas dengan animasi yang smooth.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color(0xFF1A1A1A),
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFE91E63,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.color_lens,
                                    size: 16,
                                    color: Color(0xFFC2185B),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Custom Color',
                                    style: TextStyle(
                                      color: Color(0xFFC2185B),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
