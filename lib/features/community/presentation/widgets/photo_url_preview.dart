import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Vista previa de la imagen cuando el ciudadano pega una URL de foto.
/// Si la URL no carga, se muestra un fallback silencioso (sin crash).
class PhotoUrlPreview extends StatelessWidget {
  final String url;

  const PhotoUrlPreview({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.ash,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fireMid.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.fireMid,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textMuted,
                  size: 28,
                ),
                SizedBox(height: 6),
                Text(
                  'No se pudo cargar la imagen',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
