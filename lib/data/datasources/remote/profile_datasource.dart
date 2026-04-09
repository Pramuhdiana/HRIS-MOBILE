import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_helper.dart';

/// Profile Data Source
/// Handles profile-related API calls.
class ProfileDataSource {
  ProfileDataSource(this._apiHelper);

  final ApiHelper _apiHelper;

  Future<Map<String, dynamic>> getProfile() async {
    return _apiHelper.get(
      ApiEndpoints.userProfile,
      queryParameters: const <String, dynamic>{'type': 'detail'},
    );
  }

  /// Update profil pengguna — field diselaraskan dengan biodata HRIS umum.
  Future<Map<String, dynamic>> updateProfile({
    required String nama,
    required String email,
    required String noHp,
    required String jk,
    required String agama,
    required String tempatLahir,
    required String tglLahirIso,
    required String alamatDom,
    required String alamatKtp,
    required String status,
    required int jmlAnak,
    String? kontakDarurat,
  }) async {
    final body = <String, dynamic>{
      'nama': nama,
      'jk': jk,
      'kontak_darurat': kontakDarurat ?? '',
      'agama': agama,
      'email': email,
      'no_hp': noHp,
      'jml_anak': jmlAnak,
      'tempat_lahir': tempatLahir,
      'tgl_lahir': tglLahirIso,
      'alamat_dom': alamatDom,
      'alamat_ktp': alamatKtp,
      'status': status,
    };
    // BE menerima update profile via POST (bukan PUT).
    return _apiHelper.post(ApiEndpoints.updateProfile, data: body);
  }
}
