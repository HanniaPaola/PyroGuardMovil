import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import '../widgets/zone_risk_card.dart';
import '../widgets/weather_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/risk_badge.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import 'zone_map_screen.dart';
import 'alert_history_screen.dart';
import 'weather_screen.dart';
import 'education_screen.dart';
import 'citizen_report_form_screen.dart';
import '../../../brigadista/presentation/screens/brigadista_login_screen.dart';

class CommunityHomeScreen extends StatefulWidget {
  const CommunityHomeScreen({super.key});

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    _HomeTab(),
    ZoneMapScreen(),
    AlertHistoryScreen(),
    EducationScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().loadZones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.smoke,
      body: _screens[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.fireMid,
              icon: Icon(Icons.campaign_outlined, color: AppColors.white),
              label: Text(
                'Reportar',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CitizenReportFormScreen(),
                  ),
                );
              },
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
          selectedLabelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
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
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Aprende',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.smoke,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2D1F0E), AppColors.smoke],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('🔥', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 8),
                          Text(
                            'PyroGuard AI',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Spacer(),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BrigadistaLoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                color: AppColors.fireGlow,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Hola, bienvenido',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Condiciones forestales\ncercanas a ti',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        if (provider.loadingZones)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverToBoxAdapter(
              child: SkeletonList(itemCount: 4, isCard: true),
            ),
          )
        else ...[
          // Banner de reporte ciudadano (acceso público, sin login)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: _CitizenReportBanner(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CitizenReportFormScreen(),
                    ),
                  );
                },
              ),
            ),
          ),

          // Zona más crítica destacada
          if (provider.zones.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: _AlertBanner(
                  zone:
                      provider.zones
                          .where(
                            (z) =>
                                z.riskLevel == 'crítico' ||
                                z.riskLevel == 'alto',
                          )
                          .firstOrNull ??
                      provider.zones.first,
                ),
              ),
            ),
          ],

          // Clima de zona seleccionada
          if (provider.weather != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: WeatherCard(weather: provider.weather!),
              ),
            ),

          // Título de zonas
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
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
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de zonas
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => ZoneRiskCard(
                  zone: provider.zones[i],
                  onTap: () {
                    provider.selectZone(provider.zones[i]);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WeatherScreen(zone: provider.zones[i]),
                      ),
                    );
                  },
                ),
                childCount: provider.zones.length,
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ],
    );
  }
}

class _CitizenReportBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _CitizenReportBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.fireMid.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.fireMid.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.fireMid,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.campaign_outlined,
                color: AppColors.white,
                size: 22,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Ves humo o fuego?',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Reporta el incidente, sin necesidad de iniciar sesión',
                    style: TextStyle(color: AppColors.textDim, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.fireGlow),
          ],
        ),
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final dynamic zone;
  const _AlertBanner({required this.zone});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(zone.riskLevel);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Text(
            zone.riskLevel == 'crítico' ? '🚨' : '⚠️',
            style: TextStyle(fontSize: 28),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RiskBadge(level: zone.riskLevel, large: true),
                SizedBox(height: 6),
                Text(
                  zone.name,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  zone.recommendation,
                  style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
