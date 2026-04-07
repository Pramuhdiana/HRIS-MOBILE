import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/auth_datasource.dart';
import '../../data/datasources/remote/google_auth_datasource.dart';
import '../../data/datasources/remote/ms_user_bootstrap_datasource.dart';
import '../../core/constants/company_context.dart';
import '../../core/errors/failures.dart';
import 'app_providers.dart';

/// Auth Data Source Provider
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  final apiHelper = ref.watch(apiHelperProvider);
  return AuthDataSource(apiHelper);
});

/// Google Auth Data Source Provider
final googleAuthDataSourceProvider = Provider<GoogleAuthDataSource>((ref) {
  return GoogleAuthDataSource();
});

/// MS-User bootstrap provider (perusahaan/profile/notifications)
final msUserBootstrapDataSourceProvider = Provider<MsUserBootstrapDataSource>(
  (ref) => MsUserBootstrapDataSource(ref.watch(apiClientProvider)),
);

/// Login State
class LoginState {
  final bool isEmailLoginLoading;
  final bool isGoogleLoginLoading;
  final String? error;
  final Map<String, dynamic>? userData;
  final String? token;

  const LoginState({
    this.isEmailLoginLoading = false,
    this.isGoogleLoginLoading = false,
    this.error,
    this.userData,
    this.token,
  });

  bool get isLoginBusy => isEmailLoginLoading || isGoogleLoginLoading;

  LoginState copyWith({
    bool? isEmailLoginLoading,
    bool? isGoogleLoginLoading,
    String? error,
    Map<String, dynamic>? userData,
    String? token,
  }) {
    return LoginState(
      isEmailLoginLoading: isEmailLoginLoading ?? this.isEmailLoginLoading,
      isGoogleLoginLoading: isGoogleLoginLoading ?? this.isGoogleLoginLoading,
      error: error,
      userData: userData ?? this.userData,
      token: token ?? this.token,
    );
  }
}

/// Auth Notifier
class AuthNotifier extends StateNotifier<LoginState> {
  final AuthDataSource _authDataSource;
  final GoogleAuthDataSource _googleAuthDataSource;
  final MsUserBootstrapDataSource _msUserBootstrapDataSource;
  final Ref _ref;

  AuthNotifier(
    this._authDataSource,
    this._googleAuthDataSource,
    this._msUserBootstrapDataSource,
    this._ref,
  ) : super(const LoginState());

