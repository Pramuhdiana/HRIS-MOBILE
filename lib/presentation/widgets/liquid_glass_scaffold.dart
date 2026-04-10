import 'package:flutter/material.dart';

/// Reusable scaffold dengan background gradient Liquid Glass + Abstract Flowing Shapes.
/// Premium design inspired by modern mobile OS aesthetics.
class LiquidGlassScaffold extends StatelessWidget {
  const LiquidGlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.theme = LiquidGlassTheme.oceanBlue,
    this.showFlowingShapes = true,
    this.showFlowingLines = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final LiquidGlassTheme theme;
  final bool showFlowingShapes;
  final bool showFlowingLines;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Base gradient dengan 3 colors untuk depth
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.gradientColors,
                stops: const [0.0, 0.34, 0.68, 1.0],
              ),
            ),
          ),

          // Abstract flowing shapes (opsional)
          if (showFlowingShapes) ..._buildFlowingShapes(),

          // Flowing lines pattern (opsional)
          if (showFlowingLines) _buildFlowingLines(),

          // Premium accent glow untuk memperkaya depth tiap tema
          _buildAccentGlow(),

          // Glass overlay effect
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.glassTintTop,
                  Colors.white.withValues(alpha: theme.glassOpacityTop),
                  theme.glassTintMid,
                  Colors.white.withValues(alpha: theme.glassOpacityBottom),
                ],
                stops: const [0.0, 0.2, 0.58, 1.0],
              ),
            ),
          ),

          // Subtle grain texture untuk premium feel
          _buildGrainTexture(),

          // Content
          body,
        ],
      ),
    );
  }

  /// Build abstract flowing shapes
  List<Widget> _buildFlowingShapes() {
    final shapeColors = theme.flowingShapeColors;
    return [
      // Shape 1 - Top right
      Positioned(
        top: -120,
        right: -80,
        child: _FlowingShape(
          size: 320,
          color: shapeColors[0],
          rotation: 0.3,
        ),
      ),
      // Shape 2 - Bottom left
      Positioned(
        bottom: -100,
        left: -70,
        child: _FlowingShape(
          size: 380,
          color: shapeColors[1],
          rotation: -0.5,
        ),
      ),
      // Shape 3 - Middle left
      Positioned(
        top: 180,
        left: -50,
        child: _FlowingShape(
          size: 220,
          color: shapeColors[2],
          rotation: 0.8,
        ),
      ),
      // Shape 4 - Middle right (smaller accent)
      Positioned(
        top: 350,
        right: -30,
        child: _FlowingShape(
          size: 180,
          color: shapeColors[3],
          rotation: -0.3,
        ),
      ),
    ];
  }

  /// Build flowing lines pattern
  Widget _buildFlowingLines() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _FlowingLinesPainter(
            bandColors: theme.flowingBandColors,
            specs: [
              _FlowLineSpec(
                startColor: theme.flowingLineColors[0],
                endColor: theme.flowingLineColors[2],
                strokeWidth: 2.35,
                startAnchor: 0.34,
                endLift: -0.11,
                bend: -0.16,
              ),
              _FlowLineSpec(
                startColor: theme.flowingLineColors[3],
                endColor: theme.flowingLineColors[1],
                strokeWidth: 1.95,
                startAnchor: 0.48,
                endLift: -0.08,
                bend: -0.13,
              ),
              _FlowLineSpec(
                startColor: theme.flowingLineColors[1],
                endColor: theme.flowingLineColors[3],
                strokeWidth: 2.2,
                startAnchor: 0.62,
                endLift: -0.06,
                bend: 0.1,
              ),
              _FlowLineSpec(
                startColor: theme.flowingLineColors[2],
                endColor: theme.flowingLineColors[0],
                strokeWidth: 1.85,
                startAnchor: 0.76,
                endLift: -0.05,
                bend: -0.08,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccentGlow() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: theme.accentCenterA,
          radius: 1.05,
          colors: [theme.accentGlowA, Colors.transparent],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: theme.accentCenterB,
            radius: 1.15,
            colors: [theme.accentGlowB, Colors.transparent],
          ),
        ),
      ),
    );
  }

  /// Build subtle grain texture
  Widget _buildGrainTexture() {
    return Opacity(
      opacity: 0.025,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/noise.png'),
            repeat: ImageRepeat.repeat,
            fit: BoxFit.none,
            // Jika tidak ada asset, bisa pakai pattern sederhana
            onError: (exception, stackTrace) {},
          ),
        ),
        // Fallback jika tidak ada texture
        foregroundDecoration: const BoxDecoration(color: Colors.transparent),
      ),
    );
  }
}

