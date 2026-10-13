import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../constants.dart';
import '../data.dart';
import '../foto_profil.dart';
import '../theme_controller.dart';
import '../widgets/app_logo.dart';
import '../widgets/user_avatar.dart';
import 'login_page.dart';
import 'my_projects_page.dart';
import 'profile_page.dart';

/// Tab Pengaturan: profil, tema aplikasi, proyek saya, tentang, dan keluar.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final tema = ThemeController.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([store, tema]),
      builder: (context, _) {
        final u = store.user;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pengaturan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Kartu profil ringkas
              Material(
                color: context.cSurface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const ProfilePage())),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.cBorder),
                    ),
                    child: Row(
                      children: [
                        UserAvatar(
                          radius: 30,
                          tampilkanKamera: true,
                          onTap: () => gantiFotoProfil(context),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.nama.isEmpty ? 'Mahasiswa' : u.nama,
                                  style: const TextStyle(
                                      fontSize: 17, fontWeight: FontWeight.bold)),
                              Text(u.email.isEmpty ? '-' : u.email,
                                  style: TextStyle(color: context.cMuted, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text('Lihat & edit profil',
                                  style: TextStyle(
                                      color: context.cAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: context.cMuted),
                      ],
                    ),
                  ),
                ),
              ),

              _judul(context, 'Tampilan'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: _kartu(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                            context.isDark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            color: context.cAccent),
                        const SizedBox(width: 12),
                        const Text('Tema Aplikasi',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_outlined, size: 18),
                              label: Text('Terang')),
                          ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_outlined, size: 18),
                              label: Text('Gelap')),
                          ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.settings_suggest_outlined, size: 18),
                              label: Text('Sistem')),
                        ],
                        selected: {tema.mode},
                        onSelectionChanged: (s) => tema.setMode(s.first),
                      ),
                    ),
                  ],
                ),
              ),

              _judul(context, 'Akun'),
              Container(
                decoration: _kartu(context),
                child: Column(
                  children: [
                    _tile(context, Icons.person_outline, 'Profil Saya',
                        'Data diri, kontak, dan foto',
                        () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ProfilePage()))),
                    _garis(context),
                    _tile(context, Icons.folder_open_rounded, 'Proyek Saya',
                        '${store.proyekSaya.length} proyek',
                        () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const MyProjectsPage()))),
                  ],
                ),
              ),

              _judul(context, 'Lainnya'),
              Container(
                decoration: _kartu(context),
                child: Column(
                  children: [
                    _tile(context, Icons.info_outline, 'Tentang Aplikasi',
                        'Teman Kelompok v1.0.0', () => _tentang(context)),
                    _garis(context),
                    _tile(context, Icons.logout, 'Keluar', null,
                        () => _konfirmasiKeluar(context),
                        warna: Colors.redAccent),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _kartu(BuildContext context) => BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cBorder),
      );

  Widget _garis(BuildContext context) =>
      Divider(height: 1, indent: 56, color: context.cBorder);

  Widget _judul(BuildContext context, String t) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 8, left: 4),
        child: Text(t,
            style: TextStyle(
                color: context.cMuted, fontSize: 13, fontWeight: FontWeight.w600)),
      );

  Widget _tile(BuildContext context, IconData icon, String judul, String? sub,
      VoidCallback onTap,
      {Color? warna}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: warna ?? context.cAccent),
      title: Text(judul,
          style: TextStyle(fontWeight: FontWeight.w600, color: warna)),
      subtitle: sub == null
          ? null
          : Text(sub, style: TextStyle(color: context.cMuted, fontSize: 12)),
      trailing: warna == null ? Icon(Icons.chevron_right, color: context.cMuted) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  void _tentang(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Teman Kelompok',
      applicationVersion: '1.0.0',
      applicationIcon: const AppLogo(size: 56),
      children: const [
        SizedBox(height: 8),
        Text('Mencari & membentuk kelompok mahasiswa.'),
      ],
    );
  }

  void _konfirmasiKeluar(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu akan kembali ke halaman login.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