  /// Login with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isEmailLoginLoading: true,
      isGoogleLoginLoading: false,
      error: null,
    );

    try {
      final response = await _authDataSource.login(
        email: email,
        password: password,
      );

      // Extract token from response
      // Response format: { "status": 1, "message": "ok", "data": { "token": "..." } }
      final token = response['data']?['token'] ?? 
                   response['token'] ?? 
                   response['access_token'] ??
                   response['accessToken'];

      if (token != null && token.toString().isNotEmpty) {
        // Update auth token in provider
        final tokenString = token.toString();
        _ref.read(authTokenProvider.notifier).state = tokenString;
        _ref.read(apiClientProvider).updateAuthToken(tokenString);
        
        // Save token and user data to SharedPreferences
        final prefs = _ref.read(sharedPreferencesProvider);
        await prefs.setString('auth_token', tokenString);
        await prefs.setString('user_email', email);
        await prefs.setString('login_method', 'email');
        
        // Save full response data if available
        if (response['data'] != null) {
          // You can save additional user data here if needed
        }

        // Post-login bootstrap (non-blocking for UI success)
        await _postLoginBootstrapIfPossible(tokenString);
      } else {
        throw const ServerFailure('Token not found in response');
      }

      state = state.copyWith(
        isEmailLoginLoading: false,
        isGoogleLoginLoading: false,
        userData: response,
        token: token?.toString(),
        error: null,
      );
    } on Failure catch (e) {
      state = state.copyWith(
        isEmailLoginLoading: false,
        isGoogleLoginLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isEmailLoginLoading: false,
        isGoogleLoginLoading: false,
        error: 'Unexpected error: $e',
      );
    }
  }

  /// Logout: hit server then clear session (local clear still runs if API fails).
  Future<void> logout() async {
    try {
      await _authDataSource.logout();
    } catch (_) {
      // Sessi lokal tetap ditutup walau jaringan / server gagal.
    } finally {
      state = const LoginState();
      _ref.read(authTokenProvider.notifier).state = null;
      _ref.read(apiClientProvider).updateAuthToken(null);
      _ref.read(apiClientProvider).clearCompanyContext();
      _ref.read(companyContextProvider.notifier).clearCompany();

      final prefs = _ref.read(sharedPreferencesProvider);
      await prefs.remove('auth_token');
      await prefs.remove('user_email');
      await prefs.remove('login_method');
      await _ref.read(googleLoginLocalStorageProvider).markRevokedAtNow();
    }
  }

  /// Login with Google
  Future<void> loginWithGoogle() async {
    state = state.copyWith(
      isGoogleLoginLoading: true,
      isEmailLoginLoading: false,
      error: null,
    );

    try {
      // Step 1: Sign in with Google
      final googleAccount = await _googleAuthDataSource.signIn();
      
      if (googleAccount == null) {
        // User cancelled Google sign in
        state = state.copyWith(
          isEmailLoginLoading: false,
          isGoogleLoginLoading: false,
          error: null,
        );
        return;
      }

      // Step 2: Get authentication tokens
      final googleAuth = await googleAccount.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw const ServerFailure('Failed to get Google access token');
      }

      Map<String, dynamic>? backendResponse;
      String? backendToken;
      try {
        backendResponse = await _authDataSource.loginWithGoogle(
          accessToken: accessToken,
          idToken: idToken,
        );
        backendToken = backendResponse['data']?['token'] ??
            backendResponse['token'] ??
            backendResponse['access_token'] ??
            backendResponse['accessToken'];
        if (backendToken != null && backendToken.toString().isEmpty) {
          backendToken = null;
        }
      } on Failure {
        // API belum tersedia / error server — lanjut login lokal ke dashboard
        backendResponse = null;
        backendToken = null;
      } catch (_) {
        backendResponse = null;
        backendToken = null;
      }

      final bool backendOk =
          backendToken != null && backendToken.toString().isNotEmpty;
      final String tokenString =
          backendOk ? backendToken.toString() : 'google_local:${googleAccount.id}';

      final Map<String, dynamic> userDataForState = backendOk && backendResponse != null
          ? _jsonSafeDeepCopy(backendResponse)
          : {
              'localOnly': true,
              'reason': 'backend_google_login_unavailable',
              'googleAccount': {
                'id': googleAccount.id,
                'email': googleAccount.email,
                'displayName': googleAccount.displayName,
                'photoUrl': googleAccount.photoUrl,
              },
            };

      _ref.read(authTokenProvider.notifier).state = tokenString;
      _ref.read(apiClientProvider).updateAuthToken(tokenString);

      final prefs = _ref.read(sharedPreferencesProvider);
      await prefs.setString('auth_token', tokenString);
      await prefs.setString('user_email', googleAccount.email);
      await prefs.setString('login_method', 'google');

      try {
        await _ref.read(googleLoginLocalStorageProvider).saveSession({
          'revoked_at': null,
          'backendSynced': backendOk,
          'googleAccount': {
            'id': googleAccount.id,
            'email': googleAccount.email,
            'displayName': googleAccount.displayName,
            'photoUrl': googleAccount.photoUrl,
          },
          'googleAuthentication': {
            'accessToken': accessToken,
            'idToken': idToken,
            'serverAuthCode': googleAuth.serverAuthCode,
          },
          'backendLoginResponse':
              backendResponse != null ? _jsonSafeDeepCopy(backendResponse) : null,
        });
      } catch (_) {}

      state = state.copyWith(
        isEmailLoginLoading: false,
        isGoogleLoginLoading: false,
        userData: userDataForState,
        token: tokenString,
        error: null,
      );

      // Bootstrap hanya jika token berasal dari backend (bukan google_local)
      await _postLoginBootstrapIfPossible(tokenString);
    } on Failure catch (e) {
      state = state.copyWith(
        isEmailLoginLoading: false,
        isGoogleLoginLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isEmailLoginLoading: false,
        isGoogleLoginLoading: false,
        error: 'Google login failed: $e',
      );
    }
  }

  Future<void> _postLoginBootstrapIfPossible(String tokenString) async {
    // Token lokal (fallback) tidak valid untuk ms-user.
    if (tokenString.startsWith('google_local:')) return;

    try {
      // Jalankan paralel agar cepat.
      final results = await Future.wait([
        _msUserBootstrapDataSource.getPerusahaan(),
        _msUserBootstrapDataSource.getProfile(),
        _msUserBootstrapDataSource.getNotifications(),
      ]);

      final perusahaan = results[0];
      final profile = results[1];
      final notifications = results[2];

      final prefs = _ref.read(sharedPreferencesProvider);
      await prefs.setString('ms_user_perusahaan', jsonEncode(perusahaan));
      await prefs.setString('ms_user_profile', jsonEncode(profile));
      await prefs.setString('ms_user_notifications', jsonEncode(notifications));

      // Set company context untuk header X-Company-Id jika dibutuhkan oleh service lain.
      final data = perusahaan['data'];
      if (data is Map<String, dynamic>) {
        final id = data['id'];
        final name = (data['app_name'] ?? data['nama'] ?? 'Company').toString();
        final logo = (data['path_logo'] ?? data['path_favicon'])?.toString();

        if (id != null) {
          final ctx = CompanyContext(
            companyId: id.toString(),
            companyName: name,
            companyLogo: logo,
            settings: data,
          );
          _ref.read(companyContextProvider.notifier).setCompany(ctx);
          _ref.read(apiClientProvider).updateCompanyContext(ctx);
        }
      }
    } catch (_) {
      // Bootstrap gagal tidak boleh menggagalkan login.
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

Map<String, dynamic> _jsonSafeDeepCopy(Map<String, dynamic> source) {
  try {
    return jsonDecode(jsonEncode(source)) as Map<String, dynamic>;
  } catch (_) {
    return {'unserializable': source.toString()};
  }
}

/// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, LoginState>((ref) {
  final authDataSource = ref.watch(authDataSourceProvider);
  final googleAuthDataSource = ref.watch(googleAuthDataSourceProvider);
  final msUserBootstrap = ref.watch(msUserBootstrapDataSourceProvider);
  return AuthNotifier(authDataSource, googleAuthDataSource, msUserBootstrap, ref);
});
