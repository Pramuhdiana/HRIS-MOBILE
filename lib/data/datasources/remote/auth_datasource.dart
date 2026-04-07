import '../../../core/network/api_helper.dart';
import '../../../core/constants/api_endpoints.dart';

/// Auth Data Source
/// Handles authentication API calls
class AuthDataSource {
  final ApiHelper _apiHelper;

  AuthDataSource(this._apiHelper);

  /// Login with email and password
  ///
  /// Response format:
  /// {
  ///   "status": 1,
  ///   "message": "ok",
  ///   "data": {
  ///     "token": "..."
  ///   }
  /// }
  ///
  /// Returns:
  /// - Map containing token and user data on success
  /// - Throws Failure on error
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await _apiHelper.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
  }

  /// Login with Google
  ///
  /// Request body should contain Google access token or ID token
  /// Response format same as regular login
  ///
  /// Returns:
  /// - Map containing token and user data on success
  /// - Throws Failure on error
  Future<Map<String, dynamic>> loginWithGoogle({
    required String accessToken,
    String? idToken,
  }) async {
    return await _apiHelper.post(
      ApiEndpoints.loginGoogle,
      data: {
        'access_token': accessToken,
        if (idToken != null) 'id_token': idToken,
      },
    );
  }

  /// Server logout — `https://mangroup.id/ms-auth/api/auth/logout` (Bearer token).
  Future<Map<String, dynamic>> logout() async {
    return await _apiHelper.post(ApiEndpoints.logout, data: <String, dynamic>{});
  }
}
