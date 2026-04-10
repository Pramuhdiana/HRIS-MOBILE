import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/layout/dashboard_tab_bottom_inset.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../data/providers/mock_data_provider.dart';
import '../../providers/profile_api_provider.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/attendance_card.dart';
import '../../widgets/app_smart_refresher.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/dashboard_glass_style.dart';
import '../../widgets/liquid_glass_scaffold.dart';

const _glassOnPrimary = Color(0xFF0F2741);
const _glassOnSecondary = Color(0xFF2E4C6B);
const _glassIconColor = Color(0xFF123459);

/// Home Tab - Main dashboard with overview information
/// Based on POS Mobile Figma Template design
class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  late final RefreshController _refreshController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(profileApiProvider);
    try {
      await ref.read(profileApiProvider.future);
      if (mounted) _refreshController.refreshCompleted();
    } catch (_) {
      if (mounted) _refreshController.refreshFailed();
    }
  }

  String _initialsFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final first = parts.first;
      return first.length >= 2
          ? first.substring(0, 2).toUpperCase()
          : first.toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final employee = MockDataProvider.sampleEmployee;
    final profile = ref.watch(profileApiProvider).valueOrNull;
    final dashboardStats = MockDataProvider.dashboardStats;
    final currentAttendance = MockDataProvider.sampleAttendanceRecords.first;
    final topInset = MediaQuery.paddingOf(context).top;
    final greetingName = (profile?.name?.trim().isNotEmpty ?? false)
        ? profile!.name!.trim()
        : employee.firstName;
    final greetingTitle = <String>[
      if (profile?.position?.trim().isNotEmpty ?? false)
        profile!.position!.trim()
      else
        employee.position,
      if (profile?.department?.trim().isNotEmpty ?? false)
        profile!.department!.trim()
      else
        employee.department,
    ].join(' • ');
    final avatarUrl = profile?.photoUrl?.trim();
    final avatarInitials = _initialsFromName(
      (profile?.name?.trim().isNotEmpty ?? false)
          ? profile!.name!.trim()
          : employee.fullName,
    );

    return LiquidGlassScaffold(
      body: AppSmartRefresher(
        controller: _refreshController,
        scrollController: _scrollController,
        enablePullUp: false,
        header: const WaterDropMaterialHeader(
          backgroundColor: AppColors.primary,
          color: Colors.white,
          distance: 60,
        ),
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          primary: false,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: dashboardTabScrollBottomPadding(context),
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppDimensions.paddingL,
                        topInset + AppDimensions.paddingM,
                        AppDimensions.paddingL,
                        0,
                      ),
                      child: GlassCard(
                        borderRadius: AppDimensions.cardRadius,
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        blurSigma: DashboardGlassStyle.blurSigma,
                        enableBackdropBlur: false,
                        disabledBackdropBlurSigma: 2.5,
                        borderWidth: DashboardGlassStyle.borderWidth,
                        borderOpacity: DashboardGlassStyle.borderOpacity,
                        overlayTopOpacity:
                            DashboardGlassStyle.overlayTopOpacity,
                        overlayBottomOpacity:
                            DashboardGlassStyle.overlayBottomOpacity,
                        shadowOpacity: DashboardGlassStyle.shadowOpacity,
                        enableWaterRipple: true,
                        enableShimmer: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${AppStrings.welcome},',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: _glassOnSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      greetingName,
                                      style: AppTypography.h4.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _glassOnPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: Stack(
                                        children: [
                                          Icon(
                                            Icons.notifications_outlined,
                                            size: AppDimensions.iconL,
                                            color: _glassIconColor,
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: const BoxDecoration(
                                                color: AppColors.error,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '3',
                                                  style: AppTypography.caption
                                                      .copyWith(
                                                        color: AppColors
                                                            .textOnPrimary,
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: AppDimensions.avatarM,
                                      height: AppDimensions.avatarM,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.46,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.18,
                                          ),
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child:
                                          avatarUrl != null &&
                                              avatarUrl.isNotEmpty
                                          ? Image.network(
                                              avatarUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Center(
                                                    child: Text(
                                                      avatarInitials,
                                                      style: AppTypography
                                                          .labelLarge
                                                          .copyWith(
                                                            color: _glassOnPrimary,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ),
                                            )
                                          : Center(
                                              child: Text(
                                                avatarInitials,
                                                style: AppTypography.labelLarge
                                                    .copyWith(
                                                      color: _glassOnPrimary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.paddingM),
                            Text(
                              greetingTitle,
                              style: AppTypography.bodySmall.copyWith(
                                color: _glassOnSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingL),

                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppDimensions.paddingL,
                        0,
                        AppDimensions.paddingL,
                        0,
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: AppTypography.h6.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _glassOnPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          GlassCard(
                            borderRadius: AppDimensions.cardRadius,
                            padding: const EdgeInsets.all(
                              AppDimensions.paddingL,
                            ),
                            blurSigma: DashboardGlassStyle.blurSigma,
                            enableBackdropBlur: false,
                            disabledBackdropBlurSigma: 2.5,
                            borderWidth: DashboardGlassStyle.borderWidth,
                            borderOpacity: DashboardGlassStyle.borderOpacity,
                            overlayTopOpacity:
                                DashboardGlassStyle.overlayTopOpacity,
                            overlayBottomOpacity:
                                DashboardGlassStyle.overlayBottomOpacity,
                            shadowOpacity: DashboardGlassStyle.shadowOpacity,
                            enableWaterRipple: true,
                            enableShimmer: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [const _DashboardIconScrollGrid()],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Today's Attendance Card
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: AttendanceCard(attendance: currentAttendance),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Dashboard Statistics
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This Month Overview',
                            style: AppTypography.h6.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _glassOnPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          Row(
                            children: [
                              Expanded(
                                child: DashboardCard(
                                  title: 'Present Days',
                                  value: dashboardStats['thisMonthPresentDays']
                                      .toString(),
                                  icon: Icons.check_circle,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingM),
                              Expanded(
                                child: DashboardCard(
                                  title: 'Absent Days',
                                  value: dashboardStats['thisMonthAbsentDays']
                                      .toString(),
                                  icon: Icons.cancel,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          Row(
                            children: [
                              Expanded(
                                child: DashboardCard(
                                  title: 'Late Days',
                                  value: dashboardStats['thisMonthLateDays']
                                      .toString(),
                                  icon: Icons.schedule,
                                  color: AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingM),
                              Expanded(
                                child: DashboardCard(
                                  title: 'Overtime Hours',
                                  value: '${dashboardStats['overtimeHours']}h',
                                  icon: Icons.timer,
                                  color: AppColors.info,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => context.push(AppRoutes.glassDemo),
                          icon: const Icon(Icons.blur_on_outlined),
                          label: const Text('Demo iOS glass (GlassCard)'),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef _QuickMenuItem = ({IconData icon, String label});

/// Ikon + label pintasan HR; 2 baris (5 + 4), digulir horizontal bila perlu.
class _DashboardIconScrollGrid extends StatelessWidget {
  const _DashboardIconScrollGrid();

  static const double _tileWidth = 88;
  static const double _rowGap = AppDimensions.paddingS;

  /// Lingkaran kaca; ikon di dalam sedikit lebih kecil.
  static const double _glassCircleSize = 54;
  static const double _iconInnerSize = AppDimensions.iconM;
  static const double _labelFontSize = 11;
  static const double _labelHeightFactor = 1.15;
  static const int _labelMaxLines = 2;
  static const double _tileVerticalPadding = AppDimensions.paddingS;
  static const double _iconToLabelGap = AppDimensions.paddingXS;

  static const List<_QuickMenuItem> _items = [
    (icon: Icons.calendar_month_outlined, label: 'Kalender'),
    (icon: Icons.more_time_outlined, label: 'Lembur'),
    (icon: Icons.swap_horiz_rounded, label: 'Transfer pegawai'),
    (icon: Icons.handshake_outlined, label: 'Peminjaman pegawai'),
    (icon: Icons.inventory_2_outlined, label: 'Pengajuan kebutuhan karyawan'),
    (icon: Icons.warning_amber_rounded, label: 'Surat peringatan'),
    (icon: Icons.forum_outlined, label: 'MEMO internal'),
    (icon: Icons.campaign_outlined, label: 'Pengumuman perusahaan'),
    (icon: Icons.article_outlined, label: 'PKWT'),
  ];

  static const int _firstRowCount = 5;

  /// Tinggi baris = kartu tertinggi di baris itu (ikon + teks diukur seperti [Text]).
  static double _rowHeightForItems(
    BuildContext context,
    List<_QuickMenuItem> row,
  ) {
    final textScaler = MediaQuery.textScalerOf(context);
    final style = AppTypography.bodySmall.copyWith(
      fontSize: _labelFontSize,
      height: _labelHeightFactor,
      fontWeight: FontWeight.w600,
      color: _glassOnPrimary,
    );
    final labelMaxWidth = _tileWidth - AppDimensions.paddingXS * 2;
    final tp = TextPainter(
      textDirection: Directionality.of(context),
      textScaler: textScaler,
    );
    var maxTile = 0.0;
    try {
      for (final item in row) {
        tp.text = TextSpan(text: item.label, style: style);
        tp.layout(maxWidth: labelMaxWidth);
        final textH = tp.height;
        final tileH =
            _tileVerticalPadding * 2 +
            _glassCircleSize +
            _iconToLabelGap +
            textH;
        maxTile = math.max(maxTile, tileH);
      }
    } finally {
      tp.dispose();
    }
    return maxTile;
  }

  @override
  Widget build(BuildContext context) {
    final first = _items.take(_firstRowCount).toList();
    final second = _items.skip(_firstRowCount).toList();

    // Hindari IntrinsicHeight + SingleChildScrollView (error semantics/layout).
    // Tinggi dari pengukuran teks nyata + buffer sub-pixel / border kartu.
    final h1 = _rowHeightForItems(context, first);
    final h2 = _rowHeightForItems(context, second);
    final scrollHeight = h1 + _rowGap + h2 + 6;

    return SizedBox(
      height: scrollHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: h1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < first.length; i++)
                    _tile(
                      context,
                      first[i],
                      rowHeight: h1,
                      isLastInRow: i == first.length - 1,
                    ),
                ],
              ),
            ),
            SizedBox(height: _rowGap),
            SizedBox(
              height: h2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < second.length; i++)
                    _tile(
                      context,
                      second[i],
                      rowHeight: h2,
                      isLastInRow: i == second.length - 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    _QuickMenuItem item, {
    required double rowHeight,
    required bool isLastInRow,
  }) {
    void onTap() {
      SnackBarHelper.showInfo(
        context,
        title: item.label,
        message: 'Fitur ini segera hadir.',
      );
    }

    return Padding(
      padding: EdgeInsets.only(right: isLastInRow ? 0 : _rowGap),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: _tileVerticalPadding,
          horizontal: AppDimensions.paddingXS,
        ),
        child: SizedBox(
          width: _tileWidth,
          height: math.max(0, rowHeight - _tileVerticalPadding * 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GlassCard(
                onTap: onTap,
                borderRadius: _glassCircleSize / 2,
                padding: EdgeInsets.zero,
                blurSigma: DashboardGlassStyle.quickActionIconBlurSigma,
                enableBackdropBlur: false,
                disabledBackdropBlurSigma: 2.4,
                borderWidth: DashboardGlassStyle.quickActionIconBorderWidth,
                borderOpacity: DashboardGlassStyle.quickActionIconBorderOpacity,
                overlayTopOpacity:
                    DashboardGlassStyle.quickActionIconOverlayTop,
                overlayBottomOpacity:
                    DashboardGlassStyle.quickActionIconOverlayBottom,
                shadowOpacity: DashboardGlassStyle.quickActionIconShadowOpacity,
                enableShimmer: false,
                enableWaterRipple: true,
                waterRippleColor: Colors.white.withValues(alpha: 0.42),
                waterRippleDuration: const Duration(milliseconds: 900),
                pressForwardDuration: const Duration(milliseconds: 85),
                pressReverseDuration: const Duration(milliseconds: 280),
                pressTilt: 0,
                pressPerspectiveZ: 0,
                pressSkew: 0,
                pressSlidePixels: 0,
                pressScale: 0.88,
                liquidHaptics: true,
                child: SizedBox(
                  width: _glassCircleSize,
                  height: _glassCircleSize,
                  child: Center(
                    child: Icon(
                      item.icon,
                      size: _iconInnerSize + 2,
                      color: _glassIconColor,
                      shadows: const [
                        Shadow(
                          color: Color(0x22000000),
                          blurRadius: 1.5,
                          offset: Offset(0, 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: _iconToLabelGap),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: _labelMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: _labelFontSize,
                      height: _labelHeightFactor,
                      fontWeight: FontWeight.w600,
                      color: _glassOnPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
