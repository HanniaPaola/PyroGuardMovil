import 'package:flutter/material.dart';
import '../widgets/education_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/section_header.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.smoke,
      appBar: AppBar(
        title: const Text('Aprende'),
        backgroundColor: AppColors.smoke,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionHeader(
            tag: 'Educación',
            title: 'Protege tu comunidad',
            subtitle:
                'Información clara y práctica sobre incendios forestales para que tú y tu familia estén preparados.',
          ),
          const SizedBox(height: 28),

          _CategoryTitle('🔥 ¿Qué causa los incendios?'),
          const SizedBox(height: 12),
          const EducationCard(
            icon: '☀️',
            title: 'Calor extremo y sequía',
            body:
                'Cuando pasan muchos días sin lluvia y la temperatura es muy alta, la vegetación se seca y se vuelve fácil de encender. Una chispa puede iniciar un incendio en segundos.',
            accentColor: AppColors.riskCritical,
          ),
          const EducationCard(
            icon: '💨',
            title: 'Viento fuerte',
            body:
                'El viento seca la vegetación más rápido y hace que el fuego se propague velozmente en todas direcciones. Es el factor más peligroso durante un incendio activo.',
            accentColor: AppColors.riskHigh,
          ),
          const EducationCard(
            icon: '🚬',
            title: 'Descuido humano',
            body:
                'La mayoría de los incendios son causados por personas: fogatas mal apagadas, quemas agrícolas sin control o colillas de cigarro. Todos podemos prevenirlos.',
            accentColor: AppColors.riskMedium,
          ),

          const SizedBox(height: 24),
          _CategoryTitle('🛡️ Cómo prevenirlos'),
          const SizedBox(height: 12),
          const EducationCard(
            icon: '🚫',
            title: 'No quemes en temporada de veda',
            body:
                'En Chiapas la temporada de mayor riesgo va de febrero a mayo. Durante este período está prohibido hacer quemas agrícolas sin permiso oficial de la Conafor.',
            accentColor: AppColors.fireMid,
          ),
          const EducationCard(
            icon: '🏕️',
            title: 'Apaga bien las fogatas',
            body:
                'Cubre las brasas con tierra y agua hasta que no haya calor. Nunca dejes una fogata encendida sin supervisión, aunque parezca pequeña.',
            accentColor: AppColors.fireMid,
          ),
          const EducationCard(
            icon: '🌾',
            title: 'Para agricultores: quemas controladas',
            body:
                'Si necesitas quemar rastrojos, solicita tu permiso en la oficina de Conafor más cercana. Haz la quema de madrugada, cuando hay más humedad. Nunca quemes si hay viento.',
            accentColor: AppColors.fireGlow,
          ),

          const SizedBox(height: 24),
          _CategoryTitle('📞 Qué hacer si hay un incendio'),
          const SizedBox(height: 12),
          const EducationCard(
            icon: '📱',
            title: 'Llama al 911 inmediatamente',
            body:
                'En cuanto veas humo o fuego en zona forestal llama al 911. Da tu ubicación lo más precisa posible. Cada minuto cuenta para que las brigadas lleguen a tiempo.',
            accentColor: AppColors.riskCritical,
          ),
          const EducationCard(
            icon: '🏃',
            title: 'Aléjate del viento',
            body:
                'Si hay incendio cerca, aleja a tu familia en dirección contraria al viento. El fuego viaja hacia donde sopla el viento. No intentes apagarlo tú solo.',
            accentColor: AppColors.riskCritical,
          ),
          const EducationCard(
            icon: '🔥',
            title: 'Cómo actúa PyroGuard AI',
            body:
                'Nuestro sistema monitorea la temperatura, humedad y viento de tu zona cada 30 minutos. Si las condiciones se vuelven peligrosas, te avisamos antes de que el fuego comience para que puedas actuar a tiempo.',
            accentColor: AppColors.fireGlow,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _CategoryTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.cream,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }
}
