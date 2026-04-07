import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_providers.dart';

/// Pulihkan `authToken` dari SharedPreferences setelah app dibuka.
/// Untuk login Google: hanya aktif jika file lokal ada dan `revoked_at` kosong/null.
Future<void> restoreAuthSession(WidgetRef ref) async {
  final prefs = ref.read(sharedPreferencesProvider);
  final token = prefs.getString('auth_token');
  if (token == null || token.isEmpty) {
    ref.read(authTokenProvider.notifier).state = null;
    ref.read(apiClientProvider).updateAuthToken(null);
    return;
  }

  final method = prefs.getString('login_method');
  if (method == 'google') {
    final storage = ref.read(googleLoginLocalStorageProvider);
    final session = await storage.readSession();
    if (session == null) {
      await _clearStaleAuth(ref, prefs);
      return;
    }
    final revoked = session['revoked_at'];
    if (revoked != null && revoked.toString().trim().isNotEmpty) {
      await _clearStaleAuth(ref, prefs);
      return;
    }
    if (token.startsWith('google_local:')) {
      final expectedId = token.substring('google_local:'.length);
      final ga = session['googleAccount'];
      if (ga is! Map || ga['id']?.toString() != expectedId) {
        await _clearStaleAuth(ref, prefs);
        return;
      }
    }
  }

  ref.read(authTokenProvider.notifier).state = token;
  ref.read(apiClientProvider).updateAuthToken(token);
}

Future<void> _clearStaleAuth(WidgetRef ref, SharedPreferences prefs) async {
  ref.read(authTokenProvider.notifier).state = null;
  ref.read(apiClientProvider).updateAuthToken(null);
  await prefs.remove('auth_token');
  await prefs.remove('user_email');
  await prefs.remove('login_method');
}
