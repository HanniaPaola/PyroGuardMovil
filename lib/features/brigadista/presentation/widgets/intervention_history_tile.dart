import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/risk_badge.dart';
import '../../domain/entities/zone_intervention.dart';

/// Fila de intervención previa en el perfil de zona (HU07).
class InterventionHistoryTile extends StatelessWidget {
  final ZoneIntervention intervention;
  const InterventionHistoryTile({super.key, required this.intervention});

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.ash,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fireMid.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      intervention.brigadeName,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    RiskBadge(level: intervention.riskLevelAtTime),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  '${_formatDate(intervention.date)} · ${intervention.result}',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
