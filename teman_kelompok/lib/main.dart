import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  await ThemeController.instance.init();
  runApp(const TemanKelompokApp());
}

class TemanKelompokApp extends StatelessWidget {
  const TemanKelompokApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = ThemeController.instance;
    // Halaman awal ditentukan sekali saja (sesi login yang tersimpan).
    final Widget awal = AuthService.isLoggedIn ? const HomePage() : const LoginPage();

    // Dengarkan perubahan tema supaya seluruh aplikasi ganti warna seketika.
    return AnimatedBuilder(
      animation: tema,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Teman Kelompok',
          theme: ThemeController.light,
          darkTheme: ThemeController.dark,
          themeMode: tema.mode,
          builder: (context, child) {
            final size = MediaQuery.of(context).size;
            // Di HP asli: tampilkan layar penuh. Di web/desktop: tampilkan bingkai HP.
            if (size.width < 600) return child!;

            return Scaffold(
              backgroundColor: const Color(0xFF0F172A),
              body: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(48),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(38),
                    child: SizedBox(
                      width: 390,
                      height: (size.height - 80).clamp(500.0, 812.0),
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          },
          // Kalau sesi login masih tersimpan, langsung ke Home.
          home: awal,
        );
      },
    );
  }
}
