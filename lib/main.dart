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

import 'package:device_preview/device_preview.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Notificación en background: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  di.init();
  runApp(
    DevicePreview(enabled: kIsWeb, builder: (context) => const PyroGuardApp()),
  );
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
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: AppTheme.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
