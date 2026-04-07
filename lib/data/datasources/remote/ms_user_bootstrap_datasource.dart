import 'package:dio/dio.dart';

import '../../../core/errors/failures.dart';
import '../../../core/network/api_client.dart';

/// DataSource untuk endpoint `ms-user` yang memakai format:
/// `{ code: "00", message: "ok", status: 200, data: ... }`
///
/// Ini sengaja tidak memakai `ApiHelper` karena `ApiHelper` menganggap field
/// `status` bernilai 1 sebagai sukses (format API lain).
class MsUserBootstrapDataSource {
  MsUserBootstrapDataSource(this._apiClient);

  final ApiClient _apiClient;

  static const String _perusahaanPath = '/ms-user/api/perusahaan';
  static const String _profilePath = '/ms-user/api/profile';
  static const String _notificationsPath = '/ms-user/api/notifications';

  Future<Map<String, dynamic>> getPerusahaan() => _getMsUser(_perusahaanPath);
  Future<Map<String, dynamic>> getProfile() => _getMsUser(_profilePath);
  Future<Map<String, dynamic>> getNotifications() => _getMsUser(_notificationsPath);

  Future<Map<String, dynamic>> _getMsUser(String path) async {
    try {
      final Response<dynamic> res = await _apiClient.get(path);
      final statusCode = res.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw ServerFailure(
          'Request failed with status: $statusCode ${res.statusMessage ?? ''}',
        );
      }

      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerFailure('Unexpected response format');
      }

      // MS-USER success criteria: status==200 OR code=="00"
      final status = data['status'];
      final code = data['code'];
      final ok = status == 200 || code == '00';
      if (!ok) {
        final msg = (data['message'] ?? data['error'] ?? 'Request failed')
            .toString();
        throw ServerFailure(msg);
      }

      return data;
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? ((e.response?.data as Map)['message'] ??
                  (e.response?.data as Map)['error'] ??
                  'Request failed')
              .toString()
          : (e.message ?? 'Network error');
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) throw UnauthorizedFailure(msg);
      throw ServerFailure(msg);
    }
  }
}

