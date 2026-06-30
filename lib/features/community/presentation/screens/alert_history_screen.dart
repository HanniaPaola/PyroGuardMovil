import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import '../widgets/comunicado_tile.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/section_header.dart';

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
    final recientes = history.where((c) => c.publishDate.isAfter(DateTime.now().subtract(const Duration(days: 7)))).length;

    return Scaffold(
      backgroundColor: AppColors.smoke,
      appBar: AppBar(
        title: const Text('Comunicados'),
        backgroundColor: AppColors.smoke,
      ),
      body: RefreshIndicator(
        color: AppColors.fireMid,
        backgroundColor: AppColors.ash,
        onRefresh: () async {
          await context.read<CommunityProvider>().loadComunicados();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SectionHeader(
              tag: 'Avisos',
              title: 'Comunicados de la zona',
              subtitle:
                  'Mantente informado de los reportes y actualizaciones de protección civil.',
            ),
            const SizedBox(height: 24),

            // Estadísticas
            Row(
              children: [
                _StatCard(
                  value: '$totalAlerts',
                  label: 'Comunicados',
                  icon: '🔔',
                ),
                const SizedBox(width: 12),
                _StatCard(
                  value: '$recientes',
                  label: 'Recientes',
                  icon: '⚡',
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'REGISTROS',
              style: TextStyle(
                color: AppColors.fireMid,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            if (provider.loadingComunicados)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.fireMid),
                ),
              )
            else if (history.isEmpty)
              const Center(
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.ash,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.fireMid.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.fireGlow,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
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
