import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../core/constants/app_colors.dart';

/// Global pull-to-refresh defaults for the whole app.
class AppRefreshConfiguration extends StatelessWidget {
  const AppRefreshConfiguration({super.key, required this.child});

  final Widget child;

  static const double headerTriggerDistance = 80;
  static const double maxOverScrollExtent = 120;
  static const double dragSpeedRatio = 1.15;
  static const double footerTriggerDistance = 30;

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      headerTriggerDistance: headerTriggerDistance,
      maxOverScrollExtent: maxOverScrollExtent,
      dragSpeedRatio: dragSpeedRatio,
      headerBuilder: () => const WaterDropMaterialHeader(
        backgroundColor: AppColors.primary,
        color: Color(0xFFFFFFFF),
        distance: 60,
      ),
      footerTriggerDistance: footerTriggerDistance,
      child: child,
    );
  }
}
