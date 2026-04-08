import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_strings.dart';
// import '../../../core/constants/app_dimensions.dart'; // Not used in this file
// import '../../../data/providers/mock_data_provider.dart'; // Not used in this file
import 'home_tab.dart';
import '../attendance/attendance_tab.dart';
import '../leave/leave_tab.dart';
import '../profile/profile_tab.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/layout/dashboard_tab_bottom_inset.dart';

/// Main Dashboard Screen with Bottom Navigation
/// Based on POS Mobile Figma Template design
class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  late List<Widget> _tabs;
  late final PageController _pageController;
  late final NotchBottomBarController _notchController;
  bool _postLoginSnackScheduled = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _notchController = NotchBottomBarController(index: _currentIndex);
    _tabs = [
      const HomeTab(),
      const AttendanceTab(),
      const LeaveTab(),
      const ProfileTab(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_postLoginSnackScheduled) return;
    final extra = GoRouterState.of(context).extra;
    if (extra == AppRoutes.extraLoginSuccess) {
      _postLoginSnackScheduled = true;
      final l10n = AppLocalizations.of(context)!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        SnackBarHelper.showSuccess(
          context,
          title: l10n.success,
          message: l10n.loginSuccess,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const activeColor = Colors.white;
    final inactiveColor = colorScheme.onSurfaceVariant;
    final labelColor = colorScheme.onSurface;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final floatingWidth = MediaQuery.sizeOf(context).width - 24;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          if (!mounted) return;
          setState(() => _currentIndex = index);
        },
        children: _tabs,
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          12,
          0,
          12,
          kDashboardDockShellBottomPadding + bottomInset,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: AnimatedNotchBottomBar(
            showBlurBottomBar: false,
            blurOpacity: 0.1,
            blurFilterX: 5.0,
            blurFilterY: 10.0,
            notchBottomBarController: _notchController,
            color: Colors.white,
            showLabel: true,
            textOverflow: TextOverflow.visible,
            maxLine: 1,
            shadowElevation: 5,
            kBottomRadius: 28.0,
            notchColor: const Color(0xFF6FB1FC),
            removeMargins: false,
            bottomBarWidth: floatingWidth,
            showShadow: true,
            durationInMilliSeconds: 500,
            itemLabelStyle: TextStyle(
              color: labelColor,
              fontSize: 11,
              height: 1.15,
              fontWeight: FontWeight.w500,
            ),
            elevation: 1,
            bottomBarItems: [
              BottomBarItem(
                inActiveItem: Icon(Icons.home_outlined, color: inactiveColor),
                activeItem: Icon(Icons.home, color: activeColor),
                itemLabel: AppStrings.home,
              ),
              BottomBarItem(
                inActiveItem: Icon(
                  Icons.access_time_outlined,
                  color: inactiveColor,
                ),
                activeItem: Icon(Icons.access_time, color: activeColor),
                itemLabel: AppStrings.attendance,
              ),
              BottomBarItem(
                inActiveItem: Icon(
                  Icons.event_note_outlined,
                  color: inactiveColor,
                ),
                activeItem: Icon(Icons.event_note, color: activeColor),
                itemLabel: AppStrings.leave,
              ),
              BottomBarItem(
                inActiveItem: Icon(Icons.person_outline, color: inactiveColor),
                activeItem: Icon(Icons.person, color: activeColor),
                itemLabel: AppStrings.profile,
              ),
            ],
            onTap: (index) {
              _pageController.jumpToPage(index);
            },
            kIconSize: 24.0,
          ),
        ),
      ),
    );
  }
}
