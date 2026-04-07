import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';

/// Ringkasan user dari prefs + file `google_login` (untuk tampilan profil).
class UserProfileSnapshot {
  final String? email;
  final String? loginMethod;
  final String? displayName;
  final String? photoUrl;
  final String? googleUserId;
  final bool backendSynced;
  final String? revokedAt;

  const UserProfileSnapshot({
    this.email,
    this.loginMethod,
    this.displayName,
    this.photoUrl,
    this.googleUserId,
    this.backendSynced = false,
    this.revokedAt,
  });

  bool get hasSession =>
      (email != null && email!.isNotEmpty) || (displayName != null);

  String get initials {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      final parts = displayName!.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return displayName!.substring(0, 1).toUpperCase();
    }
    if (email != null && email!.isNotEmpty) {
      return email![0].toUpperCase();
    }
    return '?';
  }
}

final userProfileSnapshotProvider =
    FutureProvider<UserProfileSnapshot>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  final email = prefs.getString('user_email');
  final method = prefs.getString('login_method');
  final session =
      await ref.read(googleLoginLocalStorageProvider).readSession();

  if (session == null) {
    return UserProfileSnapshot(
      email: email,
      loginMethod: method,
    );
  }

  Map<String, dynamic>? gam;
  final ga = session['googleAccount'];
  if (ga is Map) {
    gam = Map<String, dynamic>.from(ga);
  }

  return UserProfileSnapshot(
    email: email ?? gam?['email'] as String?,
    loginMethod: method,
    displayName: gam?['displayName'] as String?,
    photoUrl: gam?['photoUrl'] as String?,
    googleUserId: gam?['id'] as String?,
    backendSynced: session['backendSynced'] == true,
    revokedAt: session['revoked_at']?.toString(),
  );
});