/// Abstract flowing shape widget dengan gradient radial
class _FlowingShape extends StatelessWidget {
  const _FlowingShape({
    required this.size,
    required this.color,
    required this.rotation,
  });

  final double size;
  final Color color;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: color.a * 0.5),
              color.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Custom painter untuk flowing lines pattern
class _FlowingLinesPainter extends CustomPainter {
  final List<Color> bandColors;
  final List<_FlowLineSpec> specs;

  _FlowingLinesPainter({required this.bandColors, required this.specs});

  @override
  void paint(Canvas canvas, Size size) {
    const xMin = -40.0;
    final xMax = size.width + 40.0;
    const step = 14.0;
    final boundaries = specs
        .map((spec) => _sampleCurvePoints(spec, size, xMin, xMax, step))
        .toList();

    final topEdge = _horizontalPoints(y: -20, xMin: xMin, xMax: xMax, step: step);
    final bottomEdge = _horizontalPoints(
      y: size.height + 20,
      xMin: xMin,
      xMax: xMax,
      step: step,
    );

    for (var i = 0; i <= boundaries.length; i++) {
      final upper = i == 0 ? topEdge : boundaries[i - 1];
      final lower = i == boundaries.length ? bottomEdge : boundaries[i];
      final bandPath = Path()..moveTo(upper.first.dx, upper.first.dy);
      for (final p in upper.skip(1)) {
        bandPath.lineTo(p.dx, p.dy);
      }
      for (final p in lower.reversed) {
        bandPath.lineTo(p.dx, p.dy);
      }
      bandPath.close();

      final color = bandColors[i % bandColors.length];
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(bandPath, fillPaint);
    }

    for (final spec in specs) {
      final startY = size.height * spec.startAnchor;
      final endY = (startY + (size.height * spec.endLift)).clamp(
        16.0,
        size.height - 16.0,
      );
      final bendPx = size.height * spec.bend;
      final path = Path()
        ..moveTo(xMin, startY)
        ..cubicTo(
          size.width * 0.28,
          startY + bendPx,
          size.width * 0.68,
          endY + (bendPx * 0.65),
          xMax,
          endY,
        );
      final linePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [spec.startColor, spec.endColor],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..strokeWidth = spec.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, linePaint);
    }
  }

  List<Offset> _sampleCurvePoints(
    _FlowLineSpec spec,
    Size size,
    double xMin,
    double xMax,
    double step,
  ) {
    final points = <Offset>[];
    final startY = size.height * spec.startAnchor;
    final endY = (startY + (size.height * spec.endLift)).clamp(
      16.0,
      size.height - 16.0,
    );
    final bendPx = size.height * spec.bend;
    for (double x = xMin; x <= xMax; x += step) {
      final t = ((x - xMin) / (xMax - xMin)).clamp(0.0, 1.0);
      final y = _cubicBezierY(
        t,
        startY,
        startY + bendPx,
        endY + (bendPx * 0.65),
        endY,
      );
      points.add(Offset(x, y));
    }
    if (points.last.dx < xMax) {
      points.add(Offset(xMax, endY));
    }
    return points;
  }

  List<Offset> _horizontalPoints({
    required double y,
    required double xMin,
    required double xMax,
    required double step,
  }) {
    final points = <Offset>[];
    for (double x = xMin; x <= xMax; x += step) {
      points.add(Offset(x, y));
    }
    if (points.last.dx < xMax) {
      points.add(Offset(xMax, y));
    }
    return points;
  }

  double _cubicBezierY(double t, double p0, double p1, double p2, double p3) {
    final mt = 1 - t;
    return (mt * mt * mt * p0) +
        (3 * mt * mt * t * p1) +
        (3 * mt * t * t * p2) +
        (t * t * t * p3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FlowLineSpec {
  const _FlowLineSpec({
    required this.startColor,
    required this.endColor,
    required this.strokeWidth,
    required this.startAnchor,
    required this.endLift,
    required this.bend,
  });

  final Color startColor;
  final Color endColor;
  final double strokeWidth;
  final double startAnchor;
  final double endLift;
  final double bend;
}

/// Enum untuk theme variations - 5 preset profesional
enum LiquidGlassTheme {
  /// Deep navy → Ocean teal → Steel blue
  /// Use: Finance, Healthcare, Corporate
  oceanBlue,

  /// Coral red → Golden orange → Pink magenta
  /// Use: Creative, Social, Lifestyle
  sunsetCoral,

  /// Deep teal → Sage green → Navy blue
  /// Use: Sustainability, Wellness, Education
  forestEmerald,

  /// Deep purple → Teal → Blue violet
  /// Use: Premium, Beauty, Luxury
  royalPurple,

  /// Charcoal → Cool cyan → Silver gray
  /// Use: Tech, Productivity, B2B
  arcticSilver;

  /// Gradient colors untuk setiap theme
  List<Color> get gradientColors {
    switch (this) {
      case oceanBlue:
        return const [
          Color(0xFF1E3A8A), // Sapphire indigo
          Color(0xFF2563EB), // Vivid azure
          Color(0xFF38BDF8), // Aqua blue
          Color(0xFF93C5FD), // Frosted sky
        ];
      case sunsetCoral:
        return const [
          Color(0xFF7C2D12), // Deep copper
          Color(0xFFEA580C), // Burnt orange
          Color(0xFFF97316), // Bright coral
          Color(0xFFFEC89A), // Warm peach haze
        ];
      case forestEmerald:
        return const [
          Color(0xFF064E3B), // Deep emerald
          Color(0xFF059669), // Fresh jade
          Color(0xFF34D399), // Mint emerald
          Color(0xFFA7F3D0), // Glacier mint
        ];
      case royalPurple:
        return const [
          Color(0xFF4C1D95), // Deep violet
          Color(0xFF7C3AED), // Royal purple
          Color(0xFFA78BFA), // Orchid lavender
          Color(0xFFBFDBFE), // Icy periwinkle
        ];
      case arcticSilver:
        return const [
          Color(0xFF334155), // Blue graphite
          Color(0xFF475569), // Slate steel
          Color(0xFF7DD3FC), // Polar cyan
          Color(0xFFE2E8F0), // Soft silver mist
        ];
    }
  }

  /// Background color untuk scaffold
  Color get backgroundColor {
    switch (this) {
      case oceanBlue:
        return const Color(0xFF071229);
      case sunsetCoral:
        return const Color(0xFF5A1633);
      case forestEmerald:
        return const Color(0xFF082C2D);
      case royalPurple:
        return const Color(0xFF21082F);
      case arcticSilver:
        return const Color(0xFF1F2A35);
    }
  }

  /// Opacity untuk glass overlay top
  double get glassOpacityTop {
    switch (this) {
      case oceanBlue:
        return 0.22;
      case sunsetCoral:
        return 0.18;
      case forestEmerald:
        return 0.2;
      case royalPurple:
        return 0.2;
      case arcticSilver:
        return 0.24;
    }
  }

  /// Opacity untuk glass overlay bottom
  double get glassOpacityBottom {
    switch (this) {
      case oceanBlue:
        return 0.06;
      case sunsetCoral:
        return 0.07;
      case forestEmerald:
        return 0.06;
      case royalPurple:
        return 0.07;
      case arcticSilver:
        return 0.08;
    }
  }

  List<Color> get flowingShapeColors {
    switch (this) {
      case oceanBlue:
        return [
          const Color(0xFF73D7FF).withValues(alpha: 0.15),
          const Color(0xFFB7E5FF).withValues(alpha: 0.1),
          const Color(0xFF8BB8FF).withValues(alpha: 0.1),
          const Color(0xFFCFE6FF).withValues(alpha: 0.08),
        ];
      case sunsetCoral:
        return [
          const Color(0xFFFFD2A6).withValues(alpha: 0.14),
          const Color(0xFFFF8F70).withValues(alpha: 0.12),
          const Color(0xFFFFC3D7).withValues(alpha: 0.1),
          const Color(0xFFFFF0D2).withValues(alpha: 0.08),
        ];
      case forestEmerald:
        return [
          const Color(0xFF8EF0C6).withValues(alpha: 0.14),
          const Color(0xFFC8FFE5).withValues(alpha: 0.1),
          const Color(0xFF9DE6D1).withValues(alpha: 0.1),
          const Color(0xFFD8FFF2).withValues(alpha: 0.08),
        ];
      case royalPurple:
        return [
          const Color(0xFFC9A4FF).withValues(alpha: 0.14),
          const Color(0xFFE1D0FF).withValues(alpha: 0.1),
          const Color(0xFF8EC0FF).withValues(alpha: 0.1),
          const Color(0xFFF2E8FF).withValues(alpha: 0.08),
        ];
      case arcticSilver:
        return [
          const Color(0xFFC3E5F8).withValues(alpha: 0.14),
          const Color(0xFFE6F4FB).withValues(alpha: 0.1),
          const Color(0xFFABC8DA).withValues(alpha: 0.1),
          const Color(0xFFF3FAFF).withValues(alpha: 0.08),
        ];
    }
  }

  List<Color> get flowingLineColors {
    switch (this) {
      case oceanBlue:
        return [
          const Color(0xFFD9F4FF).withValues(alpha: 0.22),
          const Color(0xFF86DEFF).withValues(alpha: 0.19),
          const Color(0xFF8FB2FF).withValues(alpha: 0.24),
          const Color(0xFFF3FCFF).withValues(alpha: 0.15),
        ];
      case sunsetCoral:
        return [
          const Color(0xFFFFE7C8).withValues(alpha: 0.22),
          const Color(0xFFFFB88F).withValues(alpha: 0.19),
          const Color(0xFFFFA7BE).withValues(alpha: 0.24),
          const Color(0xFFFFF4E3).withValues(alpha: 0.15),
        ];
      case forestEmerald:
        return [
          const Color(0xFFE3FFF3).withValues(alpha: 0.22),
          const Color(0xFF9EF0CB).withValues(alpha: 0.19),
          const Color(0xFFBFFFE2).withValues(alpha: 0.24),
          const Color(0xFFF3FFF9).withValues(alpha: 0.15),
        ];
      case royalPurple:
        return [
          const Color(0xFFEDE2FF).withValues(alpha: 0.22),
          const Color(0xFFC8AEFF).withValues(alpha: 0.19),
          const Color(0xFFBFD8FF).withValues(alpha: 0.24),
          const Color(0xFFF9F3FF).withValues(alpha: 0.15),
        ];
      case arcticSilver:
        return [
          const Color(0xFFF2FAFF).withValues(alpha: 0.22),
          const Color(0xFFC6E4F6).withValues(alpha: 0.19),
          const Color(0xFFB5DDF3).withValues(alpha: 0.24),
          const Color(0xFFFFFFFF).withValues(alpha: 0.15),
        ];
    }
  }

  List<Color> get flowingBandColors {
    switch (this) {
      case oceanBlue:
        return [
          const Color(0xFF6EA8FF).withValues(alpha: 0.2),
          const Color(0xFF57C8FF).withValues(alpha: 0.24),
          const Color(0xFF8CC3FF).withValues(alpha: 0.2),
          const Color(0xFF4AB9F1).withValues(alpha: 0.24),
          const Color(0xFF9FD8FF).withValues(alpha: 0.18),
        ];
      case sunsetCoral:
        return [
          const Color(0xFFFFC79D).withValues(alpha: 0.2),
          const Color(0xFFFFA274).withValues(alpha: 0.24),
          const Color(0xFFFFD1A9).withValues(alpha: 0.2),
          const Color(0xFFFFB28B).withValues(alpha: 0.24),
          const Color(0xFFFFE1C2).withValues(alpha: 0.18),
        ];
      case forestEmerald:
        return [
          const Color(0xFF9DEFCB).withValues(alpha: 0.2),
          const Color(0xFF71E6B7).withValues(alpha: 0.24),
          const Color(0xFFB7F7D8).withValues(alpha: 0.2),
          const Color(0xFF62DFA6).withValues(alpha: 0.24),
          const Color(0xFFD2FCE8).withValues(alpha: 0.18),
        ];
      case royalPurple:
        return [
          const Color(0xFFC9B3FF).withValues(alpha: 0.2),
          const Color(0xFFB491FF).withValues(alpha: 0.24),
          const Color(0xFFD8C7FF).withValues(alpha: 0.2),
          const Color(0xFFA98BFF).withValues(alpha: 0.24),
          const Color(0xFFE7DAFF).withValues(alpha: 0.18),
        ];
      case arcticSilver:
        return [
          const Color(0xFFC3E2F4).withValues(alpha: 0.2),
          const Color(0xFF9FD0EC).withValues(alpha: 0.24),
          const Color(0xFFD2ECFA).withValues(alpha: 0.2),
          const Color(0xFF8FC8E7).withValues(alpha: 0.24),
          const Color(0xFFE8F6FF).withValues(alpha: 0.18),
        ];
    }
  }

  Alignment get accentCenterA {
    switch (this) {
      case oceanBlue:
        return const Alignment(-0.85, -0.8);
      case sunsetCoral:
        return const Alignment(0.9, -0.7);
      case forestEmerald:
        return const Alignment(-0.9, -0.5);
      case royalPurple:
        return const Alignment(0.8, -0.85);
      case arcticSilver:
        return const Alignment(-0.75, -0.9);
    }
  }

  Alignment get accentCenterB {
    switch (this) {
      case oceanBlue:
        return const Alignment(0.95, 0.85);
      case sunsetCoral:
        return const Alignment(-0.85, 0.9);
      case forestEmerald:
        return const Alignment(0.85, 0.9);
      case royalPurple:
        return const Alignment(-0.95, 0.85);
      case arcticSilver:
        return const Alignment(0.85, 0.85);
    }
  }

  Color get accentGlowA {
    switch (this) {
      case oceanBlue:
        return const Color(0xFF5FCFFF).withValues(alpha: 0.16);
      case sunsetCoral:
        return const Color(0xFFFFA36F).withValues(alpha: 0.16);
      case forestEmerald:
        return const Color(0xFF6DE3B3).withValues(alpha: 0.16);
      case royalPurple:
        return const Color(0xFFB68DFF).withValues(alpha: 0.17);
      case arcticSilver:
        return const Color(0xFFB9D9EE).withValues(alpha: 0.15);
    }
  }

  Color get accentGlowB {
    switch (this) {
      case oceanBlue:
        return const Color(0xFF84AFFF).withValues(alpha: 0.12);
      case sunsetCoral:
        return const Color(0xFFFFD37D).withValues(alpha: 0.12);
      case forestEmerald:
        return const Color(0xFF9EDDA8).withValues(alpha: 0.12);
      case royalPurple:
        return const Color(0xFF7FAEFF).withValues(alpha: 0.12);
      case arcticSilver:
        return const Color(0xFFEAF5FF).withValues(alpha: 0.12);
    }
  }

  Color get glassTintTop {
    switch (this) {
      case oceanBlue:
        return const Color(0xFFBDE9FF).withValues(alpha: 0.22);
      case sunsetCoral:
        return const Color(0xFFFFE4D0).withValues(alpha: 0.2);
      case forestEmerald:
        return const Color(0xFFD8FFE9).withValues(alpha: 0.2);
      case royalPurple:
        return const Color(0xFFE7DCFF).withValues(alpha: 0.22);
      case arcticSilver:
        return const Color(0xFFEAF6FF).withValues(alpha: 0.2);
    }
  }

  Color get glassTintMid {
    switch (this) {
      case oceanBlue:
        return const Color(0xFFFFFFFF).withValues(alpha: 0.12);
      case sunsetCoral:
        return const Color(0xFFFFF6EE).withValues(alpha: 0.12);
      case forestEmerald:
        return const Color(0xFFF2FFF8).withValues(alpha: 0.12);
      case royalPurple:
        return const Color(0xFFF7F2FF).withValues(alpha: 0.12);
      case arcticSilver:
        return const Color(0xFFFFFFFF).withValues(alpha: 0.14);
    }
  }
}
