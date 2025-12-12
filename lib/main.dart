import 'dart:io';

import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';

import 'package:tewo_p/app_desktop/ui_desktop.dart';
import 'package:tewo_p/app_movil/ui_movil.dart';
import 'package:tewo_p/apis/setting_up.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:tewo_p/apis/aws_service.dart';

//Run App, Mobile or Desktop
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Desktop Startup Check
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.maximize();
    });

    Widget initialScreen = const SettingUpPage();

    try {
      // final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '/home/night/Documents/Code/Flutter/Testing/Calculadora/TeWo-PV/TeWo-P/tewo_p/testjson/setts.json',
      );
      print('[DEBUG] Checking settings file at: ${file.path}');

      if (await file.exists()) {
        print('[DEBUG] Settings file exists');
        final content = await file.readAsString();
        final envelope = jsonDecode(content);
        final iv = encrypt.IV.fromBase64(envelope['iv']);
        final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
        final encrypter = encrypt.Encrypter(encrypt.AES(key));

        final decrypted = encrypter.decrypt(
          encrypt.Encrypted.fromBase64(envelope['content']),
          iv: iv,
        );
        final settings = jsonDecode(decrypted);

        print('[DEBUG] Settings decrypted: ${settings.keys}');

        if (settings['type'] == 'DynamoDB') {
          // Initialize AWS Service
          final service = AwsService();
          service.init(
            accessKey: settings['accessKey'],
            secretKey: settings['secretKey'],
            region: settings['region'],
          );

          // Verify connection
          print('[DEBUG] verifying startup connection...');
          if (await service.checkConnection()) {
            print('[DEBUG] Startup connection success');
            initialScreen = const LoginDynamoDBPage();
          } else {
            print('[DEBUG] Startup connection failed');
            initialScreen = MaterialApp(
              theme: ThemeData.dark(),
              home: const ConnectionErrorPage(),
            );
          }
        }
      } else {
        print('[DEBUG] Settings file not found');
      }
    } catch (e) {
      print('Startup error: $e');
      print('[DEBUG] Startup logic exception: $e');
      // Fallback to SettingUpPage
    }

    runApp(initialScreen);
  } else {
    //Mobile Interface
    runApp(const MainMovil());
  }
}
