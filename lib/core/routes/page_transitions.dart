import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';

/// Page Transitions Helper
/// Reusable page transitions for go_router using page_transition package
class PageTransitions {
  /// Fade transition
  static Page<dynamic> fade({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return _buildPageTransition(
      state: state,
      child: child,
      type: PageTransitionType.fade,
      duration: duration,
    );
  }

  /// Slide transition (from right)
  static Page<dynamic> slide({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return _buildPageTransition(
      state: state,
      child: child,
      type: PageTransitionType.rightToLeft,
      duration: duration,
    );
  }

  /// Slide transition (from left)
  static Page<dynamic> slideLeft({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return _buildPageTransition(
      state: state,
      child: child,
      type: PageTransitionType.leftToRight,
      duration: duration,
    );
  }

  /// Scale transition
  static Page<dynamic> scale({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return _buildPageTransition(
      state: state,
      child: child,
      type: PageTransitionType.scale,
      duration: duration,
      alignment: Alignment.center,
    );
  }

  /// Rotate transition
  static Page<dynamic> rotate({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return _buildPageTransition(
      state: state,
      child: child,
      type: PageTransitionType.rotate,
      duration: duration,
      alignment: Alignment.center,
    );
  }

  /// Combined fade and slide transition (top to bottom)
  static Page<dynamic> fadeSlide({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return _buildPageTransition(
      state: state,
      child: child,
      type: PageTransitionType.topToBottom,
      duration: duration,
    );
  }

  /// Combined fade and scale transition
  static Page<dynamic> fadeScale({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return _buildPageTransition(
      state: state,
      child: child,
      type: PageTransitionType.scale,
      duration: duration,
      alignment: Alignment.center,
    );
  }

  /// Top to bottom slide
  static Page<dynamic> topToBottom({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return _buildPageTransition(
      state: state,
      child: child,
      type: PageTransitionType.topToBottom,
      duration: duration,
    );
  }

  /// Bottom to top slide
  static Page<dynamic> bottomToTop({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return _buildPageTransition(
      state: state,
      child: child,
      type: PageTransitionType.bottomToTop,
      duration: duration,
    );
  }

  /// Left to right with fade
  static Page<dynamic> leftToRightWithFade({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return _buildPageTransition(
      state: state,
      child: child,
      type: PageTransitionType.leftToRightWithFade,
      duration: duration,
    );
  }

  /// Right to left with fade
  static Page<dynamic> rightToLeftWithFade({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return _buildPageTransition(
      state: state,
      child: child,
      type: PageTransitionType.rightToLeftWithFade,
      duration: duration,
    );
  }

  /// Internal helper to build page transition using page_transition package
  static Page<dynamic> _buildPageTransition({
    required GoRouterState state,
    required Widget child,
    required PageTransitionType type,
    required Duration duration,
    Alignment? alignment,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Create a dummy PageTransition route to extract its transition logic
        // We'll use the PageTransition's buildTransitions method
        final dummyRoute = PageTransition(
          child: child,
          type: type,
          duration: duration,
          reverseDuration: duration,
          alignment: alignment ?? Alignment.center,
        );

        // Use the PageTransition's buildTransitions method
        return dummyRoute.buildTransitions(
          context,
          animation,
          secondaryAnimation,
          child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// No transition (instant)
  static Page<dynamic> none({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return NoTransitionPage(key: state.pageKey, child: child);
  }
}
