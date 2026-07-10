import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/risk_badge.dart';
import '../../../../core/widgets/custom_polygon_map.dart';
import '../../../../core/widgets/zone_weather_widget.dart';
import '../../../../core/widgets/skeleton_loader.dart';

class ZoneMapScreen extends StatefulWidget {
  const ZoneMapScreen({super.key});

  @override
  State<ZoneMapScreen> createState() => _ZoneMapScreenState();
}

class _ZoneMapScreenState extends State<ZoneMapScreen> {
  bool _showZones = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = screenWidth > 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.smoke,
      appBar: AppBar(
        title: const Text(
          'Mapa de Riesgo',
          style: TextStyle(
            color: Colors.white,
            shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () {
              setState(() {
                _showZones = !_showZones;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPolygonMap(height: double.infinity),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _showZones ? 100 : -MediaQuery.of(context).size.height,
            right: 16,
            bottom: isLandscape ? 16 : null,
            height: isLandscape ? null : MediaQuery.of(context).size.height * 0.6,
            width: isLandscape ? 340 : screenWidth - 32,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.smoke.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.fireMid.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  Expanded(child: _buildZonesList(provider, null)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
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

  Widget _buildZonesList(CommunityProvider provider, ScrollController? scrollController) {
    if (provider.loadingZones) {
      return const SkeletonList(itemCount: 4, isCard: true);
    }
    return ListView.builder(
      controller: scrollController,
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
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        z.municipality,
                        style: TextStyle(
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
                    style: TextStyle(
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
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            SizedBox(height: 16),
            Text(
              'Causa principal',
              style: TextStyle(
                color: AppColors.fireMid,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 6),
            Text(
              zone.mainCause,
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Qué hacer',
              style: TextStyle(
                color: AppColors.fireMid,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 6),
            Text(
              zone.recommendation,
              style: TextStyle(
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


