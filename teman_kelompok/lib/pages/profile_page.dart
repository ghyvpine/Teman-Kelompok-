import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../constants.dart';
import '../data.dart';
import '../foto_profil.dart';
import '../kontak.dart';
import '../widgets/user_avatar.dart';

/// Halaman profil (dibuka dari Pengaturan): lihat data diri, ganti foto,
/// dan ubah nama / jurusan / kontak.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final u = store.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      UserAvatar(
                        radius: 52,
                        tampilkanKamera: true,
                        onTap: () => gantiFotoProfil(context),
                      ),
                      TextButton(
                        onPressed: () => gantiFotoProfil(context),
                        child: const Text('Ganti Foto'),
                      ),
                      Text(u.nama.isEmpty ? 'Mahasiswa' : u.nama,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(u.jurusan.isEmpty ? '-' : u.jurusan,
                          style: TextStyle(color: context.cMuted)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _info(context, Icons.badge_outlined, 'NIM', u.nim),
                _info(context, Icons.school_outlined, 'Jurusan', u.jurusan),
                _info(context, Icons.email_outlined, 'Email', u.email),
                _info(context, Icons.phone_outlined, 'WhatsApp / Telepon', u.telepon),
                _info(context, Icons.description_outlined, 'Link CV / Resume', u.cvLink),
                const SizedBox(height: 4),
                Text(
                  'Nomor dan CV dipakai otomatis saat kamu melamar ke proyek, '
                  'dan hanya dilihat ketua proyek tersebut.',
                  style: TextStyle(color: context.cMuted, fontSize: 12),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _editProfil(context),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Profil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _info(BuildContext context, IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.cAccent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: context.cMuted, fontSize: 12)),
                Text(value.isEmpty ? '-' : value,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editProfil(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => const _EditProfilSheet(),
    );
  }
}

class _EditProfilSheet extends StatefulWidget {
  const _EditProfilSheet();

  @override
  State<_EditProfilSheet> createState() => _EditProfilSheetState();
}

class _EditProfilSheetState extends State<_EditProfilSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _jurusan;
  late final TextEditingController _telepon;
  late final TextEditingController _cv;

  @override
  void initState() {
    super.initState();
    final u = AppStore.instance.user;
    _nama = TextEditingController(text: u.nama);
    _jurusan = TextEditingController(text: u.jurusan);
    _telepon = TextEditingController(text: u.telepon);
    _cv = TextEditingController(text: u.cvLink);
  }

  @override
  void dispose() {
    _nama.dispose();
    _jurusan.dispose();
    _telepon.dispose();
    _cv.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await AuthService.updateProfil(
      nama: _nama.text,
      jurusan: _jurusan.text,
      telepon: _telepon.text,
      cvLink: _cv.text,
    );
    navigator.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Profil diperbarui')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Edit Profil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _field(context, 'Nama Lengkap', _nama,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null),
              _field(context, 'Jurusan', _jurusan,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Jurusan wajib diisi' : null),
              _field(context, 'WhatsApp / Telepon (opsional)', _telepon,
                  keyboard: TextInputType.phone,
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty || teleponValid(t)) return null;
                    return 'Nomor tidak valid (9-15 digit)';
                  }),
              _field(context, 'Link CV / Resume (opsional)', _cv,
                  keyboard: TextInputType.url,
                  validator: (v) => linkValid(v ?? '') ? null : 'Link tidak valid'),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    BuildContext context,
    String label,
    TextEditingController c, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    OutlineInputBorder b(Color col, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: col, width: w));

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: context.cSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: b(context.cBorder),
          enabledBorder: b(context.cBorder),
          focusedBorder: b(kPrimary, 1.6),
          errorBorder: b(Colors.redAccent),
          focusedErrorBorder: b(Colors.redAccent, 1.6),
        ),
      ),
    );
  }
}
