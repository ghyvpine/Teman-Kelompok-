import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../constants.dart';
import '../widgets/app_logo.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _sembunyikan = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final hasil = await AuthService.login(_emailController.text, _passwordController.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (!hasil.sukses) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(hasil.error!)));
      return;
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Center(child: AppLogo(size: 150)),
                const SizedBox(height: 12),
                const Center(
                  child: Text('Teman Kelompok',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: kPrimary)),
                ),
                Center(
                  child: Text('Mencari & Membentuk Kelompok Mahasiswa',
                      style: TextStyle(fontSize: 12, color: context.cMuted)),
                ),
                const SizedBox(height: 28),
                const Text('Selamat Datang Kembali!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Masuk untuk melanjutkan mencari teman kelompok.',
                    style: TextStyle(color: context.cMuted)),
                const SizedBox(height: 28),
                _label('Email'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _dekor(context, 'nama@student.ac.id', Icons.email_outlined),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Email wajib diisi';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _label('Password'),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _sembunyikan,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _masuk(),
                  decoration:
                      _dekor(context, 'Masukkan password', Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_sembunyikan
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _sembunyikan = !_sembunyikan),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _masuk,
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
                        : const Text('Masuk',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Belum punya akun?', style: TextStyle(color: context.cMuted)),
                    TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const RegisterPage())),
                      child: const Text('Daftar',
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

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      );

  InputDecoration _dekor(BuildContext context, String hint, IconData icon) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c, width: w));
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: context.cSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: b(context.cBorder),
      enabledBorder: b(context.cBorder),
      focusedBorder: b(kPrimary, 1.6),
      errorBorder: b(Colors.redAccent),
      focusedErrorBorder: b(Colors.redAccent, 1.6),
    );
  }
}
