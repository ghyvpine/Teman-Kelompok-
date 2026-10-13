import 'package:flutter/material.dart';
import '../constants.dart';
import '../data.dart';
import '../kontak.dart';
import 'apply_page.dart';

class DetailPage extends StatelessWidget {
  final Project project;
  const DetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final p = project;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Proyek', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.matkul,
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(p.nama,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip(Icons.code, p.skill),
                          if (p.deadline.isNotEmpty) _chip(Icons.event, p.deadline),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Deskripsi Proyek',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(p.deskripsi, style: TextStyle(color: context.cBody, height: 1.4)),
                const SizedBox(height: 24),
                Text('Anggota yang Sudah Bergabung (${p.members.length}/${p.kapasitas})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                for (final m in p.members) _memberTile(context, m),
                const SizedBox(height: 24),
                if (p.milikSaya)
                  _bagianPelamar(context, p, store)
                else ...[
                  _statusLamaran(context, p),
                  _actionButton(context, p, store),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Sisi pelamar
  // ---------------------------------------------------------------------

  Widget _statusLamaran(BuildContext context, Project p) {
    final l = p.lamaranSaya;
    if (l == null) return const SizedBox.shrink();

    String teks;
    Color warna;
    IconData ikon;
    switch (l.status) {
      case StatusLamaran.menunggu:
        teks = 'Lamaranmu sedang ditinjau ketua proyek. Kamu akan dihubungi lewat ${l.telepon}.';
        warna = kAmber;
        ikon = Icons.hourglass_top_rounded;
      case StatusLamaran.diterima:
        teks = 'Selamat! Lamaranmu diterima, kamu sudah menjadi anggota kelompok ini.';
        warna = kGreen;
        ikon = Icons.check_circle_outline;
      case StatusLamaran.ditolak:
        teks = 'Maaf, lamaranmu belum diterima untuk proyek ini.';
        warna = Colors.redAccent;
        ikon = Icons.cancel_outlined;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: warna.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warna.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: warna, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(teks, style: TextStyle(color: context.cBody, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, Project p, AppStore store) {
    final messenger = ScaffoldMessenger.of(context);
    final l = p.lamaranSaya;

    String label;
    VoidCallback? onTap;
    Color color = kPrimary;

    if (l == null) {
      if (p.penuh) {
        label = 'Anggota Sudah Penuh';
        onTap = null;
      } else {
        label = 'Ajukan Bergabung';
        onTap = () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => ApplyPage(project: p)));
      }
    } else if (l.status == StatusLamaran.menunggu) {
      label = 'Batalkan Pengajuan';
      color = Colors.redAccent;
      onTap = () {
        store.batalkanLamaran(p);
        messenger.showSnackBar(const SnackBar(content: Text('Pengajuan dibatalkan')));
      };
    } else if (l.status == StatusLamaran.diterima) {
      label = 'Kamu Sudah Bergabung';
      onTap = null;
    } else {
      label = 'Pengajuan Ditolak';
      onTap = null;
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: context.cDisabled,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Sisi pemilik proyek
  // ---------------------------------------------------------------------

  Widget _bagianPelamar(BuildContext context, Project p, AppStore store) {
    final daftar = [...p.pelamar]..sort((a, b) {
        // Yang masih menunggu tampil paling atas.
        final sa = a.status == StatusLamaran.menunggu ? 0 : 1;
        final sb = b.status == StatusLamaran.menunggu ? 0 : 1;
        return sa != sb ? sa - sb : b.tanggal.compareTo(a.tanggal);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pelamar (${p.pelamar.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Hubungi pelamar lewat WhatsApp, lalu terima atau tolak lamarannya.',
            style: TextStyle(color: context.cMuted, fontSize: 12)),
        const SizedBox(height: 12),
        if (daftar.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.cBorder),
            ),
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, size: 40, color: context.cMuted.withOpacity(0.6)),
                const SizedBox(height: 8),
                Text('Belum ada yang melamar',
                    style: TextStyle(color: context.cMuted)),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => store.tambahPelamarContoh(p),
                  icon: const Icon(Icons.science_outlined, size: 18),
                  label: const Text('Tambah pelamar contoh (demo)'),
                ),
              ],
            ),
          )
        else
          for (final a in daftar) _pelamarCard(context, p, a, store),
        if (daftar.isNotEmpty && daftar.length < 3)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => store.tambahPelamarContoh(p),
              icon: const Icon(Icons.science_outlined, size: 18),
              label: const Text('Tambah pelamar contoh (demo)'),
            ),
          ),
      ],
    );
  }

  Widget _pelamarCard(BuildContext context, Project p, Applicant a, AppStore store) {
    final messenger = ScaffoldMessenger.of(context);

    Color warna;
    String status;
    switch (a.status) {
      case StatusLamaran.menunggu:
        warna = kAmber;
        status = 'Menunggu';
      case StatusLamaran.diterima:
        warna = kGreen;
        status = 'Diterima';
      case StatusLamaran.ditolak:
        warna = Colors.redAccent;
        status = 'Ditolak';
    }

    final info = [a.nim, a.jurusan].where((e) => e.isNotEmpty).join(' · ');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: context.cSoft,
                child: Icon(Icons.person, color: context.cAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (info.isNotEmpty)
                      Text(info, style: TextStyle(color: context.cMuted, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: warna.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status,
                    style: TextStyle(
                        color: warna, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          if (a.pesan.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('"${a.pesan}"',
                style: TextStyle(
                    color: context.cBody, fontSize: 13, fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 16, color: context.cMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(a.telepon,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              IconButton(
                tooltip: 'Salin nomor',
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.copy_rounded, size: 18, color: context.cMuted),
                onPressed: () => salinTeks(context, a.telepon, 'Nomor'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => chatWhatsApp(
                  context,
                  a.telepon,
                  pesan:
                      'Halo ${a.nama}, saya ketua proyek "${p.nama}" di Teman Kelompok. '
                      'Terima kasih sudah melamar, boleh kita diskusi dulu?',
                ),
                icon: const Icon(Icons.chat_outlined, size: 18),
                label: const Text('Chat WhatsApp'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kGreen,
                  side: const BorderSide(color: kGreen),
                ),
              ),
              if (a.cvLink.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () => bukaUrl(context, a.cvLink),
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('Lihat CV'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.cAccent,
                    side: BorderSide(color: context.cAccent),
                  ),
                ),
            ],
          ),
          if (a.status == StatusLamaran.menunggu) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      store.putuskanLamaran(p, a, terima: false);
                      messenger.showSnackBar(
                          SnackBar(content: Text('Lamaran ${a.nama} ditolak')));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    child: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final ok = store.putuskanLamaran(p, a, terima: true);
                      messenger.showSnackBar(SnackBar(
                          content: Text(ok
                              ? '${a.nama} resmi bergabung ke kelompok'
                              : 'Kelompok sudah penuh, tidak bisa menerima lagi')));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Terima'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
              child: Text(text,
                  style: const TextStyle(color: Colors.white, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _memberTile(BuildContext context, Member m) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: context.cSoft,
            child: Icon(Icons.person, color: context.cAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(m.role, style: TextStyle(color: context.cMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
