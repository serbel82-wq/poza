import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app_routes.dart';
import 'screens/welcome_screen.dart';
import 'screens/levels_tree_screen.dart';
import 'data/services/storage_service.dart';
import 'data/services/gamification_service.dart';
import 'data/services/firebase_service.dart';
import 'data/services/sound_service.dart';
import 'theme/child_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init ignored: $e');
  }
  
  await StorageService.init();
  await GamificationService.init();
  await SubscriptionService().init();
  
  runApp(const NeuroApp());
}

class NeuroApp extends StatefulWidget {
  const NeuroApp({super.key});

  @override
  State<NeuroApp> createState() => _NeuroAppState();
}

class _NeuroAppState extends State<NeuroApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'НейроИсследователь',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ru', 'RU'),
      supportedLocales: const [Locale('ru', 'RU')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: _themeMode,
      theme: ChildTheme.light,
      darkTheme: ChildTheme.dark,
      initialRoute: AppRoutes.welcome,
      routes: {
        AppRoutes.welcome: (context) => const WelcomeScreen(),
        AppRoutes.levelsTree: (context) => const LevelsTreeScreen(),
      },
    );
  }
}
