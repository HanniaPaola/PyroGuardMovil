import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/brigadista_provider.dart';
import '../widgets/alert_push_tile.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/section_header.dart';
import 'risk_map_screen.dart';

/// HU06: historial de alertas recibidas, ordenadas por fecha descendente,
/// con persistencia local de al menos 30 días.
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
      context.read<BrigadistaProvider>().loadAlertHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrigadistaProvider>();
    final history = [...provider.alertHistory]
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

    return Scaffold(
      backgroundColor: AppColors.smoke,
      appBar: AppBar(
        title: const Text('Historial de Alertas'),
        backgroundColor: AppColors.smoke,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionHeader(
            tag: 'Historial',
            title: 'Alertas recibidas',
            subtitle:
                'Alertas geolocalizadas de las zonas bajo tu responsabilidad, conservadas 30 días.',
          ),
          const SizedBox(height: 20),

          if (provider.loadingHistory)
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
                  'No hay alertas registradas todavía.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
              ),
            )
          else
            ...history.map(
              (alert) => AlertPushTile(
                alert: alert,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RiskMapScreen()),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
