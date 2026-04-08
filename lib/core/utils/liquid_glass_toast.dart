import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

enum LiquidToastType { success, error, warning, info }

class _ToastSlot {
  _ToastSlot({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
  });

  final String id;
  final LiquidToastType type;
  final String title;
  final String message;
  int count = 1;

  String get coalesceKey => '${type.index}|$title|$message';
}

double _layoutTop(
  List<_ToastSlot> slots,
  _ToastSlot slot,
  Set<String> exitingIds,
) {
  final isExiting = exitingIds.contains(slot.id);
  if (isExiting) {
    final idx = slots.indexOf(slot);
    return idx * 14.0;
  }
  final nonExiting = <_ToastSlot>[
    for (final s in slots)
      if (!exitingIds.contains(s.id)) s,
  ];
  final c = nonExiting.indexOf(slot);
  return (c >= 0 ? c : 0) * 14.0;
}

String? _frontInteractiveId(List<_ToastSlot> slots, Set<String> exitingIds) {
  for (final s in slots) {
    if (!exitingIds.contains(s.id)) return s.id;
  }
  return null;
}

/// Toast bergaya liquid glass: turun dari atas + skala “tetes” (iOS-like).
/// Smart stack: isi sama digabung; isi beda ditumpuk. Keluar dengan animasi
/// (geser ke atas + fade); kartu lain [AnimatedPositioned] mengisi baris tanpa loncat.
class LiquidGlassToast {
  LiquidGlassToast._();

  static const int _maxStack = 3;
  static const Duration _moveDuration = Duration(milliseconds: 420);
  static const Duration _exitDuration = Duration(milliseconds: 400);

  static OverlayEntry? _entry;
  static final ValueNotifier<List<_ToastSlot>> _notifier =
      ValueNotifier<List<_ToastSlot>>([]);
  static final Map<String, Timer> _timers = {};
  static final Set<String> _exitingIds = {};
  static final Set<String> _dropInSeenIds = {};
  static int _exitToken = 0;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required LiquidToastType type,
    Duration displayDuration = const Duration(milliseconds: 3600),
  }) {
    final overlayState = Overlay.maybeOf(context, rootOverlay: true);
    if (overlayState == null) return;

    final key = '${type.index}|$title|$message';
    final list = List<_ToastSlot>.from(_notifier.value);

    if (list.isNotEmpty && list.first.coalesceKey == key) {
      list.first.count++;
      _notifier.value = list;
      _scheduleDismiss(list.first.id, displayDuration);
      return;
    }

    final id = '${DateTime.now().microsecondsSinceEpoch}';
    list.insert(
      0,
      _ToastSlot(id: id, type: type, title: title, message: message),
    );
    while (list.length > _maxStack) {
      final removed = list.removeLast();
      _timers[removed.id]?.cancel();
      _timers.remove(removed.id);
      _dropInSeenIds.remove(removed.id);
    }
    _notifier.value = list;
    _scheduleDismiss(id, displayDuration);
    _ensureOverlay(overlayState);
  }

  static void _ensureOverlay(OverlayState overlayState) {
    if (_entry != null) return;
    _entry = OverlayEntry(
      builder: (ctx) {
        return ValueListenableBuilder<List<_ToastSlot>>(
          valueListenable: _notifier,
          builder: (context, slots, _) {
            if (slots.isEmpty) return const SizedBox.shrink();
            return _ToastStackLayer(
              slots: slots,
              exitingIds: _exitingIds,
              onDismissSlot: _beginExitAnimation,
            );
          },
        );
      },
    );
    overlayState.insert(_entry!);
  }

  static void _scheduleDismiss(String id, Duration displayDuration) {
    _timers[id]?.cancel();
    _timers[id] = Timer(displayDuration, () {
      _timers.remove(id);
      _beginExitAnimation(id);
    });
  }

  /// Mulai animasi hilang; setelah [_exitDuration] baru hapus dari daftar.
  static void _beginExitAnimation(String id) {
    if (!_notifier.value.any((e) => e.id == id)) return;
    if (_exitingIds.contains(id)) return;
    _exitingIds.add(id);
    _notifier.value = List<_ToastSlot>.from(_notifier.value);

    final token = _exitToken;
    Future<void>.delayed(_exitDuration, () {
      if (token != _exitToken) return;
      _exitingIds.remove(id);
      _removeSlot(id);
    });
  }

  static void _removeSlot(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
    _dropInSeenIds.remove(id);
    final list = List<_ToastSlot>.from(_notifier.value);
    list.removeWhere((e) => e.id == id);
    _notifier.value = list;
    if (list.isEmpty) {
      _entry?.remove();
      _entry = null;
    }
  }

  static void dismiss() {
    _exitToken++;
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    _exitingIds.clear();
    _dropInSeenIds.clear();
    _notifier.value = [];
    _entry?.remove();
    _entry = null;
  }
}

