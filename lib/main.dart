import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tewo_p/setup_interface/main_setup_ui.dart';
import 'package:tewo_p/l10n/app_localizations.dart';
import 'package:tewo_p/services/preferences_service.dart';
import 'package:tewo_p/splash/splash_screen.dart';

import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb check if needed, but Platform is better here for desktop vs mobile
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
  }
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MainAppState? state = context.findAncestorStateOfType<_MainAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Locale? _locale;
  final PreferencesService _preferencesService = PreferencesService();
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Start minimum timer and loading in parallel
    final minSplashDuration = Future.delayed(const Duration(seconds: 2));
    final loadingTasks = Future.wait([
      _loadSavedLocale(),
      _loadSavedFullscreen(),
    ]);

    await Future.wait([minSplashDuration, loadingTasks]);

    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  Future<void> _loadSavedLocale() async {
    final savedLocale = await _preferencesService.loadLocale();
    if (savedLocale != null) {
      if (mounted) {
        setState(() {
          _locale = savedLocale;
        });
      }
    }
  }

  Future<void> _loadSavedFullscreen() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final isFullscreen = await _preferencesService.loadFullscreen();
      if (isFullscreen) {
        await windowManager.setFullScreen(true);
      }
    }
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
    _preferencesService.saveLocale(value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeWo',
      locale: _locale,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.0, -1.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutExpo),
                ),
            child: child,
          );
        },
        child: _showSplash
            ? const SplashScreen(key: ValueKey('splash'))
            : const MainSetupPage(key: ValueKey('main')),
      ),
    );
  }
}
