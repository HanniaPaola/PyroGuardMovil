import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/screens/splash_screen.dart';
import 'core/di/injection_container.dart' as di;
import 'features/community/presentation/providers/community_provider.dart';
import 'features/community/presentation/providers/citizen_report_provider.dart';
import 'features/brigadista/presentation/providers/brigadista_provider.dart';
import 'features/brigadista/presentation/providers/auth_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  di.init();
  runApp(const PyroGuardApp());
}

class PyroGuardApp extends StatelessWidget {
  const PyroGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<CommunityProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<CitizenReportProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<BrigadistaProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
      ],
      child: MaterialApp(
        title: 'PyroGuard AI',
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: kProfileMode,
        theme: AppTheme.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
