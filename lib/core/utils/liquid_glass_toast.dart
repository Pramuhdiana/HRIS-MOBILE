import 'dart:ui';

import 'package:flutter/material.dart';

enum LiquidToastType { success, error, warning, info }

/// Toast bergaya liquid glass: turun dari atas + skala “tetes” (iOS-like).
class LiquidGlassToast {
  LiquidGlassToast._();

  static OverlayEntry? _entry;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required LiquidToastType type,
    Duration displayDuration = const Duration(milliseconds: 3600),
  }) {
    dismiss();
    final overlayState = Overlay.maybeOf(context, rootOverlay: true);
    if (overlayState == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _LiquidGlassToastLayer(
        title: title,
        message: message,
        type: type,
        displayDuration: displayDuration,
        onDispose: () {
          entry.remove();
          if (_entry == entry) _entry = null;
        },
      ),
    );
    _entry = entry;
    overlayState.insert(entry);
  }

  static void dismiss() {
    _entry?.remove();
    _entry = null;
  }
}

class _LiquidGlassToastLayer extends StatefulWidget {
  const _LiquidGlassToastLayer({
    required this.title,
    required this.message,
    required this.type,
    required this.displayDuration,
    required this.onDispose,
  });

  final String title;
  final String message;
  final LiquidToastType type;
  final Duration displayDuration;
  final VoidCallback onDispose;

  @override
  State<_LiquidGlassToastLayer> createState() => _LiquidGlassToastLayerState();
}

class _LiquidGlassToastLayerState extends State<_LiquidGlassToastLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _slide;
  late Animation<double> _scaleY;
  late Animation<double> _scaleX;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      duration: const Duration(milliseconds: 580),
      vsync: this,
    );
    _slide = CurvedAnimation(
      parent: _c,
      curve: const Interval(0, 0.92, curve: Curves.easeOutCubic),
    );
    _fade = CurvedAnimation(
      parent: _c,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
    );
    // Sedikit “nenang” vertikal di awal seperti tetes mengenai permukaan
    _scaleY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.72, end: 1.08).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 45,
      ),
    ]).animate(_c);
    _scaleX = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.04).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.04, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 45,
      ),
    ]).animate(_c);

    _c.forward();

    Future<void>.delayed(widget.displayDuration, () {
      if (!mounted) return;
      _close();
    });
  }

  Future<void> _close() async {
    if (!mounted) return;
    await _c.reverse();
    if (!mounted) return;
    widget.onDispose();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final accent = _accentForType(widget.type);
    final icon = _iconForType(widget.type);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: pad.top + 10,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, child) {
                final t = _slide.value;
                final dy = (1 - t) * -72;
                return Opacity(
                  opacity: _fade.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, dy),
                    child: Transform(
                      alignment: Alignment.topCenter,
                      transform: Matrix4.diagonal3Values(
                        _scaleX.value,
                        _scaleY.value,
                        1,
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              child: GestureDetector(
                onTap: _close,
                child: _GlassToastCard(
                  accent: accent,
                  icon: icon,
                  title: widget.title,
                  message: widget.message,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _accentForType(LiquidToastType type) {
    switch (type) {
      case LiquidToastType.success:
        return const Color(0xFF34C759);
      case LiquidToastType.error:
        return const Color(0xFFFF453A);
      case LiquidToastType.warning:
        return const Color(0xFFFF9F0A);
      case LiquidToastType.info:
        return const Color(0xFF0A84FF);
    }
  }

  IconData _iconForType(LiquidToastType type) {
    switch (type) {
      case LiquidToastType.success:
        return Icons.check_circle_rounded;
      case LiquidToastType.error:
        return Icons.error_rounded;
      case LiquidToastType.warning:
        return Icons.warning_rounded;
      case LiquidToastType.info:
        return Icons.info_rounded;
    }
  }
}

class _GlassToastCard extends StatelessWidget {
  const _GlassToastCard({
    required this.accent,
    required this.icon,
    required this.title,
    required this.message,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.38),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.34),
                Colors.white.withValues(alpha: 0.14),
                accent.withValues(alpha: 0.12),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 14),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: accent.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -8,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          height: 1.25,
                          shadows: [
                            Shadow(
                              color: Color(0x33000000),
                              blurRadius: 8,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      if (message.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
