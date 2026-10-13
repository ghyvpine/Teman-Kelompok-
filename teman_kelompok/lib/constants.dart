import 'package:flutter/material.dart';

const kPrimary = Color(0xFF4F46E5);
const kPrimarySoft = Color(0xFFEEF2FF);
const kGreen = Color(0xFF10B981);
const kAmber = Color(0xFFF59E0B);
const kBorder = Color(0xFFE2E8F0);

// Warna khusus mode gelap.
const kDarkBg = Color(0xFF0F172A);
const kDarkSurface = Color(0xFF1E293B);
const kDarkBorder = Color(0xFF334155);
const kDarkSoft = Color(0xFF312E81);

/// Warna yang otomatis menyesuaikan tema terang/gelap.
/// Pakai `context.cSurface` dst. sebagai pengganti Colors.white / kBorder /
/// kPrimarySoft / Colors.black54 yang sebelumnya ditulis langsung.
extension AppColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Latar kartu, input, dan panel.
  Color get cSurface => isDark ? kDarkSurface : Colors.white;

  /// Garis tepi kartu dan input.
  Color get cBorder => isDark ? kDarkBorder : kBorder;

  /// Latar lembut berwarna indigo (badge, avatar kosong).
  Color get cSoft => isDark ? kDarkSoft : kPrimarySoft;

  /// Warna aksen untuk teks dan ikon (lebih terang di mode gelap).
  Color get cAccent => isDark ? const Color(0xFFA5B4FC) : kPrimary;

  /// Teks sekunder.
  Color get cMuted => isDark ? const Color(0xFF94A3B8) : Colors.black54;

  /// Teks isi.
  Color get cBody => isDark ? const Color(0xFFCBD5E1) : Colors.black87;

  /// Latar tombol yang dinonaktifkan.
  Color get cDisabled => isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
}
