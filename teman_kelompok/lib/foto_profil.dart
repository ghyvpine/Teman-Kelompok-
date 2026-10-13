import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_service.dart';
import 'data.dart';

bool get _kameraTersedia =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Menu ganti foto profil: galeri, kamera (hanya di HP), atau hapus foto.
Future<void> gantiFotoProfil(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);

  final pilihan = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Pilih dari galeri'),
            onTap: () => Navigator.pop(ctx, 'galeri'),
          ),
          if (_kameraTersedia)
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil foto'),
              onTap: () => Navigator.pop(ctx, 'kamera'),
            ),
          if (AppStore.instance.user.foto != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Hapus foto', style: TextStyle(color: Colors.redAccent)),
              onTap: () => Navigator.pop(ctx, 'hapus'),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (pilihan == null) return;

  try {
    if (pilihan == 'hapus') {
      await AuthService.simpanFoto(null);
      messenger.showSnackBar(const SnackBar(content: Text('Foto profil dihapus')));
      return;
    }

    // Foto dikecilkan dulu supaya hemat penyimpanan.
    final file = await ImagePicker().pickImage(
      source: pilihan == 'kamera' ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 80,
    );
    if (file == null) return;

    await AuthService.simpanFoto(await file.readAsBytes());
    messenger.showSnackBar(const SnackBar(content: Text('Foto profil diperbarui')));
  } catch (_) {
    messenger.showSnackBar(
        const SnackBar(content: Text('Tidak bisa mengambil foto. Coba lagi.')));
  }
}
