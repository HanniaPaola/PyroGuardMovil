import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Indicador visual de estado offline, reutilizable en cualquier pantalla
/// que dependa de datos cacheados localmente (HU05).
class OfflineBadge extends StatelessWidget {
  final bool isOffline;
  const OfflineBadge({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.cloud_off_rounded, size: 13, color: AppColors.textDim),
          SizedBox(width: 5),
          Text(
            'Sin conexión · datos en caché',
            style: TextStyle(
              color: AppColors.textDim,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
