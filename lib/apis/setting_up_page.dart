// PAGE TO SET UP FOR FIRST TIME A MOBILE DEVICE
import 'dart:convert';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';

import 'package:tewo_p/apis/aws_service.dart';
import 'package:tewo_p/apis/behavior_manager_page.dart';
import 'package:tewo_p/l10n/manual_localizations.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:window_manager/window_manager.dart';

// -----------------------------------------------------------------------------
// MAIN ENTRY POINT FOR SETUP
// -----------------------------------------------------------------------------
class SettingUpPage extends StatefulWidget {
  const SettingUpPage({super.key});

  @override
  State<SettingUpPage> createState() => _SettingUpPageState();
}

class _SettingUpPageState extends State<SettingUpPage> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');
  bool _isLoadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/TeWo-Preferences/assets/json/preferences.json',
      );
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        setState(() {
          _themeMode = data['theme'] == 'light'
              ? ThemeMode.light
              : ThemeMode.dark;
          _locale = Locale(data['locale'] ?? 'en');
        });
      }
    } catch (e) {
      print('Error loading preferences: $e');
    } finally {
      if (mounted) setState(() => _isLoadingPrefs = false);
    }
  }

  Future<void> _savePreferences() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/assets/json/preferences.json');
      await file.parent.create(recursive: true);
      final data = {
        'theme': _themeMode == ThemeMode.light ? 'light' : 'dark',
        'locale': _locale.languageCode,
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
    _savePreferences();
  }

  Future<void> _changeLocale(Locale newLocale) async {
    setState(() => _locale = newLocale);
    await _savePreferences();
    if (_navigatorKey.currentState?.canPop() ?? false) {
      _navigatorKey.currentState!.pop();
    }
  }

  void _showLanguageDialog() {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.selectLanguage ?? 'Select Language',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              onTap: () => _changeLocale(const Locale('en')),
              selected: _locale.languageCode == 'en',
            ),
            ListTile(
              leading: const Text('🇪🇸', style: TextStyle(fontSize: 24)),
              title: const Text('Español'),
              onTap: () => _changeLocale(const Locale('es')),
              selected: _locale.languageCode == 'es',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPrefs) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorKey: _navigatorKey,
      home: WelcomeSetupMobilePage(
        onToggleTheme: _toggleTheme,
        onToggleLocale: _showLanguageDialog,
        currentTheme: _themeMode,
        currentLocale: _locale,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PHASE 1: WELCOME / CHOOSE PATH
// -----------------------------------------------------------------------------
class WelcomeSetupMobilePage extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  final VoidCallback? onToggleLocale;
  final ThemeMode? currentTheme;
  final Locale? currentLocale;

  const WelcomeSetupMobilePage({
    super.key,
    this.onToggleTheme,
    this.onToggleLocale,
    this.currentTheme,
    this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
            ? IconButton(
                icon: const Icon(Icons.fullscreen),
                onPressed: () async {
                  bool isFullScreen = await windowManager.isFullScreen();
                  await windowManager.setFullScreen(!isFullScreen);
                },
              )
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (onToggleLocale != null)
            IconButton(
              icon: Icon(Icons.translate),
              tooltip: currentLocale?.languageCode.toUpperCase() ?? 'LANG',
              onPressed: onToggleLocale,
            ),
          if (onToggleTheme != null)
            IconButton(
              icon: Icon(
                currentTheme == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              onPressed: onToggleTheme,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.welcomeTitle,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium, // Smaller for mobile
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              _buildBigButton(
                context,
                l10n.connectExisting,
                Icons.login,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConnectExistingPage(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildBigButton(
                context,
                l10n.createNew,
                Icons.add_business,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BusinessTemplatePage(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBigButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 70, // Slightly smaller height
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28),
        label: Text(text, style: const TextStyle(fontSize: 18)),
        onPressed: onPressed,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PHASE 2A: CONNECT EXISTING BUSINESS
// -----------------------------------------------------------------------------
class ConnectExistingPage extends StatelessWidget {
  const ConnectExistingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.connectExisting)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DynamoDBSetupFlow(),
                    ),
                  );
                },
                child: const Text('DynamoDB'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.grey[800],
                ),
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
                },
                child: const Text('Remote Connect to Local DB (Coming Soon)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PHASE 2B: BUSINESS PRE-SETS (TEMPLATES)
// -----------------------------------------------------------------------------
class BusinessTemplatePage extends StatelessWidget {
  const BusinessTemplatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupTemplateTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                l10n.setupTemplateSubTitle,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildTemplateButton(
                context,
                l10n.grocery,
                Icons.local_grocery_store,
                enabled: false,
              ),
              _buildTemplateButton(
                context,
                l10n.restaurant,
                Icons.restaurant,
                enabled: false,
              ),
              _buildTemplateButton(
                context,
                l10n.vehicleRental,
                Icons.car_rental,
                enabled: false,
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const VehicleRentalPage(),
                  //   ),
                  // );
                },
              ),
              _buildTemplateButton(
                context,
                l10n.phonesWorkshop,
                Icons.phone_android,
                enabled: false,
              ),
              const Divider(height: 48),
              _buildTemplateButton(
                context,
                l10n.customBehavior,
                Icons.code,
                enabled: true,
                isSecondary: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BehaviorManagerPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateButton(
    BuildContext context,
    String text,
    IconData icon, {
    bool enabled = true,
    bool isSecondary = false,
    VoidCallback? onPressed,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.teal : null,
          disabledBackgroundColor: Colors.grey[800],
          disabledForegroundColor: Colors.grey[500],
        ),
        icon: Icon(icon),
        label: Text(
          enabled ? text : "$text (${l10n.comingSoon})",
          style: const TextStyle(fontSize: 16), // Smaller text
        ),
        onPressed: enabled
            ? onPressed
            : () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
              },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ORIGINAL LOGIC: DYNAMODB SETUP FLOW
// -----------------------------------------------------------------------------
class DynamoDBSetupFlow extends StatefulWidget {
  const DynamoDBSetupFlow({super.key});

  @override
  State<DynamoDBSetupFlow> createState() => _DynamoDBSetupFlowState();
}

class _DynamoDBSetupFlowState extends State<DynamoDBSetupFlow> {
  // AWS Form Controllers
  final _accessKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _regionController = TextEditingController();
  final _endpointController = TextEditingController();

  // Business Login Controllers
  final _businessEmailController = TextEditingController();
  final _businessPasswordController = TextEditingController();

  // Verification
  final _verificationCodeController = TextEditingController();

  // State
  int _currentStep = 0; // 0: DynamoDB, 1: Business Login, 2: Verification
  bool _isTesting = false;
  bool _isConnectionSuccessful = false;
  bool _isLoading = false;
  bool _isBusinessEmailVisible = false;
  bool _isBusinessPasswordVisible = false;

  // Data holder
  Map<String, dynamic>? _businessData;
  String? _generatedCode;
  Timer? _resendTimer;
  int _resendCountdown = 120;
  bool _canResend = false;

  final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');

  @override
  void dispose() {
    _resendTimer?.cancel();
    _accessKeyController.dispose();
    _secretKeyController.dispose();
    _regionController.dispose();
    _endpointController.dispose();
    _businessEmailController.dispose();
    _businessPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentStep == 0
              ? "DynamoDB Setup"
              : _currentStep == 1
              ? "Login"
              : "Confirmation",
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_currentStep == 0) _buildDynamoDBForm(context),
                if (_currentStep == 1) _buildBusinessLoginForm(context),
                if (_currentStep == 2) _buildVerificationForm(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamoDBForm(BuildContext context) {
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
        const SizedBox(height: 16),
        TextField(
          controller: _endpointController,
          decoration: const InputDecoration(
            labelText: 'Endpoint URL (Optional)',
            hintText: 'e.g. http://10.0.2.2:8000',
          ),
        ),
        const SizedBox(height: 24),
        if (_isTesting)
          const CircularProgressIndicator()
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _testConnection(context),
                  child: const Text('Connect'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveAndContinue,
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _testConnection(BuildContext context) async {
    setState(() {
      _isTesting = true;
      _isConnectionSuccessful = false;
    });

    try {
      final service = AwsService();
      service.init(
        accessKey: _accessKeyController.text,
        secretKey: _secretKeyController.text,
        region: _regionController.text,
        endpointUrl: _endpointController.text.isNotEmpty
            ? _endpointController.text
            : null,
      );

      final isConnected = await service.checkConnection();

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
      setState(() {
        _currentStep = 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please test connection successfully first.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBusinessLoginForm(BuildContext context) {
    if (_isLoading) return const CircularProgressIndicator();
    return Column(
      children: [
        const Text("Please enter Business Owner credentials."),
        const SizedBox(height: 24),
        TextField(
          controller: _businessEmailController,
          obscureText: !_isBusinessEmailVisible,
          decoration: InputDecoration(
            labelText: 'Email',
            suffixIcon: IconButton(
              icon: Icon(
                _isBusinessEmailVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isBusinessEmailVisible = !_isBusinessEmailVisible;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _businessPasswordController,
          obscureText: !_isBusinessPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(
                _isBusinessPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isBusinessPasswordVisible = !_isBusinessPasswordVisible;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _validateBusinessLogin,
            child: const Text('Verify & Send Code'),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() => _currentStep = 0);
          },
          child: const Text("Go Back"),
        ),
      ],
    );
  }

  Future<void> _validateBusinessLogin() async {
    final email = _businessEmailController.text.trim();
    final password = _businessPasswordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final scanOutput = await AwsService().client.scan(
        tableName: 'clients_setups',
        filterExpression: 'owner_email = :email',
        expressionAttributeValues: {':email': AttributeValue(s: email)},
      );

      if (scanOutput.items != null && scanOutput.items!.isNotEmpty) {
        final item = scanOutput.items!.first;
        String? storedKey = item['bussiness_key']?.s;

        if (storedKey != null && password == storedKey) {
          _businessData = {
            'bussiness_name': item['bussiness_name']?.s ?? '',
            'bussiness_enabled': item['bussiness_enabled']?.s ?? '',
            'bussiness_key': item['bussiness_key']?.s ?? '',
            'bussiness_owner': item['bussiness_owner']?.s ?? '',
            'bussiness_prefix':
                item['bussiness_prefix']?.s ??
                item['bussiness_prefix']?.n ??
                '',
            'bussiness_target':
                item['bussiness_target']?.s ??
                item['bussiness_target']?.n ??
                '',
            'multi_purpose': item['multi_purpose']?.s ?? '',
            'owner_email': item['owner_email']?.s ?? '',
            'owner_phone':
                item['owner_phone']?.s ?? item['owner_phone']?.n ?? '',
          };

          await _sendVerificationEmail();

          setState(() {
            _isLoading = false;
            _currentStep = 2;
          });
        } else {
          throw Exception("Invalid credentials");
        }
      } else {
        throw Exception("No business found for this email.");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isLoading = false);
    }
  }

  Widget _buildVerificationForm(BuildContext context) {
    return Column(
      children: [
        const Text("A verification code has been sent to your email."),
        const SizedBox(height: 24),
        TextField(
          controller: _verificationCodeController,
          decoration: const InputDecoration(labelText: '6-Digit Code'),
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _verifyCode,
              child: const Text('Confirm'),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _canResend ? _resendCode : null,
              child: Text(
                _canResend ? "Resend Code" : "Resend in $_resendCountdown s",
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => setState(() => _currentStep = 1),
          child: const Text("Back to Login"),
        ),
      ],
    );
  }

  Future<void> _verifyCode() async {
    if (_verificationCodeController.text.trim() == _generatedCode) {
      await _completeSetup();
      if (mounted) {
        // SUCCESS: FOR MOBILE, WE JUST SHOW A DIALOG OR SNACKBAR FOR NOW
        // Navigator.of(context, rootNavigator: true).pushReplacement(
        //   MaterialPageRoute(builder: (context) => const LoginDynamoDBPage()),
        // );
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Setup Complete'),
            content: const Text(
              'Mobile Setup is done.\nPlease restart the app or implement Mobile Login flow.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Code"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendVerificationEmail() async {
    final rnd = Random();
    _generatedCode = (rnd.nextInt(900000) + 100000).toString();

    try {
      final tewoScan = await AwsService().client.scan(
        tableName: 'clients_setups',
        filterExpression: 'bussiness_name = :n',
        expressionAttributeValues: {':n': AttributeValue(s: 'TeWo')},
      );

      if (tewoScan.items == null || tewoScan.items!.isEmpty) {
        throw Exception("System TeWo account not found for SMTP.");
      }
      final tewoItem = tewoScan.items!.first;
      final smtpUser = tewoItem['owner_email']?.s;
      final smtpPass = tewoItem['bussiness_key']?.s;

      if (smtpUser == null || smtpPass == null) {
        throw Exception("Incomplete SMTP credentials.");
      }

      final smtpServer = SmtpServer(
        'smtp.gmail.com',
        username: smtpUser,
        password: smtpPass,
      );

      final message = Message()
        ..from = Address(smtpUser, 'TeWo Mail Service')
        ..recipients.add(_businessData!['owner_email'])
        ..subject = 'New Device Setup Verification'
        ..text =
            '''
TeWo Mail Service.
${_businessData!['bussiness_owner']}, a verification code have been requested to setup a new device for your bussiness.
If you did not requested it, ignore this message.
Code: $_generatedCode
''';

      await send(message, smtpServer);
      _startResendTimer();
    } catch (e) {
      print("SMTP Setup Error: $e");
      print("FALLBACK CODE: $_generatedCode");
      _startResendTimer();
    }
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 120;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendCode() async {
    await _sendVerificationEmail();
  }

  Future<void> _completeSetup() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/assets/json/dkskdp/oxfek.json');
    await file.parent.create(recursive: true);

    final settings = {
      'type': 'DynamoDB',
      'accessKey': _accessKeyController.text,
      'secretKey': _secretKeyController.text,
      'region': _regionController.text,
      'endpointUrl': _endpointController.text.isNotEmpty
          ? _endpointController.text
          : null,
      'bussiness_name': _businessData!['bussiness_name'],
      'bussiness_key': _businessData!['bussiness_key'],
      'bussiness_owner': _businessData!['bussiness_owner'],
      'bussiness_prefix': _businessData!['bussiness_prefix'],
      'bussiness_target': _businessData!['bussiness_target'],
      'owner_email': _businessData!['owner_email'],
      'owner_phone': _businessData!['owner_phone'],
    };

    final jsonString = jsonEncode(settings);

    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(jsonString, iv: iv);
    final envelope = {'iv': iv.base64, 'content': encrypted.base64};

    await file.writeAsString(jsonEncode(envelope));
  }
}
