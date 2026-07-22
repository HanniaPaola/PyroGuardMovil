import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/risk_badge.dart';
import '../../domain/entities/push_alert.dart';

/// Item de la lista de historial de alertas (HU06).
class AlertPushTile extends StatelessWidget {
  final PushAlert alert;
  final VoidCallback onTap;

  const AlertPushTile({super.key, required this.alert, required this.onTap});

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.ash,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.fireMid.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.zoneName,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${alert.distanceKm.toStringAsFixed(1)} km · ${_formatDate(alert.receivedAt)}',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            RiskBadge(level: alert.riskLevel),
          ],
        ),
      ),
    );
  }
}
