import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/routes/app_router.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/widgets/app_refresh_configuration.dart';
import 'presentation/widgets/global_api_debug_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const HRISMobileApp(),
    ),
  );
}

class HRISMobileApp extends ConsumerStatefulWidget {
  const HRISMobileApp({super.key});

  @override
  ConsumerState<HRISMobileApp> createState() => _HRISMobileAppState();
}

class _HRISMobileAppState extends ConsumerState<HRISMobileApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(apiClientProvider).setOnUnauthorized(() {
        ref.read(authProvider.notifier).clearSessionDueToUnauthorized();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(languageProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Localization support
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('id'), // Indonesian
      ],
      routerConfig: router,
      builder: (context, child) {
        return AppRefreshConfiguration(
          child: GlobalApiDebugOverlay(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
