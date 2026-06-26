import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/brigadista_provider.dart';
import '../widgets/risk_zone_map_marker.dart';
import '../widgets/zone_summary_sheet.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/offline_badge.dart';
import 'technical_directive_screen.dart';
import 'zone_profile_screen.dart';
import '../../../../core/widgets/custom_polygon_map.dart';

/// HU01: mapa de riesgo en tiempo real con indicadores por zona.
/// El widget de mapa es un placeholder listo para integrar
/// Mapbox GL / flutter_map + capa de GPS del dispositivo.
class RiskMapScreen extends StatefulWidget {
  const RiskMapScreen({super.key});

  @override
  State<RiskMapScreen> createState() => _RiskMapScreenState();
}

class _RiskMapScreenState extends State<RiskMapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BrigadistaProvider>();
      if (provider.zones.isEmpty) provider.loadZones();
    });
  }

  void _openZoneSummary(BuildContext context, zone) {
    final provider = context.read<BrigadistaProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ash,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ZoneSummarySheet(
        zone: zone,
        onViewDirective: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TechnicalDirectiveScreen(zone: zone),
            ),
          );
        },
        onViewProfile: () {
          Navigator.pop(context);
          provider.selectZone(zone);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ZoneProfileScreen(zone: zone)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrigadistaProvider>();

    return Scaffold(
      backgroundColor: AppColors.smoke,
      appBar: AppBar(
        title: const Text('Mapa de Riesgo'),
        backgroundColor: AppColors.smoke,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: OfflineBadge(isOffline: provider.isOffline)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Placeholder de mapa interactivo con GPS (criterio 1)
          const CustomPolygonMap(height: 280),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                const Text(
                  'ZONAS MONITOREADAS',
                  style: TextStyle(
                    color: AppColors.fireMid,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '${provider.zones.length} zonas',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: provider.loadingZones
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.fireMid),
                  )
                : RefreshIndicator(
                    color: AppColors.fireMid,
                    backgroundColor: AppColors.ash,
                    onRefresh: provider.loadZones,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.zones.length,
                      itemBuilder: (context, i) {
                        final zone = provider.zones[i];
                        return RiskZoneMapMarker(
                          zone: zone,
                          onTap: () => _openZoneSummary(context, zone),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: AppColors.cream, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
