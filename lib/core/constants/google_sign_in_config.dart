// Google Sign-In — OAuth Client IDs dari Google Cloud Console (Credentials).
//
// Web Client ID (untuk Android `serverClientId` & opsional GIDServerClientID iOS):
//   https://console.cloud.google.com/apis/credentials
//   → "+ CREATE CREDENTIALS" → "OAuth client ID" → Application type: **Web application**
//   → salin "Client ID" (.apps.googleusercontent.com). Bukan client Android/iOS.
//
// Cara 1 (disarankan): flutter run
//   --dart-define=GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com
//   --dart-define=GOOGLE_IOS_CLIENT_ID=....   (opsional, untuk iOS)
//
// Cara 2: isi kGoogleServerClientIdManual / kGoogleIosClientIdManual di bawah.
//
// Android: buat OAuth client tipe "Web" (untuk serverClientId) + tipe "Android"
// dengan package com.hris.hris_mobile_app dan SHA-1 debug/release.
// SHA-1 debug: keytool -list -v -keystore ~/.android/debug.keystore (password: android)
//
// iOS: selain client ID, wajib tambahkan GIDClientID + CFBundleURLSchemes
// (REVERSED_CLIENT_ID) di ios/Runner/Info.plist — lihat google_sign_in_ios.
//
// Alternatif: Firebase + google-services.json + GoogleService-Info.plist.

library;

const String _kGoogleServerClientIdEnv = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  defaultValue: '',
);

const String _kGoogleIosClientIdEnv = String.fromEnvironment(
  'GOOGLE_IOS_CLIENT_ID',
  defaultValue: '',
);

/// Web Client ID — isi jika tidak pakai `--dart-define`.
/// Ini **bukan** `client_id` Android dari `android/app/oauth_android_client.json`; yang itu
/// terdaftar lewat package + SHA-1 di Console. Di sini harus OAuth client tipe **Web**.
const String kGoogleServerClientIdManual =
    '805966681264-u65c08bg7i0d1tprob79l80cli1q9k3i.apps.googleusercontent.com';

/// iOS Client ID — sama dengan `CLIENT_ID` di `ios/Runner/OAuth-IOS.plist` / `GIDClientID` di Info.plist.
const String kGoogleIosClientIdManual =
    '805966681264-4c2q6nsture9kvepk2s52dlmiukedagc.apps.googleusercontent.com';

String get kGoogleServerClientId =>
    _kGoogleServerClientIdEnv.isNotEmpty
        ? _kGoogleServerClientIdEnv
        : kGoogleServerClientIdManual;

String get kGoogleIosClientId =>
    _kGoogleIosClientIdEnv.isNotEmpty
        ? _kGoogleIosClientIdEnv
        : kGoogleIosClientIdManual;
