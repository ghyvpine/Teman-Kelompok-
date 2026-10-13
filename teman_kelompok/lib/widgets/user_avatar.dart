import 'package:flutter/material.dart';
import '../constants.dart';
import '../data.dart';

/// Avatar akun yang sedang login: menampilkan foto profil kalau ada,
/// kalau tidak ada tampil ikon orang.
class UserAvatar extends StatelessWidget {
  final double radius;
  final VoidCallback? onTap;

  /// Tampilkan lencana kamera kecil (penanda bahwa foto bisa diganti).
  final bool tampilkanKamera;

  const UserAvatar({
    super.key,
    this.radius = 20,
    this.onTap,
    this.tampilkanKamera = false,
  });

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final foto = store.user.foto;
        final avatar = CircleAvatar(
          radius: radius,
          backgroundColor: context.cSoft,
          backgroundImage: foto == null ? null : MemoryImage(foto),
          child: foto == null
              ? Icon(Icons.person, size: radius * 1.1, color: context.cAccent)
              : null,
        );

        Widget w = avatar;
        if (tampilkanKamera) {
          w = Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                ),
              ),
            ],
          );
        }
        return onTap == null ? w : GestureDetector(onTap: onTap, child: w);
      },
    );
  }
}
