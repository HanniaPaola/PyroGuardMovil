import 'package:flutter/material.dart';
import '../../domain/entities/alert_history.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/risk_badge.dart';

class AlertHistoryTile extends StatelessWidget {
  final AlertHistory alert;

  const AlertHistoryTile({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final duration = alert.duration;
    final durationText = duration != null
        ? '${duration.inHours}h de duración'
        : 'En curso';

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.ash,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.fireMid.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.riskColor(alert.riskLevel),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatDate(alert.startDate),
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    RiskBadge(level: alert.riskLevel),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  durationText,
                  style: TextStyle(color: AppColors.textDim, fontSize: 13),
                ),
                if (alert.derivedToBrigade) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 12,
                        color: AppColors.fireMid,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Brigada despachada',
                        style: TextStyle(
                          color: AppColors.fireMid,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
