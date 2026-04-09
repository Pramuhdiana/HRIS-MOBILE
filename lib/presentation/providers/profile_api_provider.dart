import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/profile_datasource.dart';
import 'app_providers.dart';

/// Backend kadang mengirim satu objek, kadang [List] riwayat dengan `tgl_mulai`.
/// Ambil satu map: terbaru menurut `tgl_mulai`, kalau tidak ada tanggal → elemen terakhir.
Map<String, dynamic>? _recordFromObjectOrList(dynamic raw) {
  if (raw == null) return null;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  if (raw is List) {
    final maps = <Map<String, dynamic>>[];
    for (final e in raw) {
      if (e is Map) maps.add(Map<String, dynamic>.from(e));
    }
    if (maps.isEmpty) return null;
    return _latestByTglMulai(maps) ?? maps.last;
  }
  return null;
}

Map<String, dynamic>? _latestByTglMulai(List<Map<String, dynamic>> items) {
  Map<String, dynamic>? best;
  DateTime? bestDate;
  for (final m in items) {
    final d = DateTime.tryParse(m['tgl_mulai']?.toString() ?? '');
    if (d == null) continue;
    if (bestDate == null || d.isAfter(bestDate)) {
      bestDate = d;
      best = m;
    }
  }
  return best;
}

/// `09:00:00` → `09:00` untuk tampilan jam kerja.
String? _formatTimeHm(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final parts = raw.trim().split(':');
  if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
  return raw.trim();
}

/// `user.status` sering berisi perkawinan (Lajang/Menikah), bukan HTTP status.
String? _maritalFromUserField(String? s) {
  if (s == null || s.isEmpty) return null;
  if (RegExp(r'^\d+$').hasMatch(s)) return null;
  return s;
}

class ProfileApiData {
  const ProfileApiData({
    required this.name,
    required this.email,
    required this.phone,
    required this.nik,
    required this.employeeId,
    required this.position,
    required this.department,
    required this.statusEmployee,
    required this.joinDateRaw,
    required this.photoPath,
    this.genderRaw,
    this.religionRaw,
    this.birthPlace,
    this.birthDateRaw,
    this.domicileAddress,
    this.ktpAddress,
    this.childCountRaw,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.maritalStatusRaw,
    this.leaderName,
    this.leaderEmail,
    this.leaderPhone,
    this.leaderPhotoPath,
    this.leaderPosition,
    this.roleDisplayName,
    this.workSiteName,
    this.workScheduleLine,
    this.workLocationAddress,
    this.teamMemberCount,
  });

  final String? name;
  final String? email;
  final String? phone;
  final String? nik;

  /// ID karyawan numerik dari API (`employee_id`), untuk tampilan Employee ID.
  final String? employeeId;
  final String? position;
  final String? department;
  final String? statusEmployee;
  final String? joinDateRaw;

  /// Path relatif (mis. `static/files/profile-photos/....png`) atau URL absolut.
  final String? photoPath;

  /// Biodata untuk form edit (key umum di `user` / nested profile).
  final String? genderRaw;
  final String? religionRaw;
  final String? birthPlace;
  final String? birthDateRaw;
  final String? domicileAddress;
  final String? ktpAddress;
  final String? childCountRaw;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  /// `Lajang` / `Menikah` atau nilai mentah API.
  final String? maritalStatusRaw;

  /// Atasan langsung dari `data.leader` (ms-user profile).
  final String? leaderName;
  final String? leaderEmail;
  final String? leaderPhone;
  final String? leaderPhotoPath;
  final String? leaderPosition;

  /// Dari `data.role.display_name` (atau `name`).
  final String? roleDisplayName;

  /// Lokasi utama absensi (`data.lokasi[0]`).
  final String? workSiteName;
  final String? workScheduleLine;
  final String? workLocationAddress;

  /// Jumlah entri `data.members` (diringkas di profil).
  final int? teamMemberCount;

  /// Foto profil: `https://mangroup.id/` + path relatif (tanpa slash ganda).
  String? get photoUrl {
    return _msStaticPhotoUrl(photoPath);
  }

  /// Foto profil atasan (`leader.path`).
  String? get leaderPhotoUrl {
    return _msStaticPhotoUrl(leaderPhotoPath);
  }

