import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_helper.dart';
import '../../core/constants/company_context.dart';
import '../../data/datasources/local/google_login/google_login_local_storage.dart';

/// SharedPreferences Provider
/// Must be overridden in main.dart with actual SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});

/// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// API Helper Provider
final apiHelperProvider = Provider<ApiHelper>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiHelper(apiClient);
});

/// Current Company Context Provider
/// This manages the active company context for multi-company support
final companyContextProvider =
    StateNotifierProvider<CompanyContextNotifier, CompanyContext?>((ref) {
      return CompanyContextNotifier();
    });

class CompanyContextNotifier extends StateNotifier<CompanyContext?> {
  CompanyContextNotifier() : super(null);

  void setCompany(CompanyContext company) {
    state = company;
  }

  void clearCompany() {
    state = null;
  }

  bool get hasCompany => state != null;
}

/// Auth Token Provider
final authTokenProvider = StateProvider<String?>((ref) => null);

/// `true` setelah HTTP 401 pada request terautentikasi; router arahkan ke session-expired screen.
final sessionExpiredNoticeProvider = StateProvider<bool>((ref) => false);

/// Update auth token and sync with API client
void updateAuthToken(WidgetRef ref, String? token) {
  ref.read(authTokenProvider.notifier).state = token;
  ref.read(apiClientProvider).updateAuthToken(token);
}

/// Update company context and sync with API client
void updateCompanyContext(WidgetRef ref, CompanyContext company) {
  ref.read(companyContextProvider.notifier).setCompany(company);
  ref.read(apiClientProvider).updateCompanyContext(company);
}

/// Language Provider
/// Manages the current app language (id or en)
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final savedLanguage =
      prefs.getString('app_language') ?? 'id'; // Default to Indonesian
  return LanguageNotifier(prefs, Locale(savedLanguage));
});

class LanguageNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;

  LanguageNotifier(this._prefs, super.state);

  Future<void> setLanguage(Locale locale) async {
    state = locale;
    await _prefs.setString('app_language', locale.languageCode);
  }

  Future<void> toggleLanguage() async {
    final newLocale = state.languageCode == 'id'
        ? const Locale('en')
        : const Locale('id');
    await setLanguage(newLocale);
  }
}

/// Snapshot login Google (file lokal); dipakai sementara hingga sync API.
final googleLoginLocalStorageProvider = Provider<GoogleLoginLocalStorage>(
  (ref) => GoogleLoginLocalStorage(),
);

/// Has Seen Onboarding Provider
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('has_seen_onboarding') ?? false;
});
