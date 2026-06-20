import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'core/db/local_db_service.dart';
import 'presentation/provider/providers.dart';
import 'presentation/screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await MobileAds.instance.initialize();
  }
  
  final dbService = LocalDbService();
  await dbService.init();

  runApp(
    ProviderScope(
      overrides: [
        localDbServiceProvider.overrideWithValue(dbService),
      ],
      child: const OmniCalcApp(),
    ),
  );
}

class OmniCalcApp extends ConsumerWidget {
  const OmniCalcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dynamic color theme setup using M3 specs
    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: Brightness.light,
      ),
      typography: Typography.material2021(),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black, // AMOLED dark
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: Brightness.dark,
        surface: Colors.black,
        background: Colors.black,
      ),
      typography: Typography.material2021(),
    );

    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'OmniCalc',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
