import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
// import '../../../core/constants/app_dimensions.dart'; // Not used in this file
// import '../../../data/providers/mock_data_provider.dart'; // Not used in this file
import 'home_tab.dart';
import '../attendance/attendance_tab.dart';
import '../leave/leave_tab.dart';
import '../profile/profile_tab.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/snackbar_helper.dart';

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
  bool _postLoginSnackScheduled = false;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const HomeTab(),
      const AttendanceTab(),
      const LeaveTab(),
      const ProfileTab(),
    ];
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

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: AppColors.surfaceLight,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLight,
          selectedLabelStyle: AppTypography.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTypography.labelSmall,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: AppStrings.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_outlined),
              activeIcon: Icon(Icons.access_time),
              label: AppStrings.attendance,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              activeIcon: Icon(Icons.event_note),
              label: AppStrings.leave,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: AppStrings.profile,
            ),
          ],
        ),
      ),
    );
  }
}
