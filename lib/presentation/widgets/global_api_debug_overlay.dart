import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/api_config.dart';
import '../../core/routes/app_router.dart';

/// Tombol mengambang untuk panel API log: bisa di-drag, ditahan ke tepi kiri/kanan,
/// lalu menyusut jadi tab panah (seperti edge handle di beberapa launcher Android).
class GlobalApiDebugOverlay extends StatelessWidget {
  const GlobalApiDebugOverlay({super.key, required this.child});

  final Widget? child;

  void _openPanel() {
    final ctx = AppRouter.navigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      ctx.push(AppRoutes.apiLogs);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ApiConfig.enableApiLogging) {
      return child ?? const SizedBox.shrink();
    }

    return _GlobalApiDebugFabLayer(
      onOpenPanel: _openPanel,
      child: child,
    );
  }
}

enum _DockEdge { none, left, right }

class _GlobalApiDebugFabLayer extends StatefulWidget {
  const _GlobalApiDebugFabLayer({
    required this.child,
    required this.onOpenPanel,
  });

  final Widget? child;
  final VoidCallback onOpenPanel;

  @override
  State<_GlobalApiDebugFabLayer> createState() => _GlobalApiDebugFabLayerState();
}

class _GlobalApiDebugFabLayerState extends State<_GlobalApiDebugFabLayer> {
  static const double _fabSize = 52;
  static const double _tabW = 28;
  static const double _tabH = 56;
  static const double _edgeSnapPx = 40;

  double? _fabLeft;
  double? _fabTop;
  _DockEdge _dock = _DockEdge.none;
  double _edgeTop = 120;
  Size? _lastLayoutSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initIfNeeded());
  }

  void _initIfNeeded() {
    if (!mounted || _fabLeft != null) return;
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    setState(() {
      _fabLeft = size.width - _fabSize - 12;
      _fabTop = size.height - pad.bottom - 72 - _fabSize;
      _edgeTop = _clampTop(_fabTop!, size, pad);
    });
  }

  double _clampTop(double top, Size size, EdgeInsets pad) {
    final maxTop = size.height - pad.bottom - _fabSize - 8;
    final minTop = pad.top + 8;
    return top.clamp(minTop, maxTop);
  }

  double _clampTabTop(double top, Size size, EdgeInsets pad) {
    final maxTop = size.height - pad.bottom - _tabH - 8;
    final minTop = pad.top + 8;
    return top.clamp(minTop, maxTop);
  }

  void _onPanUpdate(DragUpdateDetails d, Size size, EdgeInsets pad) {
    if (_dock != _DockEdge.none) return;
    final defLeft = size.width - _fabSize - 12;
    final defTop = size.height - pad.bottom - 72 - _fabSize;
    setState(() {
      _fabLeft = (_fabLeft ?? defLeft) + d.delta.dx;
      _fabTop = (_fabTop ?? defTop) + d.delta.dy;
      _fabLeft = _fabLeft!.clamp(8.0, size.width - _fabSize - 8);
      _fabTop = _clampTop(_fabTop!, size, pad);
    });
  }

  void _snapOrLeaveFab(Size size, EdgeInsets pad) {
    if (_dock != _DockEdge.none) return;
    final defLeft = size.width - _fabSize - 12;
    final left = _fabLeft ?? defLeft;
    final defTop = size.height - pad.bottom - 72 - _fabSize;
    if (left < _edgeSnapPx) {
      setState(() {
        _dock = _DockEdge.left;
        _edgeTop = _clampTabTop(_fabTop ?? defTop, size, pad);
      });
    } else if (left > size.width - _fabSize - _edgeSnapPx) {
      setState(() {
        _dock = _DockEdge.right;
        _edgeTop = _clampTabTop(_fabTop ?? defTop, size, pad);
      });
    }
  }

  void _reclampDockedTabIfNeeded(Size size, EdgeInsets pad) {
    if (_dock == _DockEdge.none) return;
    final next = _clampTabTop(_edgeTop, size, pad);
    if (next != _edgeTop) {
      setState(() => _edgeTop = next);
    }
  }

  void _expandFromEdge(Size size, EdgeInsets pad, _DockEdge edge) {
    setState(() {
      _dock = _DockEdge.none;
      _fabTop = _clampTabTop(_edgeTop, size, pad);
      if (edge == _DockEdge.left) {
        _fabLeft = 8;
      } else {
        _fabLeft = size.width - _fabSize - 8;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final scheme = Theme.of(context).colorScheme;

    if (_lastLayoutSize != size) {
      _lastLayoutSize = size;
      if (_dock != _DockEdge.none) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _reclampDockedTabIfNeeded(size, pad);
        });
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child ?? const SizedBox.shrink(),
        if (_dock == _DockEdge.left)
          Positioned(
            left: 0,
            top: _edgeTop,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (d) {
                setState(() {
                  _edgeTop = _clampTabTop(_edgeTop + d.delta.dy, size, pad);
                });
              },
              child: _EdgePeekTab(
                width: _tabW,
                height: _tabH,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(14),
                ),
                color: scheme.primaryContainer,
                onPrimary: scheme.onPrimaryContainer,
                icon: Icons.chevron_right_rounded,
                semanticsLabel: 'Buka tombol API log',
                onTap: () => _expandFromEdge(size, pad, _DockEdge.left),
              ),
            ),
          ),
        if (_dock == _DockEdge.right)
          Positioned(
            right: 0,
            top: _edgeTop,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (d) {
                setState(() {
                  _edgeTop = _clampTabTop(_edgeTop + d.delta.dy, size, pad);
                });
              },
              child: _EdgePeekTab(
                width: _tabW,
                height: _tabH,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
                color: scheme.primaryContainer,
                onPrimary: scheme.onPrimaryContainer,
                icon: Icons.chevron_left_rounded,
                semanticsLabel: 'Buka tombol API log',
                onTap: () => _expandFromEdge(size, pad, _DockEdge.right),
              ),
            ),
          ),
        if (_dock == _DockEdge.none)
          Positioned(
            left: _fabLeft ?? (size.width - _fabSize - 12),
            top: _fabTop ?? (size.height - pad.bottom - 72 - _fabSize),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (d) => _onPanUpdate(d, size, pad),
              onPanEnd: (_) => _snapOrLeaveFab(size, pad),
              onPanCancel: () => _snapOrLeaveFab(size, pad),
              child: Material(
                elevation: 6,
                shadowColor: Colors.black26,
                shape: const CircleBorder(),
                color: scheme.primaryContainer,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: widget.onOpenPanel,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: _fabSize,
                    height: _fabSize,
                    child: Icon(
                      Icons.bug_report_rounded,
                      size: 24,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EdgePeekTab extends StatelessWidget {
  const _EdgePeekTab({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.color,
    required this.onPrimary,
    required this.icon,
    required this.semanticsLabel,
    required this.onTap,
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Color color;
  final Color onPrimary;
  final IconData icon;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Hindari Tooltip di tepi layar: overlay portal sering bentrok dengan
    // gesture / safe area dan memicu error assertion pada overlay.
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: Material(
        elevation: 4,
        color: color,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: width,
            height: height,
            child: Icon(icon, size: 22, color: onPrimary),
          ),
        ),
      ),
    );
  }
}
