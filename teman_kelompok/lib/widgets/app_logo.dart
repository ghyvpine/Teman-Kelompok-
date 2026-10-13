import 'package:flutter/material.dart';
import '../constants.dart';

/// Logo Teman Kelompok (emblem bulat). Kalau file gambarnya belum ada,
/// otomatis memakai ikon cadangan supaya aplikasi tidak error.
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: context.cSoft, shape: BoxShape.circle),
        child: Icon(Icons.group_work_rounded, size: size * 0.55, color: context.cAccent),
      ),
    );
  }
}
