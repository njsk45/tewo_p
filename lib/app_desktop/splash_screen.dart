// LOADING SPLASH SCREEN
import 'package:flutter/material.dart';

class SplashApp extends StatefulWidget {
  final Future<void> Function() onInit;
  const SplashApp({super.key, required this.onInit});

  @override
  State<SplashApp> createState() => _SplashAppState();
}

class _SplashAppState extends State<SplashApp> {
  @override
  void initState() {
    super.initState();
    // Start initialization after frame is rendered (or concurrently)
    // We add a minimum delay to ensure the splash is visible for at least a moment, e.g., 2 seconds
    _startInit();
  }

  Future<void> _startInit() async {
    // Wait for at least 2 seconds AND the actual initialization logic
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      widget.onInit(),
    ]);
    // Navigation is handled inside onInit or subsequent logic, but ideally onInit should mostly prep.
    // However, main.dart logic directly chooses the screen.
    // We might need to handle navigation here based on a result?
    // Let's refactor main to return the target screen instead of runApp-ing directly.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white, // Or brand color
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or App Name
              const Icon(
                Icons.store,
                size: 80,
                color: Colors.blue,
              ), // Placeholder
              const SizedBox(height: 24),
              const Text(
                'TeWo-PV',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Starting up...'),
            ],
          ),
        ),
      ),
    );
  }
}
