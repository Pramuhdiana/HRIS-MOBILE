import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/google_sign_in_config.dart';

/// Google Sign-In Data Source
/// Handles Google authentication
class GoogleAuthDataSource {
  final GoogleSignIn _googleSignIn;

  GoogleAuthDataSource({GoogleSignIn? googleSignIn})
    : _googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            scopes: const ['email', 'profile'],
            serverClientId: kGoogleServerClientId.isEmpty
                ? null
                : kGoogleServerClientId,
            clientId: kGoogleIosClientId.isEmpty ? null : kGoogleIosClientId,
          );

  void _ensureConfiguredForPlatform() {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      if (kGoogleServerClientId.isEmpty) {
        throw StateError(
          'Google Sign-In belum dikonfigurasi untuk Android. '
          'Jalankan app dengan --dart-define=GOOGLE_SERVER_CLIENT_ID=<Web Client ID .apps.googleusercontent.com> '
          'dan pastikan di Google Cloud Console sudah ada OAuth client Android '
          '(package com.hris.hris_mobile_app + SHA-1 keystore). '
          'Atau tambahkan google-services.json dari Firebase.',
        );
      }
      return;
    }
    if (Platform.isIOS) {
      if (kGoogleIosClientId.isEmpty) {
        throw StateError(
          'Google Sign-In belum dikonfigurasi untuk iOS. '
          'Set --dart-define=GOOGLE_IOS_CLIENT_ID=<iOS Client ID> '
          'dan tambahkan GIDClientID + CFBundleURLTypes (REVERSED_CLIENT_ID) di ios/Runner/Info.plist.',
        );
      }
    }
  }

  /// Sign in with Google
  /// Returns GoogleSignInAccount on success, null on cancel
  Future<GoogleSignInAccount?> signIn() async {
    _ensureConfiguredForPlatform();
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      return account;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Get current signed in account
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Check if user is signed in
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Get authentication token
  Future<String?> getAccessToken() async {
    try {
      _ensureConfiguredForPlatform();
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;
        return auth.accessToken;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
