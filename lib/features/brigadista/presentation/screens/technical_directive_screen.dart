import 'package:flutter/material.dart';
import '../../domain/entities/risk_zone.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/risk_badge.dart';
import '../../../../core/widgets/section_header.dart';

/// HU04: directiva técnica de acción preventiva generada por NLP,
/// alineada a normativas Conafor según el riesgo vigente de la zona.
class TechnicalDirectiveScreen extends StatelessWidget {
  final RiskZone zone;
  const TechnicalDirectiveScreen({super.key, required this.zone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.smoke,
      appBar: AppBar(
        title: const Text('Directiva Técnica'),
        backgroundColor: AppColors.smoke,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  zone.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              RiskBadge(level: zone.riskLevel, large: true),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            zone.municipality,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),

          const SizedBox(height: 24),
          const SectionHeader(
            tag: 'Generado por NLP',
            title: 'Protocolo de acción preventiva',
            subtitle:
                'Recomendaciones técnicas basadas en normativas Conafor y el nivel de riesgo actual de la zona.',
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.ash,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.riskColor(zone.riskLevel).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text('📋', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Directiva vigente',
                      style: TextStyle(
                        color: AppColors.fireMid,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  zone.technicalDirective,
                  style: const TextStyle(
                    color: AppColors.cream,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.smoke,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.update,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Última actualización: ${zone.lastUpdated.day.toString().padLeft(2, '0')}/'
                        '${zone.lastUpdated.month.toString().padLeft(2, '0')}/${zone.lastUpdated.year} '
                        '${zone.lastUpdated.hour.toString().padLeft(2, '0')}:${zone.lastUpdated.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.fireMid.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.fireMid.withOpacity(0.25)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.fireGlow),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Esta directiva se actualiza automáticamente si el nivel de riesgo de la zona cambia.',
                    style: TextStyle(
                      color: AppColors.textDim,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
