import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';

class Account {
  final String nama;
  final String nim;
  final String jurusan;
  final String email;
  final String passHash;

  const Account({
    required this.nama,
    required this.nim,
    required this.jurusan,
    required this.email,
    required this.passHash,
  });

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'nim': nim,
        'jurusan': jurusan,
        'email': email,
        'passHash': passHash,
      };

  factory Account.fromJson(Map<String, dynamic> j) => Account(
        nama: j['nama'] as String,
        nim: j['nim'] as String,
        jurusan: j['jurusan'] as String,
        email: j['email'] as String,
        passHash: j['passHash'] as String,
      );
}

class AuthResult {
  final String? error;

  /// true kalau gagal daftar karena email/NIM sudah punya akun.
  final bool sudahTerdaftar;
  const AuthResult.ok()
      : error = null,
        sudahTerdaftar = false;
  const AuthResult.gagal(this.error, {this.sudahTerdaftar = false});
  bool get sukses => error == null;
}

/// Akun disimpan di perangkat memakai shared_preferences.
/// Catatan: ini cukup untuk tugas kuliah. Untuk aplikasi sungguhan,
/// autentikasi harus lewat server (mis. Supabase Auth / Firebase Auth).
class AuthService {
  static late SharedPreferences _prefs;
  static final List<Account> _accounts = [];
  static Account? current;

  static bool get isLoggedIn => current != null;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final raw = _prefs.getString('accounts');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _accounts
        ..clear()
        ..addAll(list.map((e) => Account.fromJson(e as Map<String, dynamic>)));
    }

    // Pulihkan sesi login terakhir.
    final email = _prefs.getString('session_email');
    if (email != null) {
      current = _cari(email);
      if (current != null) _sinkronProfil(current!);
    }
  }

  static Account? _cari(String email) {
    final e = email.trim().toLowerCase();
    for (final a in _accounts) {
      if (a.email == e) return a;
    }
    return null;
  }

  static String _hash(String email, String password) =>
      sha256.convert(utf8.encode('${email.trim().toLowerCase()}:$password')).toString();

  /// Kunci penyimpanan data tambahan per akun (telepon, cv, foto).
  static String _k(String jenis, String email) => '${jenis}_$email';

  static void _sinkronProfil(Account a) {
    final store = AppStore.instance;
    store.simpanProfil(
      nama: a.nama,
      nim: a.nim,
      jurusan: a.jurusan,
      email: a.email,
      telepon: _prefs.getString(_k('telepon', a.email)) ?? '',
      cvLink: _prefs.getString(_k('cv', a.email)) ?? '',
    );
    final foto = _prefs.getString(_k('foto', a.email));
    store.setFoto(foto == null ? null : base64Decode(foto));
  }

  static Future<void> _simpanAkun() =>
      _prefs.setString('accounts', jsonEncode(_accounts.map((a) => a.toJson()).toList()));

  static Future<AuthResult> register({
    required String nama,
    required String nim,
    required String jurusan,
    required String email,
    required String password,
  }) async {
    final e = email.trim().toLowerCase();

    if (_cari(e) != null) {
      return const AuthResult.gagal(
          'Email ini sudah terdaftar. Silakan masuk, tidak perlu daftar lagi.',
          sudahTerdaftar: true);
    }
    if (_accounts.any((a) => a.nim == nim.trim())) {
      return const AuthResult.gagal(
          'NIM ini sudah terdaftar. Silakan masuk, tidak perlu daftar lagi.',
          sudahTerdaftar: true);
    }

    final akun = Account(
      nama: nama.trim(),
      nim: nim.trim(),
      jurusan: jurusan.trim(),
      email: e,
      passHash: _hash(e, password),
    );
    _accounts.add(akun);
    await _simpanAkun();

    // Setelah daftar, langsung masuk.
    await _mulaiSesi(akun);
    return const AuthResult.ok();
  }

  static Future<AuthResult> login(String email, String password) async {
    final akun = _cari(email);
    if (akun == null) {
      return const AuthResult.gagal('Akun belum terdaftar. Silakan daftar dulu.');
    }
    if (akun.passHash != _hash(email, password)) {
      return const AuthResult.gagal('Password salah.');
    }
    await _mulaiSesi(akun);
    return const AuthResult.ok();
  }

  static Future<void> _mulaiSesi(Account a) async {
    current = a;
    await _prefs.setString('session_email', a.email);
    _sinkronProfil(a);
  }

  static Future<void> logout() async {
    current = null;
    await _prefs.remove('session_email');
  }

  // ---------------------------------------------------------------------
  // Profil: kontak, data diri, dan foto
  // ---------------------------------------------------------------------

  /// Simpan nomor telepon & link CV supaya form lamaran berikutnya terisi otomatis.
  static Future<void> simpanKontak({
    required String telepon,
    required String cvLink,
  }) async {
    final a = current;
    if (a == null) return;
    await _prefs.setString(_k('telepon', a.email), telepon.trim());
    await _prefs.setString(_k('cv', a.email), cvLink.trim());
    AppStore.instance.simpanProfil(telepon: telepon.trim(), cvLink: cvLink.trim());
  }

  /// Ubah nama, jurusan, dan kontak. NIM dan email tidak bisa diubah.
  static Future<void> updateProfil({
    required String nama,
    required String jurusan,
    required String telepon,
    required String cvLink,
  }) async {
    final a = current;
    if (a == null) return;
    final baru = Account(
      nama: nama.trim(),
      nim: a.nim,
      jurusan: jurusan.trim(),
      email: a.email,
      passHash: a.passHash,
    );
    final i = _accounts.indexWhere((x) => x.email == a.email);
    if (i >= 0) _accounts[i] = baru;
    current = baru;
    await _simpanAkun();
    AppStore.instance.simpanProfil(nama: baru.nama, jurusan: baru.jurusan);
    await simpanKontak(telepon: telepon, cvLink: cvLink);
  }

  /// Simpan foto profil (null = hapus foto). Foto dikecilkan oleh image_picker
  /// sebelum sampai sini, jadi aman disimpan sebagai base64.
  static Future<void> simpanFoto(Uint8List? bytes) async {
    final a = current;
    if (a == null) return;
    if (bytes == null) {
      await _prefs.remove(_k('foto', a.email));
    } else {
      await _prefs.setString(_k('foto', a.email), base64Encode(bytes));
    }
    AppStore.instance.setFoto(bytes);
  }
}
