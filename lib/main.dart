import 'dart:io';

import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tewo_p/app_desktop/ui_desktop.dart';
import 'package:tewo_p/app_movil/ui_movil.dart';

//Run App, Mobile or Desktop
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Desktop Interface
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.maximize();
    });
    runApp(const MainDesktop());
  } else {
    //Mobile Interface
    runApp(const MainMovil());
  }
}
