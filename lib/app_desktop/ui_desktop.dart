import "dart:async";
//Desktop Interface
import 'dart:io';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:aws_common/aws_common.dart';
import 'package:flutter/material.dart';

import 'package:tewo_p/apis/aws_service.dart';
import 'package:tewo_p/apis/parameters_service.dart';

class MainDesktop extends StatefulWidget {
  const MainDesktop({super.key});

  @override
  State<MainDesktop> createState() => _MainDesktopState();
}

class _MainDesktopState extends State<MainDesktop> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    await ParametersService().init();
    setState(() {
      _themeMode = ParametersService().isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  Future<void> _toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    setState(() {
      _themeMode = newMode;
    });
    await ParametersService().setTheme(newMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeWo-P',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: DesktopHomeScreen(onThemeChanged: _toggleTheme),
    );
  }
}

class DesktopHomeScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  const DesktopHomeScreen({super.key, required this.onThemeChanged});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}


class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  bool _isLoading = false;
  Timer? _connectionCheckTimer;

  @override
  void initState() {
    super.initState();
    // Check connection every 30 seconds
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkConnectionBackground();
    });
  }

  @override
  void dispose() {
    _connectionCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectionBackground() async {
    try {
      final isConnected = await AwsService().checkConnection();
      if (mounted && !isConnected) {
        _connectionCheckTimer?.cancel(); // Stop checking if we are navigating away
        Navigator.of(context).pushReplacement(
           MaterialPageRoute(builder: (context) => const MaterialApp(
             debugShowCheckedModeBanner: false,
             home: ConnectionErrorPage()
           )),
        );
      }
    } catch (e) {
      print('Background connection check failed: $e');
    }
  }

  Future<void> _testConnection() async {
    setState(() => _isLoading = true);
    try {
      final isConnected = await AwsService().checkConnection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isConnected ? 'Connection Successful!' : 'Connection Failed',
            ),
            backgroundColor: isConnected ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TeWo-P Desktop')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to TeWo-P'),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _testConnection,
                child: const Text('Test Connection'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ParametersPage(onThemeChanged: widget.onThemeChanged),
                  ),
                );
              },
              child: const Text('Parameters'),
            ),
          ],
        ),
      ),
    );
  }
}

class ParametersPage extends StatelessWidget {
  final VoidCallback onThemeChanged;
  const ParametersPage({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Parameters')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(isDark ? 'Dark Mode' : 'Light Mode'),
            trailing: IconButton(
              icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              onPressed: onThemeChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class ConnectionErrorPage extends StatefulWidget {
  const ConnectionErrorPage({super.key});

  @override
  State<ConnectionErrorPage> createState() => _ConnectionErrorPageState();
}

class _ConnectionErrorPageState extends State<ConnectionErrorPage> {
  bool _isRetrying = false;

  Future<void> _retryConnection() async {
    setState(() => _isRetrying = true);
    try {
      // AwsService is a singleton and should have been initialized by main.dart
      final isConnected = await AwsService().checkConnection();
      if (mounted) {
        if (isConnected) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainDesktop()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connection failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 64, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                'Connection Error',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to connect to the database. It could be a WiFi issue.\n'
                'Please check your connection or contact database support.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (_isRetrying)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _retryConnection,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Connection'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginDynamoDBPage extends StatefulWidget {
  const LoginDynamoDBPage({super.key});

  @override
  State<LoginDynamoDBPage> createState() => _LoginDynamoDBPageState();
}

class _LoginDynamoDBPageState extends State<LoginDynamoDBPage> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _navigatorKey = GlobalKey<NavigatorState>();
  String _errorMessage = '';

  void _signIn() {
    final user = _userController.text;
    final password = _passwordController.text;

    if (user == 'admin' && password == 'admin') {
      _navigatorKey.currentState!.pushReplacement(
        MaterialPageRoute(builder: (context) => const MainDesktop()),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid username or password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(
                  builder: (context) {
                    return Text(
                      'DynamoDB Login',
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                  },
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
