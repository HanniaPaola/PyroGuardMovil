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
import '../../../../core/widgets/skeleton_loader.dart';

/// HU01: mapa de riesgo en tiempo real con indicadores por zona.
/// El widget de mapa es un placeholder listo para integrar
/// Mapbox GL / flutter_map + capa de GPS del dispositivo.
class RiskMapScreen extends StatefulWidget {
  const RiskMapScreen({super.key});

  @override
  State<RiskMapScreen> createState() => _RiskMapScreenState();
}

class _RiskMapScreenState extends State<RiskMapScreen> {
  bool _showZones = false;
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
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(child: OfflineBadge(isOffline: provider.isOffline)),
          ),
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
            height: isLandscape
                ? null
                : MediaQuery.of(context).size.height * 0.6,
            width: isLandscape ? 340 : screenWidth - 32,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.smoke.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.fireMid.withValues(alpha: 0.2),
                ),
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
                  _buildHeader(provider),
                  Expanded(child: _buildZonesList(provider, null)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BrigadistaProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Text(
            'ZONAS MONITOREADAS',
            style: TextStyle(
              color: AppColors.fireMid,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          Spacer(),
          Text(
            '${provider.zones.length} zonas',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildZonesList(
    BrigadistaProvider provider,
    ScrollController? scrollController,
  ) {
    if (provider.loadingZones) {
      return const SkeletonList(itemCount: 4, isCard: true);
    }
    return RefreshIndicator(
      color: AppColors.fireMid,
      backgroundColor: AppColors.ash,
      onRefresh: provider.loadZones,
      child: ListView.builder(
        controller: scrollController,
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
    );
  }
}
