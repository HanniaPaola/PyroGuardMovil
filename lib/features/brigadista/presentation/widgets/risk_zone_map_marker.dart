import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/risk_badge.dart';
import '../../domain/entities/risk_zone.dart';
import '../../../../core/widgets/zone_weather_widget.dart';

/// Tarjeta de zona usada tanto en la lista del mapa (HU01) como en otras
/// vistas que necesiten mostrar resumen de una RiskZone.
class RiskZoneMapMarker extends StatelessWidget {
  final RiskZone zone;
  final VoidCallback onTap;

  const RiskZoneMapMarker({super.key, required this.zone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(zone.riskLevel);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.ash,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.6), blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    zone.municipality,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  ZoneWeatherWidget(zoneId: zone.id),
                ],
              ),
            ),
            RiskBadge(level: zone.riskLevel),
          ],
        ),
      ),
    );
  }
}
