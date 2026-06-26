import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/community/di/community_module.dart';
import 'features/community/presentation/screens/community_home_screen.dart';
import 'features/brigadista/di/brigadista_module.dart';

void main() {
  runApp(const PyroGuardApp());
}

class PyroGuardApp extends StatelessWidget {
  const PyroGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CommunityModule.buildProvider()),
        ChangeNotifierProvider(
          create: (_) => CommunityModule.buildCitizenReportProvider(),
        ),
        ChangeNotifierProvider(create: (_) => BrigadistaModule.buildProvider()),
        ChangeNotifierProvider(
          create: (_) => BrigadistaModule.buildAuthProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'PyroGuard AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const CommunityHomeScreen(),
      ),
    );
  }
}
