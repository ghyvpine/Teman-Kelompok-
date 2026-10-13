import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ubah nomor lokal (08xxx) jadi format internasional (628xxx) untuk WhatsApp.
String normalisasiTelepon(String raw) {
  var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (d.startsWith('0')) {
    d = '62${d.substring(1)}';
  } else if (d.startsWith('8')) {
    d = '62$d';
  }
  return d;
}

/// Nomor dianggap valid kalau 9-15 digit (setelah simbol dibuang).
bool teleponValid(String raw) {
  final d = raw.replaceAll(RegExp(r'[^0-9]'), '');
  return d.length >= 9 && d.length <= 15;
}

bool linkValid(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return true; // opsional
  final u = Uri.tryParse(t.contains('://') ? t : 'https://$t');
  return u != null && u.host.contains('.');
}

Future<void> bukaUrl(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  var u = url.trim();
  if (!u.contains('://')) u = 'https://$u';
  try {
    final ok = await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
    if (!ok) throw Exception('gagal membuka');
  } catch (_) {
    await Clipboard.setData(ClipboardData(text: u));
    messenger.showSnackBar(const SnackBar(
        content: Text('Tidak bisa membuka tautan. Tautan disalin ke clipboard.')));
  }
}

Future<void> chatWhatsApp(BuildContext context, String telepon, {String? pesan}) {
  final q = pesan == null ? '' : '?text=${Uri.encodeComponent(pesan)}';
  return bukaUrl(context, 'https://wa.me/${normalisasiTelepon(telepon)}$q');
}

Future<void> salinTeks(BuildContext context, String teks, String label) async {
  final messenger = ScaffoldMessenger.of(context);
  await Clipboard.setData(ClipboardData(text: teks));
  messenger.showSnackBar(SnackBar(content: Text('$label disalin')));
}
