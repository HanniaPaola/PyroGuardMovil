import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import '../widgets/comunicado_tile.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/skeleton_loader.dart';

class AlertHistoryScreen extends StatefulWidget {
  const AlertHistoryScreen({super.key});

  @override
  State<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends State<AlertHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().loadComunicados();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final history = provider.comunicados;

    final totalAlerts = history.length;
    final recientes = history
        .where(
          (c) =>
              c.publishDate.isAfter(DateTime.now().subtract(Duration(days: 7))),
        )
        .length;

    return Scaffold(
      backgroundColor: AppColors.smoke,
      appBar: AppBar(
        title: Text('Comunicados'),
        backgroundColor: AppColors.smoke,
      ),
      body: RefreshIndicator(
        color: AppColors.fireMid,
        backgroundColor: AppColors.ash,
        onRefresh: () async {
          await context.read<CommunityProvider>().loadComunicados();
        },
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            SectionHeader(
              tag: 'Avisos',
              title: 'Comunicados de la zona',
              subtitle:
                  'Mantente informado de los reportes y actualizaciones de protección civil.',
            ),
            SizedBox(height: 24),

            // Estadísticas
            Row(
              children: [
                _StatCard(
                  value: '$totalAlerts',
                  label: 'Comunicados',
                  icon: '🔔',
                ),
                SizedBox(width: 12),
                _StatCard(value: '$recientes', label: 'Recientes', icon: '⚡'),
              ],
            ),
            SizedBox(height: 24),

            Text(
              'REGISTROS',
              style: TextStyle(
                color: AppColors.fireMid,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 12),

            if (provider.loadingComunicados)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: SkeletonList(itemCount: 4, isCard: false),
              )
            else if (history.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No hay comunicados registrados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ),
              )
            else
              ...history.map((a) => ComunicadoTile(comunicado: a)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.ash,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.fireMid.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: TextStyle(fontSize: 22)),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: AppColors.fireGlow,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
