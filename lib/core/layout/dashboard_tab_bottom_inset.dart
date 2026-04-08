import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

/// Padding bawah untuk konten scroll/tab di dalam [MainDashboardScreen].
///
/// Scaffold memakai `extendBody: true` dan dock [AnimatedNotchBottomBar] dibungkus
/// `Padding(..., bottom: [kDashboardDockShellBottomPadding] + MediaQuery.padding.bottom)`.
/// Jika layout dock diubah, sesuaikan konstanta di file ini dan [MainDashboardScreen].
const double kDashboardDockShellBottomPadding = 0;

/// Perkiraan tinggi area isi notch bar (ikon + label + margin internal paket).
/// Sedikit lebih besar dari [AppDimensions.bottomNavHeight] agar aman di berbagai font scale.
const double _kFloatingDockBodyHeight = AppDimensions.bottomNavHeight + 0;

/// Jarak ekstra antara ujung konten scroll dan atas dock.
const double _kContentGapAboveDock = 0;

/// Padding bawah aman untuk menghindari overlap dengan floating bottom dock.
double dashboardTabScrollBottomPadding(BuildContext context) {
  final systemBottom = MediaQuery.paddingOf(context).bottom;
  final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
  if (keyboardInset > 0) return 12;
  // Nilai tengah: tidak terlalu jauh, tapi tetap clear dari navbar.
  return systemBottom + 15;
}
