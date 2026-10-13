import 'package:flutter/material.dart';
import '../constants.dart';
import '../data.dart';
import 'detail_page.dart';

class MyProjectsPage extends StatelessWidget {
  const MyProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyek Saya', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final list = store.proyekSaya;
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_open_rounded,
                        size: 56, color: context.cMuted.withOpacity(0.6)),
                    const SizedBox(height: 12),
                    const Text('Belum ada proyek',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Buat proyek baru atau ajukan bergabung ke proyek lain.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.cMuted)),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final p = list[i];

              String status;
              Color warna;
              if (p.milikSaya) {
                final n = p.jumlahMenunggu;
                status = n > 0 ? 'Pemilik · $n pelamar baru' : 'Pemilik';
                warna = kGreen;
              } else {
                switch (p.lamaranSaya!.status) {
                  case StatusLamaran.diterima:
                    status = 'Diterima';
                    warna = kGreen;
                  case StatusLamaran.ditolak:
                    status = 'Ditolak';
                    warna = Colors.redAccent;
                  case StatusLamaran.menunggu:
                    status = 'Menunggu persetujuan';
                    warna = kAmber;
                }
              }

              return Material(
                color: context.cSurface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => DetailPage(project: p))),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.cBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.matkul,
                                  style: TextStyle(
                                      color: context.cAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(p.nama,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: warna.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(status,
                                    style: TextStyle(
                                        color: warna,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: context.cMuted),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
