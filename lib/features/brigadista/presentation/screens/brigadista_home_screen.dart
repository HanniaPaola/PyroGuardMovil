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
import 'close_intervention_form_screen.dart';
import 'zone_profile_screen.dart';
import 'technical_directive_screen.dart';
import 'brigadista_login_screen.dart';
import '../providers/auth_provider.dart';

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
    final provider = context.watch<BrigadistaProvider>();
    final screens = [
      _BrigadistaHomeTab(),
      RiskMapScreen(),
      AlertHistoryScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.smoke,
      body: screens[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? (provider.activeInterventionZoneId != null
                ? FloatingActionButton.extended(
                    backgroundColor: AppColors.fireGlow,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CloseInterventionFormScreen(),
                        ),
                      );
                    },
                    label: Text(
                      'CERRAR INTERVENCIÓN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: Icon(Icons.fact_check, color: Colors.white),
                  )
                : FloatingActionButton(
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
                  ))
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
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.logout, color: AppColors.textMuted),
                tooltip: 'Cerrar sesión',
                onPressed: () => _confirmLogout(context),
              ),
            ],
          ),
          SizedBox(height: 20),

          SyncStatusBanner(
            isOffline: provider.isOffline,
            pendingCount: provider.pendingSyncCount,
          ),
          SizedBox(height: 16),

          if (provider.activeInterventionZoneId != null) ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.fireMid.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.fireMid),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.fireGlow,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INTERVENCIÓN ACTIVA',
                          style: TextStyle(
                            color: AppColors.fireGlow,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Zona: ${provider.activeInterventionZoneName ?? provider.activeInterventionZoneId}',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],

          // Botón SOS de Emergencia
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            icon: provider.sendingEmergency
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.emergency, size: 28),
            label: Text(
              provider.sendingEmergency ? 'Enviando...' : 'EMERGENCIA SOS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            onPressed: provider.sendingEmergency || provider.isOffline
                ? null
                : () async {
                    final success = await provider.reportEmergency();
                    if (!context.mounted) return;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Ubicación de emergencia enviada exitosamente.',
                          ),
                          backgroundColor: Colors.green.shade700,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error al enviar la emergencia. Intenta de nuevo o usa radio.',
                          ),
                          backgroundColor: Colors.red.shade900,
                        ),
                      );
                    }
                  },
          ),
          SizedBox(height: 24),

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
                    MaterialPageRoute(builder: (_) => AlertHistoryScreen()),
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

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.ash,
        title: Text('Cerrar sesión', style: TextStyle(color: AppColors.white)),
        content: Text(
          '¿Estás seguro de que deseas cerrar tu sesión como brigadista?',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.fireGlow,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => BrigadistaLoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Text('Salir', style: TextStyle(color: AppColors.white)),
          ),
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
