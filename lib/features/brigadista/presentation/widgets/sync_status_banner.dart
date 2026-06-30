import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Banner que informa al brigadista cuántas observaciones están
/// pendientes de sincronizar mientras no hay conexión (HU05).
class SyncStatusBanner extends StatelessWidget {
  final bool isOffline;
  final int pendingCount;

  const SyncStatusBanner({
    super.key,
    required this.isOffline,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline && pendingCount == 0) return const SizedBox.shrink();

    final color = isOffline ? AppColors.fireMid : AppColors.fireGlow;
    final text = isOffline
        ? 'Modo sin conexión · ${pendingCount > 0 ? '$pendingCount registro(s) en cola' : 'usando datos en caché'}'
        : 'Sincronizando $pendingCount registro(s) pendiente(s)...';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.cloud_off_rounded : Icons.sync_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
