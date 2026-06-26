import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/brigadista_provider.dart';
import '../widgets/intervention_history_tile.dart';
import '../../domain/entities/risk_zone.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/risk_badge.dart';
import '../../../../core/widgets/offline_badge.dart';
import '../../../../core/widgets/section_header.dart';

/// HU07: perfil de zona asignada, con historial de las últimas 5
/// intervenciones y riesgo promedio histórico. Disponible offline
/// con datos de la última sincronización.
class ZoneProfileScreen extends StatefulWidget {
  final RiskZone zone;
  const ZoneProfileScreen({super.key, required this.zone});

  @override
  State<ZoneProfileScreen> createState() => _ZoneProfileScreenState();
}

class _ZoneProfileScreenState extends State<ZoneProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrigadistaProvider>().loadZoneInterventions(widget.zone.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrigadistaProvider>();
    final interventions = provider.interventions.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.smoke,
      appBar: AppBar(
        title: const Text('Perfil de Zona'),
        backgroundColor: AppColors.smoke,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: OfflineBadge(isOffline: provider.isOffline)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.ash,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.riskColor(
                  widget.zone.riskLevel,
                ).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.zone.name,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    RiskBadge(level: widget.zone.riskLevel, large: true),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.zone.municipality,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader(
            tag: 'Contexto histórico',
            title: 'Riesgo promedio histórico',
            subtitle: 'Nivel de riesgo mensual registrado en esta zona.',
          ),
          const SizedBox(height: 14),

          // Riesgo promedio histórico simplificado (placeholder de gráfica)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.ash,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.fireMid.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];
                final heights = [30.0, 45.0, 70.0, 90.0, 60.0, 40.0];
                final colors = [
                  AppColors.riskLow,
                  AppColors.riskMedium,
                  AppColors.riskHigh,
                  AppColors.riskCritical,
                  AppColors.riskHigh,
                  AppColors.riskMedium,
                ];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 22,
                      height: heights[i],
                      decoration: BoxDecoration(
                        color: colors[i],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      months[i],
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              const Text(
                'ÚLTIMAS INTERVENCIONES',
                style: TextStyle(
                  color: AppColors.fireMid,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                '${interventions.length} de 5',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (provider.loadingInterventions)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: CircularProgressIndicator(color: AppColors.fireMid),
              ),
            )
          else if (interventions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Sin intervenciones registradas en esta zona.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            ...interventions.map(
              (i) => InterventionHistoryTile(intervention: i),
            ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
