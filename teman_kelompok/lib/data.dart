import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class Member {
  final String name;
  final String role;
  const Member(this.name, this.role);
}

enum StatusLamaran { menunggu, diterima, ditolak }

/// Lamaran seseorang untuk bergabung ke sebuah proyek.
/// Kontak (telepon / CV) hanya ditampilkan ke pemilik proyek.
class Applicant {
  final String id;
  final String nama;
  final String nim;
  final String jurusan;
  final String email;
  final String telepon;
  final String cvLink;
  final String pesan;
  final DateTime tanggal;
  StatusLamaran status;

  Applicant({
    required this.id,
    required this.nama,
    required this.nim,
    required this.jurusan,
    required this.email,
    required this.telepon,
    this.cvLink = '',
    this.pesan = '',
    DateTime? tanggal,
    this.status = StatusLamaran.menunggu,
  }) : tanggal = tanggal ?? DateTime.now();
}

class Project {
  final String id;
  final String nama;
  final String matkul;
  final String deskripsi;
  final String skill;
  final String deadline;
  final int kapasitas;
  final List<Member> members;
  final List<Applicant> pelamar;
  final bool milikSaya;

  Project({
    required this.id,
    required this.nama,
    required this.matkul,
    required this.deskripsi,
    required this.skill,
    required this.deadline,
    required this.kapasitas,
    required this.members,
    List<Applicant>? pelamar,
    this.milikSaya = false,
  }) : pelamar = pelamar ?? [];

  int get sisa => kapasitas - members.length;
  bool get penuh => sisa <= 0;

  /// Lamaran milik akun yang sedang login (null kalau belum pernah melamar).
  Applicant? get lamaranSaya {
    final email = AppStore.instance.user.email;
    if (email.isEmpty) return null;
    for (final a in pelamar) {
      if (a.email == email) return a;
    }
    return null;
  }

  int get jumlahMenunggu =>
      pelamar.where((a) => a.status == StatusLamaran.menunggu).length;
}

class UserProfile {
  String nama;
  String nim;
  String jurusan;
  String email;
  String telepon;
  String cvLink;
  Uint8List? foto;
  UserProfile({
    this.nama = '',
    this.nim = '',
    this.jurusan = '',
    this.email = '',
    this.telepon = '',
    this.cvLink = '',
    this.foto,
  });
}

/// Penyimpanan data sementara (in-memory) supaya semua halaman saling terhubung.
class AppStore extends ChangeNotifier {
  AppStore._();
  static final AppStore instance = AppStore._();

  final UserProfile user = UserProfile();

  final List<Project> projects = [
    Project(
      id: 'p1',
      nama: 'Aplikasi Teman Kelompok',
      matkul: 'Pemrograman Perangkat Bergerak',
      deskripsi: 'Membuat aplikasi Flutter responsif untuk tugas akhir semester.',
      skill: 'Flutter, UI/UX',
      deadline: '25 November 2026',
      kapasitas: 5,
      members: [
        const Member('Nazhmi Putra', 'Ketua Kelompok'),
        const Member('Ahmad Fauzi', 'UI/UX Designer'),
        const Member('Siti Rahma', 'Frontend Developer'),
      ],
    ),
    Project(
      id: 'p2',
      nama: 'Sistem Operasional Toko',
      matkul: 'Basis Data Lanjutan',
      deskripsi: 'Optimasi query dan perancangan skema database terintegrasi.',
      skill: 'MySQL, Supabase, ERD',
      deadline: '30 November 2026',
      kapasitas: 4,
      members: [
        const Member('Rina Wulandari', 'Ketua Kelompok'),
        const Member('Dimas Pratama', 'Database Engineer'),
        const Member('Laras Ayu', 'Analis Sistem'),
      ],
    ),
    Project(
      id: 'p3',
      nama: 'Website Katalog UMKM',
      matkul: 'Pemrograman Web',
      deskripsi: 'Membangun website katalog produk UMKM lengkap dengan keranjang belanja.',
      skill: 'HTML, CSS, JavaScript, PHP',
      deadline: '10 Desember 2026',
      kapasitas: 4,
      members: [
        const Member('Budi Santoso', 'Ketua Kelompok'),
        const Member('Intan Permata', 'Backend Developer'),
      ],
    ),
  ];

  /// Proyek yang kubuat atau yang pernah kulamar (apa pun statusnya).
  List<Project> get proyekSaya =>
      projects.where((p) => p.milikSaya || p.lamaranSaya != null).toList();

  void tambahProyek(Project p) {
    projects.insert(0, p);
    notifyListeners();
  }

  /// Kirim lamaran. Mengembalikan false kalau sudah pernah melamar.
  bool kirimLamaran(Project p, Applicant a) {
    if (p.lamaranSaya != null) return false;
    p.pelamar.add(a);
    notifyListeners();
    return true;
  }

  /// Batalkan lamaran milikku (hanya selama masih menunggu).
  void batalkanLamaran(Project p) {
    final a = p.lamaranSaya;
    if (a == null || a.status != StatusLamaran.menunggu) return;
    p.pelamar.remove(a);
    notifyListeners();
  }

  /// Pemilik proyek menerima / menolak pelamar.
  /// Mengembalikan false kalau diterima tapi kelompok sudah penuh.
  bool putuskanLamaran(Project p, Applicant a, {required bool terima}) {
    if (terima) {
      if (p.penuh) return false;
      a.status = StatusLamaran.diterima;
      p.members.add(Member(a.nama, 'Anggota'));
    } else {
      a.status = StatusLamaran.ditolak;
    }
    notifyListeners();
    return true;
  }

  static const _contoh = [
    ['Dewi Anggraini', '2301001', 'Sistem Informasi', 'dewi@student.ac.id', '081234567801'],
    ['Rizky Maulana', '2301002', 'Teknik Informatika', 'rizky@student.ac.id', '081234567802'],
    ['Putri Salsabila', '2301003', 'Desain Komunikasi Visual', 'putri@student.ac.id', '081234567803'],
  ];

  /// Hanya untuk demo: tambah pelamar contoh ke proyekku supaya alur
  /// terima/tolak bisa dicoba tanpa akun kedua.
  bool tambahPelamarContoh(Project p) {
    for (var i = 0; i < _contoh.length; i++) {
      final id = 'demo-${p.id}-$i';
      if (p.pelamar.any((a) => a.id == id)) continue;
      final c = _contoh[i];
      p.pelamar.add(Applicant(
        id: id,
        nama: c[0],
        nim: c[1],
        jurusan: c[2],
        email: c[3],
        telepon: c[4],
        cvLink: 'https://drive.google.com/contoh-cv-${i + 1}',
        pesan: 'Halo kak, saya tertarik bergabung dan siap membantu sesuai skill yang dibutuhkan.',
      ));
      notifyListeners();
      return true;
    }
    return false;
  }

  void simpanProfil({
    String? nama,
    String? nim,
    String? jurusan,
    String? email,
    String? telepon,
    String? cvLink,
  }) {
    if (nama != null) user.nama = nama;
    if (nim != null) user.nim = nim;
    if (jurusan != null) user.jurusan = jurusan;
    if (email != null) user.email = email;
    if (telepon != null) user.telepon = telepon;
    if (cvLink != null) user.cvLink = cvLink;
    notifyListeners();
  }

  void setFoto(Uint8List? bytes) {
    user.foto = bytes;
    notifyListeners();
  }
}
