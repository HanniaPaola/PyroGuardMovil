import 'package:flutter/material.dart';
import '../../domain/entities/citizen_report.dart';
import '../../../../core/constants/app_colors.dart';

/// Pantalla de confirmación tras enviar un reporte ciudadano exitosamente.
class CitizenReportSuccessScreen extends StatelessWidget {
  final CitizenReport report;

  const CitizenReportSuccessScreen({super.key, required this.report});

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.smoke,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.fireMid.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.fireMid.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Text('✅', style: TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Reporte enviado',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gracias por ayudar a proteger tu comunidad.\nNuestro equipo revisará tu reporte.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.ash,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.fireMid.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(label: 'ID de reporte', value: report.id ?? '—'),
                    const SizedBox(height: 10),
                    _DetailRow(
                      label: 'Estado',
                      value: report.status ?? 'En revisión',
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      label: 'Fecha',
                      value: _formatDate(report.createdAt),
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      label: 'Ubicación',
                      value:
                          '${report.latitude.toStringAsFixed(4)}, ${report.longitude.toStringAsFixed(4)}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.fireMid,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Volver al inicio',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
