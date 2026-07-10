import 'package:flutter/material.dart';

class AppColors {
  static const Color fireCore = Color(0xFFFF2200);
  static const Color fireMid = Color(0xFFFF6A00);
  static const Color fireGlow = Color(0xFFFFB347);
  static const Color fireTip = Color(0xFFFFE566);
  static const Color ember = Color(0xFFFF4500);
  
  static const Color smoke = Color(0xFF1A1008);
  static const Color ash = Color(0xFF2D1F0E);
  static const Color bark = Color(0xFF3D2B1A);
  static const Color cream = Color(0xFFFFF8F0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDim = Color(0xFFC4A882);
  static const Color textMuted = Color(0xFF8A6E50);

  static const Color riskLow = Color(0xFF22C55E);
  static const Color riskMedium = Color(0xFFEAB308);
  static const Color riskHigh = Color(0xFFF97316);
  static const Color riskCritical = Color(0xFFEF4444);

  static Color riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'bajo':
        return riskLow;
      case 'medio':
        return riskMedium;
      case 'alto':
        return riskHigh;
      case 'crítico':
        return riskCritical;
      default:
        return riskLow;
    }
  }

  static String riskLabel(String level) {
    switch (level.toLowerCase()) {
      case 'bajo':
        return 'Sin riesgo';
      case 'medio':
        return 'Precaución';
      case 'alto':
        return 'Alerta';
      case 'crítico':
        return 'Peligro';
      default:
        return 'Sin riesgo';
    }
  }

  static const LinearGradient gradientFire = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [fireCore, fireMid, fireGlow],
  );
}
