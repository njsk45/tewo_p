import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tewo_p/app/main_ui.dart';

import 'package:window_manager/window_manager.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        await windowManager.ensureInitialized();
      }

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
      };

      runApp(const MainApp());
    },
    (error, stack) async {
      print('[CRITICAL] Uncaught error: $error');
      print(stack);
      exit(1);
    },
  );
}