class _ToastStackLayer extends StatelessWidget {
  const _ToastStackLayer({
    required this.slots,
    required this.exitingIds,
    required this.onDismissSlot,
  });

  final List<_ToastSlot> slots;
  final Set<String> exitingIds;
  final void Function(String id) onDismissSlot;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    const cardRegionHeight = 130.0;
    final stackHeight = cardRegionHeight + (slots.length - 1) * 14.0;
    final frontId = _frontInteractiveId(slots, exitingIds);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 16,
            right: 16,
            top: pad.top + 10,
            child: SizedBox(
              height: stackHeight,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  for (final slot in slots.reversed)
                    AnimatedPositioned(
                      key: ValueKey<String>(slot.id),
                      duration: LiquidGlassToast._moveDuration,
                      curve: Curves.easeOutCubic,
                      top: _layoutTop(slots, slot, exitingIds),
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        ignoring: slot.id != frontId,
                        child: _StackToastItem(
                          slot: slot,
                          slots: slots,
                          exitingIds: exitingIds,
                          onTap: () => onDismissSlot(slot.id),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StackToastItem extends StatelessWidget {
  const _StackToastItem({
    required this.slot,
    required this.slots,
    required this.exitingIds,
    required this.onTap,
  });

  final _ToastSlot slot;
  final List<_ToastSlot> slots;
  final Set<String> exitingIds;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForType(slot.type);
    final icon = _iconForType(slot.type);
    final title = slot.count > 1 ? '${slot.title}  ×${slot.count}' : slot.title;

    Widget card = _GlassToastCard(
      accent: accent,
      icon: icon,
      title: title,
      message: slot.message,
    );

    card = GestureDetector(
      onTap: onTap,
      child: card,
    );

    if (exitingIds.contains(slot.id)) {
      card = _ExitSlideWrapper(child: card);
    } else {
      final compact = <_ToastSlot>[
        for (final s in slots)
          if (!exitingIds.contains(s.id)) s,
      ].indexOf(slot);
      if (compact == 0) {
        card = _DropInToastWrapper(
          slotId: slot.id,
          child: card,
        );
      } else {
        final depth = compact.toDouble();
        card = Transform.scale(
          scale: (1.0 - depth * 0.035).clamp(0.88, 1.0),
          alignment: Alignment.topCenter,
          child: Opacity(
            opacity: (1.0 - depth * 0.12).clamp(0.55, 1.0),
            child: card,
          ),
        );
      }
    }

    return card;
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

/// Geser ke atas + fade saat menghilang (bukan hilang tiba-tiba).
class _ExitSlideWrapper extends StatefulWidget {
  const _ExitSlideWrapper({required this.child});

  final Widget child;

  @override
  State<_ExitSlideWrapper> createState() => _ExitSlideWrapperState();
}

class _ExitSlideWrapperState extends State<_ExitSlideWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      duration: LiquidGlassToast._exitDuration,
      vsync: this,
    );
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeInCubic);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return Opacity(
          opacity: Tween<double>(begin: 1, end: 0).evaluate(curved).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, Tween<double>(begin: 0, end: -56).evaluate(curved)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _DropInToastWrapper extends StatefulWidget {
  const _DropInToastWrapper({
    required this.child,
    required this.slotId,
  });

  final Widget child;
  final String slotId;

  @override
  State<_DropInToastWrapper> createState() => _DropInToastWrapperState();
}

class _DropInToastWrapperState extends State<_DropInToastWrapper>
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

    final skip = LiquidGlassToast._dropInSeenIds.contains(widget.slotId);
    if (skip) {
      _c.value = 1;
    } else {
      LiquidGlassToast._dropInSeenIds.add(widget.slotId);
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
      child: widget.child,
    );
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
