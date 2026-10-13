import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../constants.dart';
import '../widgets/app_logo.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _jurusanController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  bool _sembunyikan = true;
  bool _loading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _jurusanController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  Future<void> _daftar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final hasil = await AuthService.register(
      nama: _namaController.text,
      nim: _nimController.text,
      jurusan: _jurusanController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (!hasil.sukses) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(
        content: Text(hasil.error!),
        duration: const Duration(seconds: 5),
        action: hasil.sudahTerdaftar
            ? SnackBarAction(label: 'Masuk', onPressed: () => Navigator.pop(context))
            : null,
      ));
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppLogo(size: 72),
                const SizedBox(height: 12),
                const Text('Buat Akun Baru',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Isi data dirimu untuk mulai mencari teman kelompok.',
                    style: TextStyle(color: context.cMuted)),
                const SizedBox(height: 24),
                _field(context, 'Nama Lengkap', 'Masukkan nama', _namaController,
                    Icons.person_outline,
                    action: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null),
                _field(context, 'NIM', 'Masukkan NIM', _nimController, Icons.badge_outlined,
                    keyboard: TextInputType.number,
                    action: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().length < 5)
                        ? 'NIM minimal 5 digit'
                        : null),
                _field(context, 'Jurusan', 'Teknik Informatika / dll', _jurusanController,
                    Icons.school_outlined,
                    action: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Jurusan wajib diisi' : null),
                _field(context, 'Email', 'nama@student.ac.id', _emailController,
                    Icons.email_outlined,
                    keyboard: TextInputType.emailAddress,
                    action: TextInputAction.next,
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Email wajib diisi';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    }),
                _field(context, 'Password', 'Minimal 6 karakter', _passwordController,
                    Icons.lock_outline,
                    obscure: _sembunyikan,
                    action: TextInputAction.next,
                    suffix: IconButton(
                      icon: Icon(_sembunyikan
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _sembunyikan = !_sembunyikan),
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Password minimal 6 karakter'
                        : null),
                _field(context, 'Konfirmasi Password', 'Ulangi password',
                    _konfirmasiController, Icons.lock_outline,
                    obscure: _sembunyikan,
                    action: TextInputAction.done,
                    onSubmit: (_) => _daftar(),
                    validator: (v) => v != _passwordController.text
                        ? 'Password tidak sama'
                        : null),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _daftar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white))
                        : const Text('Daftar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sudah punya akun?', style: TextStyle(color: context.cMuted)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Masuk',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
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
    TextEditingController controller,
    IconData icon, {
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboard,
    TextInputAction? action,
    ValueChanged<String>? onSubmit,
    String? Function(String?)? validator,
  }) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c, width: w));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboard,
            textInputAction: action,
            onFieldSubmitted: onSubmit,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              suffixIcon: suffix,
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
