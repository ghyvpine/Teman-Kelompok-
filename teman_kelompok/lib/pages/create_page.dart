import 'package:flutter/material.dart';
import '../constants.dart';
import '../data.dart';

class CreatePage extends StatefulWidget {
  /// Dipanggil setelah proyek berhasil dipublikasikan (mis. pindah ke tab Cari).
  final VoidCallback? onSelesai;
  const CreatePage({super.key, this.onSelesai});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _namaProyekController = TextEditingController();
  final _matkulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _jumlahAnggotaController = TextEditingController();
  final _skillController = TextEditingController();
  final _deadlineController = TextEditingController();

  @override
  void dispose() {
    _namaProyekController.dispose();
    _matkulController.dispose();
    _deskripsiController.dispose();
    _jumlahAnggotaController.dispose();
    _skillController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  static const _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  Future<void> _pilihTanggal() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final tgl = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (tgl != null) {
      _deadlineController.text = '${tgl.day} ${_bulan[tgl.month - 1]} ${tgl.year}';
    }
  }

  void _publikasikan() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final store = AppStore.instance;
    final jumlah = int.parse(_jumlahAnggotaController.text.trim());
    final namaSaya = store.user.nama.isEmpty ? 'Saya' : store.user.nama;

    store.tambahProyek(Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nama: _namaProyekController.text.trim(),
      matkul: _matkulController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      skill: _skillController.text.trim(),
      deadline: _deadlineController.text.trim(),
      kapasitas: jumlah + 1, // +1 untuk pembuat proyek (ketua)
      members: [Member(namaSaya, 'Ketua Kelompok')],
      milikSaya: true,
    ));

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Proyek baru berhasil dibuat!')));

    _formKey.currentState!.reset();
    for (final c in [
      _namaProyekController,
      _matkulController,
      _deskripsiController,
      _jumlahAnggotaController,
      _skillController,
      _deadlineController,
    ]) {
      c.clear();
    }

    if (widget.onSelesai != null) {
      widget.onSelesai!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  String? _wajib(String? v, String pesan) =>
      (v == null || v.trim().isEmpty) ? pesan : null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Buat Proyek Baru',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Isi detail proyek untuk merekrut anggota.',
                  style: TextStyle(color: context.cMuted)),
              const SizedBox(height: 20),
              _field(context, 'Nama Proyek', 'Contoh: Aplikasi E-Commerce',
                  _namaProyekController,
                  validator: (v) => _wajib(v, 'Nama proyek wajib diisi')),
              _field(context, 'Mata Kuliah', 'Contoh: Pemrograman Web', _matkulController,
                  validator: (v) => _wajib(v, 'Mata kuliah wajib diisi')),
              _field(context, 'Deskripsi Proyek', 'Jelaskan tujuan proyek...',
                  _deskripsiController,
                  maxLines: 3,
                  validator: (v) => _wajib(v, 'Deskripsi wajib diisi')),
              _field(context, 'Jumlah Anggota Dibutuhkan', 'Contoh: 4',
                  _jumlahAnggotaController,
                  keyboard: TextInputType.number,
                  suffixText: 'orang',
                  validator: (v) {
                    final n = int.tryParse(v?.trim() ?? '');
                    if (n == null) return 'Isi dengan angka';
                    if (n < 1 || n > 20) return 'Masukkan 1 sampai 20';
                    return null;
                  }),
              _field(context, 'Skill yang Dibutuhkan', 'Contoh: Flutter, PHP, UI/UX',
                  _skillController,
                  validator: (v) => _wajib(v, 'Skill wajib diisi')),
              _field(context, 'Deadline Pengerjaan', 'Pilih tanggal', _deadlineController,
                  readOnly: true,
                  onTap: _pilihTanggal,
                  suffixIcon: const Icon(Icons.calendar_month_outlined),
                  validator: (v) => _wajib(v, 'Deadline wajib dipilih')),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _publikasikan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Publikasikan Proyek',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboard,
    String? suffixText,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
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
            readOnly: readOnly,
            onTap: onTap,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              suffixText: suffixText,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: context.cSurface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: border(context.cBorder),
              enabledBorder: border(context.cBorder),
              focusedBorder: border(kGreen, 1.6),
              errorBorder: border(Colors.redAccent),
              focusedErrorBorder: border(Colors.redAccent, 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
