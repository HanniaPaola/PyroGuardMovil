import 'package:flutter/material.dart';
import '../widgets/education_card.dart';
import '../../../../core/constants/app_colors.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.smoke,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.smoke,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'Aprende y Protege',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.fireMid.withValues(alpha: 0.3),
                          AppColors.smoke,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      size: 150,
                      color: AppColors.fireGlow.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: const Text(
                'Información clara y práctica sobre incendios forestales para que tú y tu familia estén preparados.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _categoryTitle('🔥 ¿Qué causa los incendios?', 0),
                const SizedBox(height: 16),
                const EducationCard(
                  index: 1,
                  icon: '☀️',
                  title: 'Calor extremo y sequía',
                  body:
                      'Cuando pasan muchos días sin lluvia y la temperatura es alta, la vegetación se seca y se enciende fácil. Una chispa basta.',
                  accentColor: AppColors.riskCritical,
                ),
                const EducationCard(
                  index: 2,
                  icon: '💨',
                  title: 'Viento fuerte',
                  body:
                      'Seca la vegetación y propaga el fuego rápido en todas direcciones. Es el factor más peligroso durante un incendio.',
                  accentColor: AppColors.riskHigh,
                ),
                const EducationCard(
                  index: 3,
                  icon: '🚬',
                  title: 'Descuido humano',
                  body:
                      'La mayoría de incendios son por personas: fogatas mal apagadas o quemas agrícolas sin control.',
                  accentColor: AppColors.riskMedium,
                ),
                const SizedBox(height: 24),
                _categoryTitle('🛡️ Cómo prevenirlos', 4),
                const SizedBox(height: 16),
                const EducationCard(
                  index: 5,
                  icon: '🚫',
                  title: 'No quemes en temporada de veda',
                  body:
                      'En Chiapas el mayor riesgo es de febrero a mayo. Durante este período están prohibidas las quemas sin permiso.',
                  accentColor: AppColors.fireMid,
                ),
                const EducationCard(
                  index: 6,
                  icon: '🏕️',
                  title: 'Apaga bien las fogatas',
                  body:
                      'Cubre las brasas con tierra y agua hasta eliminar el calor. Nunca dejes una fogata sin supervisión.',
                  accentColor: AppColors.fireMid,
                ),
                const EducationCard(
                  index: 7,
                  icon: '🌾',
                  title: 'Quemas controladas',
                  body:
                      'Solicita tu permiso. Haz la quema de madrugada, con humedad. Nunca quemes si hay viento.',
                  accentColor: AppColors.fireGlow,
                ),
                const SizedBox(height: 24),
                _categoryTitle('📞 Qué hacer si hay incendio', 8),
                const SizedBox(height: 16),
                const EducationCard(
                  index: 9,
                  icon: '📱',
                  title: 'Llama al 911 inmediatamente',
                  body:
                      'Da tu ubicación precisa. Cada minuto cuenta para que las brigadas actúen a tiempo.',
                  accentColor: AppColors.riskCritical,
                ),
                const EducationCard(
                  index: 10,
                  icon: '🏃',
                  title: 'Aléjate del viento',
                  body:
                      'Aleja a tu familia en dirección contraria al viento. El fuego viaja hacia donde sopla.',
                  accentColor: AppColors.riskCritical,
                ),
                const EducationCard(
                  index: 11,
                  icon: '🤖',
                  title: 'PyroGuard AI',
                  body:
                      'Monitoreamos clima y riesgo cada 30 min. Te avisamos antes del peligro para que puedas actuar.',
                  accentColor: AppColors.fireGlow,
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTitle(String text, int index) {
    return _AnimatedCategoryTitle(text: text, index: index);
  }
}

class _AnimatedCategoryTitle extends StatefulWidget {
  final String text;
  final int index;

  const _AnimatedCategoryTitle({required this.text, required this.index});

  @override
  State<_AnimatedCategoryTitle> createState() => _AnimatedCategoryTitleState();
}

class _AnimatedCategoryTitleState extends State<_AnimatedCategoryTitle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(-0.1, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.fireMid.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: const Border(left: BorderSide(color: AppColors.fireMid, width: 4)),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