  static String? _msStaticPhotoUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    final raw = path.trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    final p = raw.startsWith('/') ? raw.substring(1) : raw;
    return 'https://mangroup.id/ms-static/$p';
  }

  /// Lama kerja dalam tahun penuh berdasarkan `tgl_masuk` (hari jadi belum lewat → tahun − 1).
  int? get yearsOfService {
    if (joinDateRaw == null || joinDateRaw!.isEmpty) return null;
    final start = DateTime.tryParse(joinDateRaw!);
    if (start == null) return null;
    final now = DateTime.now();
    var years = now.year - start.year;
    if (now.month < start.month ||
        (now.month == start.month && now.day < start.day)) {
      years--;
    }
    if (years < 0) return 0;
    return years;
  }
}

final profileDataSourceProvider = Provider<ProfileDataSource>((ref) {
  final apiHelper = ref.watch(apiHelperProvider);
  return ProfileDataSource(apiHelper);
});

final profileApiProvider = FutureProvider<ProfileApiData?>((ref) async {
  final token = ref.watch(authTokenProvider);
  if (token == null || token.isEmpty) return null;

  final ds = ref.watch(profileDataSourceProvider);
  final res = await ds.getProfile();
  final data = (res['data'] is Map)
      ? Map<String, dynamic>.from(res['data'])
      : null;
  if (data == null) return null;

  final dynamic userRaw = data['user'];
  final Map<String, dynamic> user = userRaw is Map
      ? Map<String, dynamic>.from(userRaw)
      : <String, dynamic>{};

  String? pickStr(dynamic v) {
    if (v == null) return null;
    if (v is String) {
      final t = v.trim();
      return t.isEmpty ? null : t;
    }
    if (v is num) {
      if (v is int) return v.toString();
      final d = v as double;
      if (d == d.roundToDouble()) return d.toInt().toString();
      return v.toString();
    }
    final s = v.toString().trim();
    if (s.isEmpty || s == 'null') return null;
    return s;
  }

  /// Backend mengisi `nik` / `employee_id` di `user`, sibling (`profile`, `employee`, …), atau root `data`.
  List<Map<String, dynamic>> collectIdentityMaps() {
    final out = <Map<String, dynamic>>[];
    void pushMap(dynamic raw) {
      if (raw is! Map) return;
      final m = Map<String, dynamic>.from(raw);
      if (m.isNotEmpty) out.add(m);
    }

    pushMap(user);
    for (final key in <String>[
      'profile',
      'employee',
      'pegawai',
      'biodata',
      'karyawan',
      'user_profile',
    ]) {
      pushMap(data[key]);
    }
    final nestedUserProfile = user['profile'];
    if (nestedUserProfile is Map) {
      pushMap(nestedUserProfile);
    }
    pushMap(data);
    return out;
  }

  String? pickFirstFromMaps(
    List<Map<String, dynamic>> maps,
    List<String> keys,
  ) {
    for (final m in maps) {
      for (final k in keys) {
        final s = pickStr(m[k]);
        if (s != null) return s;
      }
    }
    return null;
  }

  final identityMaps = collectIdentityMaps();

  final divisionObj =
      _recordFromObjectOrList(data['division']) ??
      _recordFromObjectOrList(data['riwayat_divisi']);

  final positionObj =
      _recordFromObjectOrList(data['position']) ??
      _recordFromObjectOrList(data['riwayat_jabatan']) ??
      _recordFromObjectOrList(data['riwayat_posisi']);

  final positionTitle =
      pickStr(positionObj?['nm_jabatan']) ??
      pickStr(positionObj?['job_posisi']) ??
      pickStr(user['job_posisi']) ??
      pickStr(user['nm_jabatan']);

  Map<String, dynamic>? leaderMap;
  final leaderRaw = data['leader'] ?? user['leader'];
  if (leaderRaw is Map) {
    leaderMap = Map<String, dynamic>.from(leaderRaw);
  }

  String? roleDisplayName;
  final roleRaw = data['role'];
  if (roleRaw is Map) {
    final rm = Map<String, dynamic>.from(roleRaw);
    roleDisplayName = pickStr(rm['display_name']) ?? pickStr(rm['name']);
  }

  Map<String, dynamic>? firstLokasi;
  final lokasiRaw = data['lokasi'];
  if (lokasiRaw is List && lokasiRaw.isNotEmpty) {
    final first = lokasiRaw.first;
    if (first is Map) {
      firstLokasi = Map<String, dynamic>.from(first);
    }
  }

  String? workSiteName;
  String? workScheduleLine;
  String? workLocationAddress;
  if (firstLokasi != null) {
    workSiteName = pickStr(firstLokasi['nama']) ?? pickStr(firstLokasi['area']);
    final jm = _formatTimeHm(pickStr(firstLokasi['jam_masuk']));
    final jp = _formatTimeHm(pickStr(firstLokasi['jam_plg']));
    if (jm != null && jp != null) {
      workScheduleLine = '$jm – $jp';
    } else {
      workScheduleLine = jm ?? jp;
    }
    workLocationAddress = pickStr(firstLokasi['lokasi']);
  }

  int? teamMemberCount;
  final membersRaw = data['members'];
  if (membersRaw is List && membersRaw.isNotEmpty) {
    teamMemberCount = membersRaw.length;
  }

  String? pickChildCount() {
    final v = pickFirstFromMaps(identityMaps, const [
      'jumlah_anak',
      'jml_anak',
      'jumlahAnak',
    ]);
    if (v != null) return v;
    for (final m in identityMaps) {
      final n = m['jumlah_anak'];
      if (n is num) return n.toInt().toString();
      if (n != null) {
        final p = int.tryParse(n.toString());
        if (p != null) return p.toString();
      }
    }
    return null;
  }

  return ProfileApiData(
    name: pickStr(user['nama']),
    email: pickStr(user['email']),
    phone: pickStr(user['no_hp']),
    nik: pickFirstFromMaps(identityMaps, const [
      'nik',
      'nik_ktp',
      'no_ktp',
      'nip',
    ]),
    employeeId: pickFirstFromMaps(identityMaps, const [
      'employee_id',
      'employeeId',
      'id_employee',
    ]),
    position: positionTitle,
    department: pickStr(divisionObj?['nm_divisi']),
    statusEmployee: pickStr(user['status_employee']),
    joinDateRaw: pickStr(user['tgl_masuk']),
    photoPath: pickStr(user['path']),
    genderRaw: pickFirstFromMaps(identityMaps, const [
      'jk',
      'jenis_kelamin',
      'jenisKelamin',
      'gender',
      'kelamin',
    ]),
    religionRaw: pickFirstFromMaps(identityMaps, const ['agama', 'religion']),
    birthPlace: pickFirstFromMaps(identityMaps, const [
      'tempat_lahir',
      'tempatLahir',
      'birth_place',
    ]),
    birthDateRaw: pickFirstFromMaps(identityMaps, const [
      'tgl_lahir',
      'tanggal_lahir',
      'tglLahir',
      'date_of_birth',
      'dateOfBirth',
    ]),
    domicileAddress: pickFirstFromMaps(identityMaps, const [
      'alamat_dom',
      'alamat_domisili',
      'alamatDomisili',
      'domisili',
    ]),
    ktpAddress: pickFirstFromMaps(identityMaps, const [
      'alamat_ktp',
      'alamatKtp',
      'alamat_ktp_sesuai',
    ]),
    childCountRaw: pickChildCount(),
    emergencyContactName: pickFirstFromMaps(identityMaps, const [
      'nama_kontak_darurat',
      'namaKontakDarurat',
    ]),
    emergencyContactPhone: pickFirstFromMaps(identityMaps, const [
      'no_hp_darurat',
      'noHpDarurat',
      'telp_kontak_darurat',
      'kontak_darurat',
      'telepon_darurat',
    ]),
    maritalStatusRaw:
        pickFirstFromMaps(identityMaps, const [
          'status_perkawinan',
          'statusPerkawinan',
          'status_kawin',
          'marital_status',
        ]) ??
        _maritalFromUserField(pickStr(user['status'])),
    leaderName: leaderMap != null ? pickStr(leaderMap['nama']) : null,
    leaderEmail: leaderMap != null ? pickStr(leaderMap['email']) : null,
    leaderPhone: leaderMap != null ? pickStr(leaderMap['no_hp']) : null,
    leaderPhotoPath: leaderMap != null ? pickStr(leaderMap['path']) : null,
    leaderPosition: leaderMap != null
        ? (pickStr(leaderMap['nm_jabatan']) ?? pickStr(leaderMap['job_posisi']))
        : null,
    roleDisplayName: roleDisplayName,
    workSiteName: workSiteName,
    workScheduleLine: workScheduleLine,
    workLocationAddress: workLocationAddress,
    teamMemberCount: teamMemberCount,
  );
});
