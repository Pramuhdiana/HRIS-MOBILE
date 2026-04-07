import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/animated_onboarding.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/dashboard/main_dashboard_screen.dart';
import '../../presentation/providers/app_providers.dart';
import 'page_transitions.dart';

/// App Router Configuration
/// Centralized routing using go_router
class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Router configuration
  static GoRouter router(WidgetRef ref) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      redirect: (context, state) {
        // Check if user has seen onboarding
        final hasSeenOnboardingAsync = ref.read(hasSeenOnboardingProvider);
        final isLoggedIn = ref.read(authTokenProvider) != null;

        return hasSeenOnboardingAsync.when(
          data: (seen) {
            final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
            final isSplash = state.matchedLocation == AppRoutes.splash;
            final isLogin = state.matchedLocation == AppRoutes.login;
            final isDashboard = state.matchedLocation == AppRoutes.dashboard;

            // If user is logged in, allow access to onboarding (they might want to view it again)
            if (isLoggedIn && isOnboarding) {
              return null; // Allow access to onboarding
            }

            // If user is logged in and trying to access login/splash, redirect to dashboard
            if (isLoggedIn && (isLogin || isSplash)) {
              return AppRoutes.dashboard;
            }

            // If user is not logged in and trying to access protected routes
            if (!isLoggedIn && isDashboard) {
              return AppRoutes.login;
            }

            // If user hasn't seen onboarding and not on onboarding/splash screen
            if (!seen && !isOnboarding && !isSplash) {
              return AppRoutes.onboarding;
            }

            // If user has seen onboarding and on onboarding screen (but not logged in)
            // Redirect to login only if they're not logged in
            if (seen && isOnboarding && !isLoggedIn) {
              return AppRoutes.login;
            }

            return null; // No redirect needed
          },
          loading: () => null, // Don't redirect while loading
          error: (_, __) => null, // Don't redirect on error
        );
      },
      routes: [
        // Splash Screen - Fade transition
        GoRoute(
          path: AppRoutes.splash,
          name: AppRoutes.splashName,
          pageBuilder: (context, state) => PageTransitions.fade(
            context: context,
            state: state,
            child: const SplashScreen(),
            duration: const Duration(milliseconds: 500),
          ),
        ),

        // Onboarding Screen - Fade and slide transition
        GoRoute(
          path: AppRoutes.onboarding,
          name: AppRoutes.onboardingName,
          pageBuilder: (context, state) => PageTransitions.fadeSlide(
            context: context,
            state: state,
            child: const AnimatedOnboardingScreen(),
            duration: const Duration(milliseconds: 500),
          ),
        ),

        // Auth Routes - Slide from right
        GoRoute(
          path: AppRoutes.login,
          name: AppRoutes.loginName,
          pageBuilder: (context, state) => PageTransitions.slide(
            context: context,
            state: state,
            child: const LoginScreen(),
            duration: const Duration(milliseconds: 400),
          ),
        ),

        // Main Dashboard - Fade and scale transition
        GoRoute(
          path: AppRoutes.dashboard,
          name: AppRoutes.dashboardName,
          pageBuilder: (context, state) => PageTransitions.fadeScale(
            context: context,
            state: state,
            child: const MainDashboardScreen(),
            duration: const Duration(milliseconds: 400),
          ),
        ),
      ],
    );
  }
}

/// App Routes Constants
/// Centralized route paths and names
class AppRoutes {
  // Paths
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  // Route Names (for named navigation)
  static const String splashName = 'splash';
  static const String onboardingName = 'onboarding';
  static const String loginName = 'login';
  static const String dashboardName = 'dashboard';

  /// `GoRouterState.extra` saat membuka dashboard setelah login sukses (untuk SnackBar di dashboard).
  static const String extraLoginSuccess = 'loginSuccess';
}
