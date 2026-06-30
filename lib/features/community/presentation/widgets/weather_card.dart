import 'package:flutter/material.dart';
import '../../domain/entities/weather_condition.dart';
import '../../../../core/constants/app_colors.dart';

class WeatherCard extends StatelessWidget {
  final WeatherCondition weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.ash,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fireMid.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONDICIONES ACTUALES',
            style: TextStyle(
              color: AppColors.fireMid,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _WeatherStat(
                icon: '🌡️',
                value: '${weather.temperature.toStringAsFixed(1)}°C',
                label: 'Temperatura',
              ),
              _WeatherStat(
                icon: '💧',
                value: '${weather.humidity.toStringAsFixed(0)}%',
                label: 'Humedad',
              ),
              _WeatherStat(
                icon: '💨',
                value: '${weather.windSpeed.toStringAsFixed(0)} km/h',
                label: 'Viento',
              ),
              _WeatherStat(
                icon: '☀️',
                value: '${weather.daysWithoutRain}d',
                label: 'Sin lluvia',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.smoke,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.fireCore.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    weather.explanation,
                    style: const TextStyle(
                      color: AppColors.textDim,
                      fontSize: 13,
                      height: 1.6,
                    ),
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

class _WeatherStat extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _WeatherStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.fireGlow,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
