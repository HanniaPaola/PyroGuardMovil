import 'package:flutter/material.dart';
import '../../domain/entities/comunicado.dart';
import '../../../../core/constants/app_colors.dart';

class ComunicadoTile extends StatelessWidget {
  final Comunicado comunicado;

  const ComunicadoTile({super.key, required this.comunicado});

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
                  _formatDate(comunicado.publishDate),
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Icon(Icons.campaign, size: 16, color: AppColors.fireGlow),
            ],
          ),
          SizedBox(height: 8),
          Text(
            comunicado.title,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            comunicado.content,
            style: TextStyle(color: AppColors.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
