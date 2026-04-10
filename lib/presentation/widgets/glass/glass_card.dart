import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'water_glass_ripple.dart';

/// iOS-style [GlassCard]: blur backdrop, water ripple, shimmer, dan 3D touch di titik sentuh.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.blurSigma = 22,
    this.enableBackdropBlur = true,
    this.disabledBackdropBlurSigma = 2.5,
    this.overlayTopOpacity = 0.008,
    this.overlayBottomOpacity = 0.0,
    this.borderWidth = 2,
    this.borderOpacity = 0.16,
    this.shadowOpacity = 0.038,
    this.splashColor,
    this.highlightColor,
    this.splashRadius = 200,
    this.liquidHaptics = true,
    this.pressScale = 0.964,
    this.pressSlidePixels = 7,
    this.pressSkew = 0.022,
    this.pressTilt = 0.11,
    this.pressPerspectiveZ = 0.00095,
    this.enableWaterRipple = true,
    this.enableShimmer = true,
    this.waterRippleColor,
    this.waterRippleDuration = const Duration(milliseconds: 1400),
    this.pressForwardDuration = const Duration(milliseconds: 165),
    this.pressReverseDuration = const Duration(milliseconds: 580),
  }) : assert(!enableBackdropBlur || (blurSigma >= 8 && blurSigma <= 30)),
       assert(disabledBackdropBlurSigma >= 0 && disabledBackdropBlurSigma <= 8),
       assert(borderWidth >= 1 && borderWidth <= 3),
       assert(overlayTopOpacity <= 0.06),
       assert(overlayBottomOpacity <= 0.06),
       assert(pressScale >= 0.82 && pressScale < 1.0),
       assert(pressSlidePixels >= 0 && pressSlidePixels <= 14),
       assert(pressTilt >= 0 && pressTilt <= 0.22),
       assert(pressPerspectiveZ >= 0 && pressPerspectiveZ <= 0.003);

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double blurSigma;
  final bool enableBackdropBlur;
  final double disabledBackdropBlurSigma;
  final double overlayTopOpacity;
  final double overlayBottomOpacity;
  final double borderWidth;
  final double borderOpacity;
  final double shadowOpacity;

  /// Riak Material; default **tanpa splash** ([NoSplash]). Set jika perlu riak berwarna.
  final Color? splashColor;
  final Color? highlightColor;
  final double splashRadius;
  final bool liquidHaptics;
  final double pressScale;
  final double pressSlidePixels;
  final double pressSkew;
  final double pressTilt;
  final double pressPerspectiveZ;
  final bool enableWaterRipple;
  final bool enableShimmer;
  final Color? waterRippleColor;
  final Duration waterRippleDuration;
  final Duration pressForwardDuration;
  final Duration pressReverseDuration;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with TickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final AnimationController _shimmerCtrl;
  late Animation<double> _scaleAnim;

  final List<WaterRipple> _ripples = [];
  Alignment _focal = Alignment.center;
  Offset? _lastTouchPosition;
  bool _pressActive = false;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: widget.pressForwardDuration,
      reverseDuration: widget.pressReverseDuration,
    );
    _scaleAnim = _buildScaleAnim();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    );

    if (widget.enableShimmer) {
      _shimmerCtrl.repeat();
    }
  }

  Animation<double> _buildScaleAnim() {
    return Tween<double>(begin: 1.0, end: widget.pressScale).animate(
      CurvedAnimation(
        parent: _pressCtrl,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant GlassCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pressScale != widget.pressScale) {
      _scaleAnim = _buildScaleAnim();
    }
    if (oldWidget.pressForwardDuration != widget.pressForwardDuration) {
      _pressCtrl.duration = widget.pressForwardDuration;
    }
    if (oldWidget.pressReverseDuration != widget.pressReverseDuration) {
      _pressCtrl.reverseDuration = widget.pressReverseDuration;
    }
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _setFocalFromLocal(Offset local, BoxConstraints c) {
    final w = c.maxWidth;
    final h = c.maxHeight;
    if (w <= 0 || h <= 0) return;
    final x = local.dx.clamp(0.0, w);
    final y = local.dy.clamp(0.0, h);
    final nx = (x / w).clamp(0.001, 0.999);
    final ny = (y / h).clamp(0.001, 0.999);
    setState(() {
      _focal = Alignment(nx * 2 - 1, ny * 2 - 1);
      _lastTouchPosition = Offset(x, y);
    });
  }

  void _createWaterRipple(Offset position) {
    if (!widget.enableWaterRipple) return;

    final controller = AnimationController(
      vsync: this,
      duration: widget.waterRippleDuration,
    );

    final ripple = WaterRipple(
      position: position,
      controller: controller,
      color: widget.waterRippleColor ?? Colors.white.withValues(alpha: 0.48),
    );

    setState(() {
      _ripples.add(ripple);
    });

    controller.forward().then((_) {
      if (!mounted) return;
      setState(() {
        _ripples.remove(ripple);
      });
      controller.dispose();
    });
  }

  void _onPointerDown(PointerDownEvent e, BoxConstraints c) {
    if (widget.onTap == null) return;
    _pressActive = true;
    _setFocalFromLocal(e.localPosition, c);
    _pressCtrl.forward();
    _createWaterRipple(e.localPosition);
  }

  void _onPointerMove(PointerMoveEvent e, BoxConstraints c) {
    if (widget.onTap == null || !_pressActive) return;
    _setFocalFromLocal(e.localPosition, c);
  }

  void _releasePress() {
    if (widget.onTap == null) return;
    _pressActive = false;
    _pressCtrl.reverse();
  }

  Matrix4 _pressTiltMatrix(double depth) {
    if (widget.pressTilt <= 0 || widget.pressPerspectiveZ <= 0) {
      return Matrix4.identity();
    }
    final t = widget.pressTilt * depth;
    final m = Matrix4.identity()..setEntry(3, 2, widget.pressPerspectiveZ);
    m.rotateY(-t * _focal.x);
    m.rotateX(-t * _focal.y);
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(widget.borderRadius);
    final pressHue = widget.splashColor != null
        ? widget.splashColor!.withValues(alpha: 1)
        : Colors.white;
    final inkHighlight = widget.highlightColor ?? Colors.transparent;
    final useCustomSplash = widget.splashColor != null;
    final effectiveBackdropSigma = widget.enableBackdropBlur
        ? widget.blurSigma
        : widget.disabledBackdropBlurSigma;

    final glassBody = ClipRRect(
      borderRadius: r,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (effectiveBackdropSigma > 0)
            Positioned.fill(
              child: BackdropFilter(
                blendMode: BlendMode.src,
                filter: ImageFilter.blur(
                  sigmaX: effectiveBackdropSigma,
                  sigmaY: effectiveBackdropSigma,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: widget.borderWidth,
                    color: Colors.white.withValues(
                      alpha: widget.borderOpacity.clamp(0.08, 0.28),
                    ),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(
                        alpha: widget.overlayTopOpacity * 0.42,
                      ),
                      Colors.white.withValues(
                        alpha:
                            widget.overlayTopOpacity * 0.2 +
                            widget.overlayBottomOpacity * 0.45,
                      ),
                      Colors.white.withValues(
                        alpha: widget.overlayBottomOpacity * 0.6,
                      ),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),
          if (widget.enableShimmer)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _shimmerCtrl,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        (_shimmerCtrl.value * 2 - 1) * 200,
                        (_shimmerCtrl.value * 2 - 1) * 200,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(
                                alpha: _isHovering ? 0.15 : 0.05,
                              ),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ...List.generate(_ripples.length, (index) {
            final ripple = _ripples[index];
            return Positioned(
              left: ripple.position.dx,
              top: ripple.position.dy,
              child: WaterRippleWidget(ripple: ripple),
            );
          }),
          if (_pressActive && _lastTouchPosition != null)
            Positioned(
              left: _lastTouchPosition!.dx,
              top: _lastTouchPosition!.dy,
              child: AnimatedBuilder(
                animation: _pressCtrl,
                builder: (context, child) {
                  final depth =
                      ((1.0 - _scaleAnim.value) / (1.0 - widget.pressScale))
                          .clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(-50 + (depth * 10), -50 + (depth * 10)),
                    child: Container(
                      width: 100 - (depth * 20),
                      height: 100 - (depth * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            pressHue.withValues(alpha: 0.30 * depth),
                            pressHue.withValues(alpha: 0.11 * depth),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(padding: widget.padding, child: widget.child),
        ],
      ),
    );

    final interactive = widget.onTap != null
        ? Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: r),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                if (widget.liquidHaptics) {
                  HapticFeedback.lightImpact();
                }
                widget.onTap!();
              },
              onHover: (hovering) {
                setState(() {
                  _isHovering = hovering;
                });
              },
              borderRadius: r,
              splashColor: widget.splashColor ?? Colors.transparent,
              highlightColor: inkHighlight,
              splashFactory: useCustomSplash
                  ? InkRipple.splashFactory
                  : NoSplash.splashFactory,
              radius: widget.splashRadius,
              child: glassBody,
            ),
          )
        : glassBody;

    final body = Container(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.shadowOpacity),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -6,
          ),
        ],
      ),
      child: interactive,
    );

    if (widget.onTap == null) {
      return body;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _scaleAnim,
          builder: (context, child) {
            final s = _scaleAnim.value.clamp(widget.pressScale, 1.08);
            final denom = (1.0 - widget.pressScale).clamp(0.001, 1.0);
            final depth = ((1.0 - s) / denom).clamp(0.0, 1.35);
            final slide =
                Offset(_focal.x, _focal.y) * widget.pressSlidePixels * depth;

            final k = widget.pressSkew * depth;
            final shearMatrix = Matrix4.identity()
              ..setEntry(0, 1, k * _focal.y)
              ..setEntry(1, 0, -k * _focal.x);

            final tiltMatrix = _pressTiltMatrix(depth);

            return Transform.translate(
              offset: slide,
              child: Transform(
                alignment: _focal,
                transform: tiltMatrix,
                child: Transform(
                  alignment: _focal,
                  transform: shearMatrix,
                  child: Transform.scale(
                    scale: s,
                    alignment: _focal,
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (e) => _onPointerDown(e, constraints),
            onPointerMove: (e) => _onPointerMove(e, constraints),
            onPointerUp: (_) => _releasePress(),
            onPointerCancel: (_) => _releasePress(),
            child: body,
          ),
        );
      },
    );
  }
}
