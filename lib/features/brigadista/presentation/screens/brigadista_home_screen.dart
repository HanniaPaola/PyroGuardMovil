import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/brigadista_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/offline_badge.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../widgets/sync_status_banner.dart';
import '../widgets/risk_zone_map_marker.dart';
import 'risk_map_screen.dart';
import 'alert_history_screen.dart';
import 'field_observation_form_screen.dart';
import 'zone_profile_screen.dart';
import 'technical_directive_screen.dart';


/// Home del módulo Brigadista. Punto central tras el login, con acceso
/// rápido a mapa de riesgo, formulario de campo e historial de alertas.
class BrigadistaHomeScreen extends StatefulWidget {
  const BrigadistaHomeScreen({super.key});

  @override
  State<BrigadistaHomeScreen> createState() => _BrigadistaHomeScreenState();
}

class _BrigadistaHomeScreenState extends State<BrigadistaHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrigadistaProvider>().loadZones();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _BrigadistaHomeTab(),
      RiskMapScreen(),
      AlertHistoryScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.smoke,
      body: screens[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.fireMid,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FieldObservationFormScreen(),
                  ),
                );
              },
              child: Icon(
                Icons.note_add_outlined,
                color: AppColors.white,
              ),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Color(0x1AFF6A00))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: AppColors.ash,
          selectedItemColor: AppColors.fireGlow,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Historial',
            ),
          ],
        ),
      ),
    );
  }
}

class _BrigadistaHomeTab extends StatelessWidget {
  const _BrigadistaHomeTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrigadistaProvider>();
    final criticalZones = provider.zones
        .where((z) => z.riskLevel == 'crítico' || z.riskLevel == 'alto')
        .toList();

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Text('🧑‍🚒', style: TextStyle(fontSize: 26)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Panel del Brigadista',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              OfflineBadge(isOffline: provider.isOffline),
            ],
          ),
          SizedBox(height: 20),

          SyncStatusBanner(
            isOffline: provider.isOffline,
            pendingCount: provider.pendingSyncCount,
          ),

          SectionHeader(
            tag: 'Zonas prioritarias',
            title: 'Atención inmediata',
            subtitle: 'Zonas con riesgo alto o crítico cerca de tu posición.',
          ),
          SizedBox(height: 16),

          if (provider.loadingZones)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: SkeletonList(itemCount: 3, isCard: true),
            )
          else if (criticalZones.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'No hay zonas críticas en este momento.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            ...criticalZones.map(
              (z) => RiskZoneMapMarker(
                zone: z,
                onTap: () {
                  provider.selectZone(z);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TechnicalDirectiveScreen(zone: z),
                    ),
                  );
                },
              ),
            ),

          SizedBox(height: 24),
          Text(
            'ACCESOS RÁPIDOS',
            style: TextStyle(
              color: AppColors.fireMid,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.map_outlined,
                  label: 'Mapa de riesgo',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RiskMapScreen()),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.fact_check_outlined,
                  label: 'Nueva observación',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FieldObservationFormScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.history_outlined,
                  label: 'Historial de alertas',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AlertHistoryScreen(),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.assignment_outlined,
                  label: 'Perfil de zona',
                  onTap: () {
                    if (provider.zones.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ZoneProfileScreen(
                            zone: provider.selectedZone ?? provider.zones.first,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.ash,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.fireMid.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.fireGlow, size: 22),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: AppColors.cream,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
