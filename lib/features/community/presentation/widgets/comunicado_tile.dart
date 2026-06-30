import 'package:flutter/material.dart';
import '../../domain/entities/comunicado.dart';
import '../../../../core/constants/app_colors.dart';

class ComunicadoTile extends StatelessWidget {
  final Comunicado comunicado;

  const ComunicadoTile({super.key, required this.comunicado});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
                  _formatDate(comunicado.publishDate),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const Icon(Icons.campaign, size: 16, color: AppColors.fireGlow),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comunicado.title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            comunicado.content,
            style: const TextStyle(
              color: AppColors.textDim,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
