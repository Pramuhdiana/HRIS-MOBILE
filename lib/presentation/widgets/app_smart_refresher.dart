import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../core/constants/app_colors.dart';

/// Shared pull-to-refresh wrapper so all screens use the same behavior/style.
class AppSmartRefresher extends StatelessWidget {
  const AppSmartRefresher({
    super.key,
    required this.controller,
    required this.child,
    required this.onRefresh,
    this.onLoading,
    this.scrollController,
    this.enablePullDown = true,
    this.enablePullUp = false,
    this.physics = const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    ),
    this.header,
    this.footer,
  });

  final RefreshController controller;
  final Widget child;
  final VoidCallback onRefresh;
  final VoidCallback? onLoading;
  final ScrollController? scrollController;
  final bool enablePullDown;
  final bool enablePullUp;
  final ScrollPhysics physics;
  final Widget? header;
  final Widget? footer;

  static const WaterDropMaterialHeader _defaultHeader = WaterDropMaterialHeader(
    backgroundColor: AppColors.primary,
    color: Colors.white,
    distance: 60,
  );

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: controller,
      enablePullDown: enablePullDown,
      enablePullUp: enablePullUp,
      scrollController: scrollController,
      physics: physics,
      header: header ?? _defaultHeader,
      footer: footer,
      onRefresh: onRefresh,
      onLoading: onLoading,
      child: child,
    );
  }
}
