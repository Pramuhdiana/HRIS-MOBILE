import 'dart:developer';

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';

class LiquidBottomNavItem {
  const LiquidBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class LiquidGlassBottomNav extends StatefulWidget {
  const LiquidGlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<LiquidBottomNavItem> items;

  @override
  State<LiquidGlassBottomNav> createState() => _LiquidGlassBottomNavState();
}

class _LiquidGlassBottomNavState extends State<LiquidGlassBottomNav> {
  late final NotchBottomBarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotchBottomBarController(index: widget.currentIndex);
  }

  @override
  void didUpdateWidget(covariant LiquidGlassBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _controller.jumpTo(widget.currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.items.length >= 2 && widget.items.length <= 5, 'Tabs must be 2..5 items');
    assert(widget.currentIndex >= 0 && widget.currentIndex < widget.items.length);

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const barWidth = 500.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 8 + bottomInset),
      child: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: Colors.white,
        showLabel: true,
        textOverflow: TextOverflow.visible,
        maxLine: 1,
        shadowElevation: 5,
        kBottomRadius: 28.0,
        notchColor: Colors.black87,
        removeMargins: false,
        bottomBarWidth: barWidth,
        showShadow: false,
        durationInMilliSeconds: 300,
        itemLabelStyle: const TextStyle(fontSize: 10),
        elevation: 1,
        bottomBarItems: [
          for (int i = 0; i < widget.items.length; i++)
            BottomBarItem(
              inActiveItem: Icon(widget.items[i].icon, color: Colors.blueGrey),
              activeItem: Icon(
                widget.items[i].activeIcon,
                color: switch (i) {
                  2 => Colors.pink,
                  3 => Colors.yellow,
                  _ => Colors.blueAccent,
                },
              ),
              itemLabel: widget.items[i].label,
            ),
        ],
        onTap: (index) {
          log('current selected index $index');
          widget.onTap(index);
        },
        kIconSize: 24.0,
      ),
    );
  }
}
