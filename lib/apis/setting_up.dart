import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';
import 'package:tewo_p/apis/aws_service.dart';
import 'package:tewo_p/app_desktop/ui_desktop.dart';

class SettingUpPage extends StatefulWidget {
  const SettingUpPage({super.key});

  @override
  State<SettingUpPage> createState() => _SettingUpPageState();
}

class _SettingUpPageState extends State<SettingUpPage> {
  // Navigation State
  int _currentStep = 0; // 0: Role, 1: DB Selection, 2: Config

  // Role Selection
  bool _isAdmin = false;

  // DB Selection
  String? _selectedDb; // 'DynamoDB', 'LocalDB'

  // AWS Form Controllers

  final _accessKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _regionController = TextEditingController();

  bool _isTesting = false;
  bool _isConnectionSuccessful = false;

  // Encryption Key (Hardcoded as per plan)
  final _key = encrypt.Key.fromUtf8(
    'my32lengthsupersecretnooneknows1',
  ); // 32 chars  // Navigator Key to access navigation without context
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      navigatorKey: _navigatorKey,
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Setup',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 48),
                    if (_currentStep == 0) _buildRoleSelection(),
                    if (_currentStep == 1) _buildDbSelection(),
                    if (_currentStep == 2) _buildConfigForm(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      children: [
        Text('Select Role', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // User: Empty function
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
              ),
              child: const Text('User'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isAdmin = true;
                  _currentStep = 1;
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
              ),
              child: const Text('Admin'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDbSelection() {
    return Column(
      children: [
        Text(
          'Select Database System',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedDb = 'DynamoDB';
                  _currentStep = 2;
                });
              },
              child: const Text('DynamoDB AWS'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedDb = 'LocalDB';
                  _currentStep = 2;
                });
              },
              child: const Text('LocalDB'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _currentStep = 0),
          child: const Text('Back'),
        ),
      ],
    );
  }

  Widget _buildConfigForm(BuildContext context) {
    if (_selectedDb == 'LocalDB') {
      return Column(
        children: [
          const Text('Local Database Setup'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Empty function
                },
                child: const Text('Load Backup'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Empty function
                },
                child: const Text('Create DB'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _currentStep = 1),
            child: const Text('Back'),
          ),
        ],
      );
    }

    // DynamoDB Form
    return Column(
      children: [
        TextField(
          controller: _accessKeyController,
          decoration: const InputDecoration(labelText: 'Access Key'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _secretKeyController,
          decoration: const InputDecoration(labelText: 'Secret Key'),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _regionController,
          decoration: const InputDecoration(labelText: 'Region'),
        ),
        const SizedBox(height: 24),
        if (_isTesting)
          const CircularProgressIndicator()
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _testConnection(context),
                child: const Text('Test Connection'),
              ),
              ElevatedButton(
                onPressed: _saveAndContinue,
                child: const Text('Save & Continue'),
              ),
            ],
          ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _currentStep = 1),
          child: const Text('Back'),
        ),
      ],
    );
  }

  Future<void> _testConnection(BuildContext context) async {
    print('[DEBUG] _testConnection UI triggered');
    setState(() {
      _isTesting = true;
      _isConnectionSuccessful = false;
    });

    try {
      final service = AwsService();
      print(
        '[DEBUG] Initializing service with: ${_accessKeyController.text}, ${_regionController.text}',
      );
      service.init(
        accessKey: _accessKeyController.text,
        secretKey: _secretKeyController.text,
        region: _regionController.text,
      );

      final isConnected = await service.checkConnection();
      print('[DEBUG] Connection result: $isConnected');

      setState(() {
        _isConnectionSuccessful = isConnected;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isConnected ? 'Connection Successful!' : 'Connection Failed!',
            ),
            backgroundColor: isConnected ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      print('[DEBUG] Exception in _testConnection: $e');
      setState(() {
        _isConnectionSuccessful = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _saveAndContinue() async {
    if (_isConnectionSuccessful) {
      await _saveSettings();
      if (mounted) {
        _navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(builder: (context) => const MainDesktop()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please test connection successfully first.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    final settings = {
      'type': 'DynamoDB',

      'accessKey': _accessKeyController.text,
      'secretKey': _secretKeyController.text,
      'region': _regionController.text,
    };

    final jsonString = jsonEncode(settings);

    // Generate a random IV
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(jsonString, iv: iv);

    // Create the envelope
    final envelope = {'iv': iv.base64, 'content': encrypted.base64};

    // final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '/home/night/Documents/Code/Flutter/Testing/Calculadora/TeWo-PV/TeWo-P/tewo_p/testjson/setts.json',
    );
    await file.writeAsString(jsonEncode(envelope));
    print('[DEBUG] Settings saved (encrypted) to: ${file.path}');
  }
}
