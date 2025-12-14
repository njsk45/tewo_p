import 'dart:io';

import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tewo_p/app_desktop/ui_desktop.dart';
import 'package:tewo_p/app_movil/ui_movil.dart';
import 'package:tewo_p/apis/setting_up.dart';
import 'package:tewo_p/app_desktop/splash_screen.dart'; // Import Splash

import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:tewo_p/apis/aws_service.dart';
import 'package:tewo_p/apis/session_service.dart';
import 'dart:async'; // For runZonedGuarded
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        // Optional: Propagate to zone if you want standard error printing + exit
        // Zone.current.handleUncaughtError(details.exception, details.stack!);
      };

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        runApp(const DesktopApp());
      } else {
        runApp(const MainMovil());
      }
    },
    (error, stack) async {
      print('[CRITICAL] Uncaught error: $error');
      print(stack);
      await SessionService().emergencyDeactivate();
      exit(1);
    },
  );
}

class DesktopApp extends StatefulWidget {
  const DesktopApp({super.key});

  @override
  State<DesktopApp> createState() => _DesktopAppState();
}

class _DesktopAppState extends State<DesktopApp> {
  bool _initialized = false;
  Widget _nextScreen = const SettingUpPage();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 1. Initialize Window Manager
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    // Show window early but empty/splash
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.maximize();
    });

    // 2. Perform Backend Logic
    final logicStart = DateTime.now();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/assets/json/dkskdp/oxfek.json');
      print('[DEBUG] Checking settings file at: ${file.path}');

      if (await file.exists()) {
        try {
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

          // Strict Validation
          if (_hasAllRequiredFields(settings)) {
            // Initialize Session Service Table Name
            final prefix = settings['bussiness_prefix'];
            if (prefix != null) {
              SessionService().setTableName('${prefix}_users');
            }

            final service = AwsService();
            service.init(
              accessKey: settings['accessKey'],
              secretKey: settings['secretKey'],
              region: settings['region'],
            );

            print('[DEBUG] verifying startup connection...');
            if (await service.checkConnection()) {
              print(
                '[DEBUG] Startup connection success. Checking Business Status...',
              );

              bool maintenanceMode = false;
              // Check Business Enabled Status
              final businessName = settings['bussiness_name'];
              if (businessName != null) {
                // In DynamoDB 'clients_setups' table, key is bussiness_name? Or we scan?
                // Using Scan as done in setup for now to match logic, though Query is better if key known.
                // Setup uses scan on 'clients_setups'.
                final scanOutput = await service.client.scan(
                  tableName: 'clients_setups',
                  filterExpression: 'bussiness_name = :n',
                  expressionAttributeValues: {
                    ':n': AttributeValue(s: businessName),
                  },
                );

                if (scanOutput.items != null && scanOutput.items!.isNotEmpty) {
                  final item = scanOutput.items!.first;
                  final enabled = item['bussiness_enabled']?.s;
                  if (enabled != 'ENABLED') {
                    maintenanceMode = true;
                    print('[DEBUG] Business is DISABLED or UNDER MAINTENANCE');
                  }
                } else {
                  // Could not find business record? Maybe deleted?
                  // Treat as risk/maintenance? Or Allow?
                  // Assuming safer to block or warn.
                  // For now, if connection works but business not found, maybe just proceed but warn later?
                  // Prompt implies strict check: "Else 'DISABLED' ... if 'EMPLOYEE' show warning"
                  // If record missing, we can't check enabled status.
                  print('[WARN] Business record not found.');
                }
              }

              _nextScreen = LoginDynamoDBPage(maintenanceMode: maintenanceMode);
            } else {
              _nextScreen = MaterialApp(
                theme: ThemeData.dark(),
                home: const ConnectionErrorPage(),
              );
            }
          } else {
            print(
              '[ERROR] Missing fields in configuration. Deleting and restarting setup.',
            );
            await file.delete();
            _nextScreen = const SettingUpPage();
          }
        } catch (e) {
          print(
            '[ERROR] Corrupted configuration file. Deleting and restarting setup. Error: $e',
          );
          await file.delete();
          _nextScreen = const SettingUpPage();
        }
      } else {
        // File doesn't exist
        _nextScreen = const SettingUpPage();
      }
    } catch (e) {
      print('Startup System Error: $e');
    }

    // Ensure splash is visible for at least 2 seconds
    final elapsed = DateTime.now().difference(logicStart);
    if (elapsed.inSeconds < 2) {
      await Future.delayed(
        Duration(milliseconds: 2000 - elapsed.inMilliseconds),
      );
    }

    setState(() {
      _initialized = true;
    });
  }

  bool _hasAllRequiredFields(Map<String, dynamic> settings) {
    const required = [
      'accessKey',
      'secretKey',
      'region',
      'bussiness_name',
      'bussiness_key',
      'bussiness_owner',
      'bussiness_prefix',
      'bussiness_target',
      'owner_email',
      'owner_phone',
    ];
    for (var field in required) {
      if (!settings.containsKey(field) || settings[field] == null) {
        print('[ERROR] Missing field: $field');
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // While initializing, show Splash
    if (!_initialized) {
      return const SplashAppWait();
    }
    // Once done, show main app
    return _nextScreen;
  }
}

// Simple wrapper for splash to avoid logic duplication in build
class SplashAppWait extends StatelessWidget {
  const SplashAppWait({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF1E1E1E), // Dark background
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store, size: 80, color: Colors.blue),
              SizedBox(height: 24),
              Text(
                'TeWo-PV',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text for dark bg
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
