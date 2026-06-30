import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/risk_badge.dart';
import '../../../../core/widgets/custom_polygon_map.dart';
import '../../../../core/widgets/zone_weather_widget.dart';

class ZoneMapScreen extends StatelessWidget {
  const ZoneMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();

    return Scaffold(
      backgroundColor: AppColors.smoke,
      appBar: AppBar(
        title: const Text('Mapa de Riesgo'),
        backgroundColor: AppColors.smoke,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > 600;

          if (isLandscape) {
            return Row(
              children: [
                const Expanded(
                  flex: 5,
                  child: CustomPolygonMap(height: double.infinity),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader(),
                      Expanded(child: _buildZonesList(provider)),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                const CustomPolygonMap(height: 280),
                _buildHeader(),
                Expanded(child: _buildZonesList(provider)),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: const [
          Text(
            'ZONAS',
            style: TextStyle(
              color: AppColors.fireMid,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          Spacer(),
          Text(
            'Toca una zona para detalles',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZonesList(CommunityProvider provider) {
    if (provider.loadingZones) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.fireMid),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.zones.length,
      itemBuilder: (context, i) {
        final z = provider.zones[i];
        return GestureDetector(
          onTap: () => _showZoneSheet(context, z),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.ash,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.fireMid.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        z.name,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        z.municipality,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      ZoneWeatherWidget(zoneId: z.id),
                    ],
                  ),
                ),
                RiskBadge(level: z.riskLevel),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showZoneSheet(BuildContext context, dynamic zone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ash,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 8),
            Text(
              zone.municipality,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              'Causa principal',
              style: const TextStyle(
                color: AppColors.fireMid,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              zone.mainCause,
              style: const TextStyle(
                color: AppColors.textDim,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Qué hacer',
              style: const TextStyle(
                color: AppColors.fireMid,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              zone.recommendation,
              style: const TextStyle(
                color: AppColors.fireGlow,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}


