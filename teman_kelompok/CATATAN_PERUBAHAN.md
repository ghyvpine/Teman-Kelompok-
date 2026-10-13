# Catatan perubahan Teman Kelompok

## Cara pasang
1. Salin isi folder ini ke proyek Flutter-mu (timpa `lib/` dan `pubspec.yaml`, tambah folder `assets/`).
2. Jalankan: `flutter pub get`
3. Jalankan ulang aplikasi (stop dulu, lalu run; hot reload tidak cukup karena ada paket & asset baru).

## Pengaturan tambahan per platform
- iOS (`ios/Runner/Info.plist`): tambahkan
  - `NSPhotoLibraryUsageDescription` = "Untuk memilih foto profil"
  - `NSCameraUsageDescription` = "Untuk mengambil foto profil"
- Android: tidak perlu mengubah apa pun.

## File baru
- lib/theme_controller.dart  -> tema terang/gelap/sistem (tersimpan)
- lib/kontak.dart            -> buka WhatsApp / link CV, validasi nomor
- lib/foto_profil.dart       -> menu ganti foto profil
- lib/widgets/app_logo.dart, lib/widgets/user_avatar.dart
- lib/pages/settings_page.dart -> tab Pengaturan (menggantikan tab Profil)
- lib/pages/apply_page.dart  -> form lamaran (nomor telepon, link CV, pesan)
- assets/images/logo_icon.png (emblem), logo_full.jpg (logo lengkap)

## File yang diubah
constants, data, auth_service, main, home, login, register, create, search,
detail, my_projects, profile (sekarang halaman dalam Pengaturan).

## Catatan
- Tombol "Tambah pelamar contoh (demo)" di detail proyek milikmu hanya untuk
  mencoba alur terima/tolak tanpa akun kedua. Hapus dua blok `TextButton.icon`
  di `_bagianPelamar` (detail_page.dart) dan fungsi `tambahPelamarContoh`
  (data.dart) kalau tidak diperlukan.
- Data proyek & lamaran masih in-memory (hilang saat aplikasi ditutup), sama
  seperti sebelumnya. Foto, nomor, CV, dan tema tersimpan di perangkat.
