import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/animated_onboarding.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/dashboard/main_dashboard_screen.dart';
import '../../presentation/widgets/glass_card.dart';
import '../../presentation/providers/app_providers.dart';
import 'page_transitions.dart';

/// Memicu [GoRouter] menjalankan ulang [redirect] saat auth/onboarding berubah,
/// tanpa membuat router baru (mencegah [Duplicate GlobalKey] pada [navigatorKey]).
class GoRouterRefresh extends ChangeNotifier {
  GoRouterRefresh(this._ref) {
    _ref.listen(authTokenProvider, (_, __) => notifyListeners());
    _ref.listen(hasSeenOnboardingProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}

final goRouterRefreshProvider = Provider<GoRouterRefresh>((ref) {
  final notifier = GoRouterRefresh(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// Satu instance [GoRouter] per app — jangan panggil [GoRouter.new] di setiap build.
final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(goRouterRefreshProvider);

  String? redirect(BuildContext context, GoRouterState state) {
    final hasSeenOnboardingAsync = ref.read(hasSeenOnboardingProvider);
    final isLoggedIn = ref.read(authTokenProvider) != null;

    return hasSeenOnboardingAsync.when(
      data: (seen) {
        final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
        final isSplash = state.matchedLocation == AppRoutes.splash;
        final isLogin = state.matchedLocation == AppRoutes.login;
        final isDashboard = state.matchedLocation == AppRoutes.dashboard;
        final isGlassDemo = state.matchedLocation == AppRoutes.glassDemo;

        if (!isLoggedIn && isGlassDemo) {
          return AppRoutes.login;
        }

        if (isLoggedIn && isOnboarding) {
          return null;
        }

        if (isLoggedIn && isLogin) {
          return AppRoutes.dashboard;
        }

        if (!isLoggedIn && isDashboard) {
          return AppRoutes.login;
        }

        if (!seen && !isOnboarding && !isSplash) {
          return AppRoutes.onboarding;
        }

        if (seen && isOnboarding && !isLoggedIn) {
          return AppRoutes.login;
        }

        return null;
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  final router = GoRouter(
    navigatorKey: AppRouter.navigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: refresh,
    redirect: redirect,
    routes: [
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
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        pageBuilder: (context, state) => PageTransitions.portalFadeIn(
          state: state,
          child: const AnimatedOnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        pageBuilder: (context, state) => PageTransitions.portalFadeIn(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRoutes.dashboardName,
        pageBuilder: (context, state) => PageTransitions.portalFadeIn(
          state: state,
          child: const MainDashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.glassDemo,
        name: AppRoutes.glassDemoName,
        pageBuilder: (context, state) => PageTransitions.fade(
          context: context,
          state: state,
          child: const GlassCardExample(),
          duration: const Duration(milliseconds: 320),
        ),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

/// App Router Configuration
/// Centralized routing using go_router
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

/// App Routes Constants
/// Centralized route paths and names
class AppRoutes {
  // Paths
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String glassDemo = '/glass-demo';

  // Route Names (for named navigation)
  static const String splashName = 'splash';
  static const String onboardingName = 'onboarding';
  static const String loginName = 'login';
  static const String dashboardName = 'dashboard';
  static const String glassDemoName = 'glass-demo';

  /// `GoRouterState.extra` saat membuka dashboard setelah login sukses (untuk SnackBar di dashboard).
  static const String extraLoginSuccess = 'loginSuccess';
}
