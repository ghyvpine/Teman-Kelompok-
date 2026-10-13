import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

/// Menyimpan pilihan tema (terang / gelap / ikuti sistem) dan mengingatnya
/// walaupun aplikasi ditutup.
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const _key = 'theme_mode';
  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key);
    _mode = ThemeMode.values.firstWhere(
      (m) => m.name == v,
      orElse: () => ThemeMode.light,
    );
  }

  Future<void> setMode(ThemeMode m) async {
    if (m == _mode) return;
    _mode = m;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, m.name);
  }

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final bg = dark ? kDarkBg : const Color(0xFFF8FAFC);
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: ColorScheme.fromSeed(seedColor: kPrimary, brightness: b),
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? kDarkSurface : Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: dark ? kDarkSoft : kPrimarySoft,
      ),
    );
  }
}
