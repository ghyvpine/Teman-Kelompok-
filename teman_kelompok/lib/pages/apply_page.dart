import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../constants.dart';
import '../data.dart';
import '../kontak.dart';

/// Form lamaran: pelamar mengisi kontak supaya ketua proyek bisa menghubungi.
class ApplyPage extends StatefulWidget {
  final Project project;
  const ApplyPage({super.key, required this.project});

  @override
  State<ApplyPage> createState() => _ApplyPageState();
}

class _ApplyPageState extends State<ApplyPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _teleponController;
  late final TextEditingController _cvController;
  final _pesanController = TextEditingController();
  bool _simpanKontak = true;

  @override
  void initState() {
    super.initState();
    // Terisi otomatis kalau sebelumnya sudah pernah disimpan.
    final u = AppStore.instance.user;
    _teleponController = TextEditingController(text: u.telepon);
    _cvController = TextEditingController(text: u.cvLink);
  }

  @override
  void dispose() {
    _teleponController.dispose();
    _cvController.dispose();
    _pesanController.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final store = AppStore.instance;
    final u = store.user;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final ok = store.kirimLamaran(
      widget.project,
      Applicant(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: u.nama.isEmpty ? 'Mahasiswa' : u.nama,
        nim: u.nim,
        jurusan: u.jurusan,
        email: u.email,
        telepon: _teleponController.text.trim(),
        cvLink: _cvController.text.trim(),
        pesan: _pesanController.text.trim(),
      ),
    );

    if (!ok) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Kamu sudah pernah melamar ke proyek ini')));
      navigator.pop();
      return;
    }

    if (_simpanKontak) {
      await AuthService.simpanKontak(
        telepon: _teleponController.text,
        cvLink: _cvController.text,
      );
    }

    messenger.showSnackBar(
        const SnackBar(content: Text('Lamaran terkirim! Tunggu kabar dari ketua proyek.')));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final u = AppStore.instance.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajukan Bergabung', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.cSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.matkul,
                          style: TextStyle(color: context.cAccent, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(p.nama,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        'Pelamar: ${u.nama.isEmpty ? '-' : u.nama}'
                        '${u.nim.isEmpty ? '' : ' · ${u.nim}'}',
                        style: TextStyle(color: context.cBody, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _field(context, 'Nomor WhatsApp / Telepon', '08xxxxxxxxxx', _teleponController,
                    icon: Icons.phone_outlined,
                    keyboard: TextInputType.phone,
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Nomor telepon wajib diisi';
                      if (!teleponValid(t)) return 'Nomor tidak valid (9-15 digit)';
                      return null;
                    }),
                _field(context, 'Link CV / Resume (opsional)',
                    'drive.google.com/... atau linkedin.com/in/...', _cvController,
                    icon: Icons.description_outlined,
                    keyboard: TextInputType.url,
                    validator: (v) => linkValid(v ?? '') ? null : 'Link tidak valid'),
                _field(context, 'Pesan untuk ketua (opsional)',
                    'Ceritakan skill dan alasan kamu ingin bergabung...', _pesanController,
                    maxLines: 4),
                CheckboxListTile(
                  value: _simpanKontak,
                  onChanged: (v) => setState(() => _simpanKontak = v ?? true),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Simpan nomor & link CV untuk lamaran berikutnya',
                      style: TextStyle(fontSize: 13)),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: context.cMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nomor dan CV hanya dilihat ketua proyek ini, dipakai untuk menghubungimu lewat chat.',
                        style: TextStyle(color: context.cMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _kirim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Kirim Lamaran',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    BuildContext context,
    String label,
    String hint,
    TextEditingController controller, {
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c, width: w));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboard,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: icon == null ? null : Icon(icon, size: 20),
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
        ],
      ),
    );
  }
}
