import 'package:flutter/material.dart';
import '../constants.dart';
import '../data.dart';
import '../widgets/app_logo.dart';
import '../widgets/user_avatar.dart';
import 'search_page.dart';
import 'create_page.dart';
import 'detail_page.dart';
import 'my_projects_page.dart';
import 'settings_page.dart';

/// Kerangka utama: bottom navigation berpindah halaman.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  void _pindah(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(onPindah: _pindah),
      const SearchPage(),
      CreatePage(onSelesai: () => _pindah(1)),
      const SettingsPage(),
    ];

    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _pindah,
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: kPrimary),
              label: 'Home'),
          const NavigationDestination(
              icon: Icon(Icons.search),
              selectedIcon: Icon(Icons.search, color: kPrimary),
              label: 'Cari'),
          const NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle, color: kPrimary),
              label: 'Buat'),
          const NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: kPrimary),
              label: 'Pengaturan'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final ValueChanged<int> onPindah;
  const _HomeTab({required this.onPindah});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final nama = store.user.nama.isEmpty ? 'Mahasiswa' : store.user.nama.split(' ').first;
        final rekomendasi = store.projects.where((p) => !p.milikSaya && !p.penuh).take(3).toList();
        final butuhTindakan =
            store.projects.where((p) => p.milikSaya).fold<int>(0, (n, p) => n + p.jumlahMenunggu);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppLogo(size: 36),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Teman Kelompok',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: Badge(
                      isLabelVisible: butuhTindakan > 0,
                      label: Text('$butuhTindakan'),
                      child: const Icon(Icons.notifications_none_rounded),
                    ),
                    onPressed: () {
                      final pesan = butuhTindakan > 0
                          ? '$butuhTindakan pelamar menunggu keputusanmu di Proyek Saya'
                          : 'Belum ada notifikasi baru';
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(pesan)));
                    },
                  ),
                  UserAvatar(radius: 20, onTap: () => onPindah(3)),
                ],
              ),
              const SizedBox(height: 20),
              Text('Halo, $nama! 👋',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Temukan rekan tim terbaik untuk tugas kuliahmu.',
                  style: TextStyle(color: context.cMuted)),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  _menuCard(context, 'Cari Kelompok', 'Jelajahi Proyek',
                      Icons.search_rounded, kPrimary, () => onPindah(1)),
                  _menuCard(context, 'Buat Proyek', 'Rekrut Anggota',
                      Icons.add_box_rounded, kGreen, () => onPindah(2)),
                  _menuCard(context, 'Proyek Saya', '${store.proyekSaya.length} Aktif',
                      Icons.folder_open_rounded, kAmber, () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MyProjectsPage()));
                  }),
                  _menuCard(context, 'Pengaturan', 'Profil & Tema',
                      Icons.settings_outlined, const Color(0xFF6366F1), () => onPindah(3)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Rekomendasi Proyek',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () => onPindah(1), child: const Text('Lihat Semua')),
                ],
              ),
              const SizedBox(height: 8),
              if (rekomendasi.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                      child: Text('Belum ada proyek untuk direkomendasikan.',
                          style: TextStyle(color: context.cMuted))),
                )
              else
                for (final p in rekomendasi) _projectCard(context, p),
            ],
          ),
        );
      },
    );
  }

  Widget _menuCard(BuildContext context, String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return Material(
      color: context.cSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.cBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.14),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(subtitle, style: TextStyle(color: context.cMuted, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _projectCard(BuildContext context, Project p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => DetailPage(project: p))),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.cBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.matkul,
                    style: TextStyle(
                        color: context.cAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(p.nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: context.cSoft, borderRadius: BorderRadius.circular(20)),
                      child: Text('Butuh ${p.sisa} anggota',
                          style: TextStyle(
                              fontSize: 12,
                              color: context.cAccent,
                              fontWeight: FontWeight.w600)),
                    ),
                    Text(p.skill, style: TextStyle(fontSize: 12, color: context.cMuted)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
