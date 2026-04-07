import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Menyimpan snapshot login Google ke disk (`applicationSupport/google_login/`).
/// Sementara untuk development; nanti bisa diganti sync ke API/database.
class GoogleLoginLocalStorage {
  static const _folderName = 'google_login';
  static const _fileName = 'google_login_session.json';

  Future<Directory> _ensureFolder() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}$_folderName');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _sessionFile() async {
    final dir = await _ensureFolder();
    return File('${dir.path}${Platform.pathSeparator}$_fileName');
  }

  /// Satu file JSON berisi profil Google + token Google + respons API backend.
  /// [revoked_at]: `null` saat aktif login; diisi saat logout lewat [markRevokedAtNow].
  Future<void> saveSession(Map<String, dynamic> payload) async {
    final file = await _sessionFile();
    final withMeta = {
      ...payload,
      'savedAt': DateTime.now().toIso8601String(),
    };
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(withMeta),
    );
  }

  /// Tandai sesi Google dicabut; hapus token dari snapshot yang tersimpan (file tetap ada).
  Future<void> markRevokedAtNow() async {
    final file = await _sessionFile();
    if (!file.existsSync()) return;

    Map<String, dynamic> map;
    try {
      final decoded = jsonDecode(await file.readAsString());
      map = decoded is Map<String, dynamic>
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
    } catch (_) {
      map = <String, dynamic>{};
    }

    map['revoked_at'] = DateTime.now().toIso8601String();
    map['googleAuthentication'] = <String, dynamic>{};
    map['savedAt'] = DateTime.now().toIso8601String();

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(map),
    );
  }

  Future<Map<String, dynamic>?> readSession() async {
    final file = await _sessionFile();
    if (!file.existsSync()) return null;
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  Future<void> clear() async {
    final file = await _sessionFile();
    if (file.existsSync()) await file.delete();
  }
}
