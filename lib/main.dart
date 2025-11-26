import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tewo_p/app_desktop/ui_desktop.dart';
import 'package:tewo_p/app_movil/ui_movil.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    runApp(const MainDesktop());
  } else {
    runApp(const MainMovil());
  }
}
