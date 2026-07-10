import 'package:flutter/material.dart';
import '../../domain/entities/citizen_report.dart';
import '../../../../core/constants/app_colors.dart';

class CitizenReportTile extends StatelessWidget {
  final CitizenReport report;

  const CitizenReportTile({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.ash,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.fireMid.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.createdAt != null ? _formatDate(report.createdAt!) : '',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(report.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _getStatusColor(report.status).withValues(alpha: 0.3)),
                ),
                child: Text(
                  report.status?.toUpperCase() ?? 'PENDIENTE',
                  style: TextStyle(
                    color: _getStatusColor(report.status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            report.description,
            style: TextStyle(
              color: AppColors.textDim,
              fontSize: 13,
            ),
          ),
          if (report.photoUrl != null) ...[
             const SizedBox(height: 12),
             ClipRRect(
               borderRadius: BorderRadius.circular(8),
               child: Image.network(
                 report.photoUrl!,
                 height: 120,
                 width: double.infinity,
                 fit: BoxFit.cover,
                 errorBuilder: (context, error, stackTrace) => const SizedBox(),
               ),
             ),
          ]
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'atendido':
      case 'resuelto':
        return Colors.green;
      case 'en progreso':
      case 'asignado':
        return Colors.orange;
      default:
        return AppColors.riskCritical;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
