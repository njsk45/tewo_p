import "dart:async";
import "dart:io";
//Desktop Interface
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:flutter/material.dart';

import 'package:tewo_p/l10n/manual_localizations.dart';
import 'package:window_manager/window_manager.dart';

import 'package:tewo_p/apis/aws_service.dart';
import 'package:tewo_p/apis/parameters_service.dart';
import 'package:tewo_p/app_desktop/users_management.dart';
import 'package:tewo_p/app_desktop/user_profile.dart';
import 'package:tewo_p/app_desktop/peripherals_page.dart';
import 'package:tewo_p/services/secure_storage_service.dart';

class AdminDesktop extends StatefulWidget {
  final String userAlias;
  final String userId;
  final Map<String, AttributeValue> currentUser;

  const AdminDesktop({
    super.key,
    required this.userAlias,
    required this.userId,
    required this.currentUser,
  });

  @override
  State<AdminDesktop> createState() => _AdminDesktopState();
}

class _AdminDesktopState extends State<AdminDesktop> {
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await ParametersService().init();
    setState(() {
      _themeMode = ParametersService().isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light;
      _locale = Locale(ParametersService().currentLocale);
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

  Future<void> _changeLocale(Locale newLocale) async {
    setState(() {
      _locale = newLocale;
    });
    await ParametersService().setLocale(newLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeWo-P Admin',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: DesktopHomeScreen(
        onThemeChanged: _toggleTheme,
        onLocaleChanged: _changeLocale,
        currentLocale: _locale,
        title: 'Admin Desktop',
        userAlias: widget.userAlias,
        userId: widget.userId,
        currentUser: widget.currentUser,
        showManagerTools: true,
        canEditUsers: true,
        canAddUsers: true,
      ),
    );
  }
}

class ModeratorDesktop extends StatefulWidget {
  final String userAlias;
  final String userId;
  final Map<String, AttributeValue> currentUser;

  const ModeratorDesktop({
    super.key,
    required this.userAlias,
    required this.userId,
    required this.currentUser,
  });

  @override
  State<ModeratorDesktop> createState() => _ModeratorDesktopState();
}

class _ModeratorDesktopState extends State<ModeratorDesktop> {
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await ParametersService().init();
    setState(() {
      _themeMode = ParametersService().isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light;
      _locale = Locale(ParametersService().currentLocale);
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

  Future<void> _changeLocale(Locale newLocale) async {
    setState(() {
      _locale = newLocale;
    });
    await ParametersService().setLocale(newLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeWo-P Moderator',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: DesktopHomeScreen(
        onThemeChanged: _toggleTheme,
        onLocaleChanged: _changeLocale,
        currentLocale: _locale,
        title: 'Moderator Desktop',
        userAlias: widget.userAlias,
        userId: widget.userId,
        currentUser: widget.currentUser,
        showManagerTools: true,
        canEditUsers: false,
        canAddUsers: true,
      ),
    );
  }
}

class EmployeeDesktop extends StatefulWidget {
  final String userAlias;
  final String userId;
  final Map<String, AttributeValue> currentUser;

  const EmployeeDesktop({
    super.key,
    required this.userAlias,
    required this.userId,
    required this.currentUser,
  });

  @override
  State<EmployeeDesktop> createState() => _EmployeeDesktopState();
}

class _EmployeeDesktopState extends State<EmployeeDesktop> {
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await ParametersService().init();
    setState(() {
      _themeMode = ParametersService().isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light;
      _locale = Locale(ParametersService().currentLocale);
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

  Future<void> _changeLocale(Locale newLocale) async {
    setState(() {
      _locale = newLocale;
    });
    await ParametersService().setLocale(newLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeWo-P Employee',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: DesktopHomeScreen(
        onThemeChanged: _toggleTheme,
        onLocaleChanged: _changeLocale,
        currentLocale: _locale,
        title: 'Employee Desktop',
        userAlias: widget.userAlias,
        userId: widget.userId,
        currentUser: widget.currentUser,
        showManagerTools: false,
        canEditUsers: false,
        canAddUsers: false,
      ),
    );
  }
}

class DesktopHomeScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final Function(Locale) onLocaleChanged;
  final Locale currentLocale;
  final String title;
  final String userAlias;
  final String userId;
  final Map<String, AttributeValue> currentUser;
  final bool showManagerTools;
  final bool canEditUsers;
  final bool canAddUsers;

  const DesktopHomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.currentLocale,
    required this.title,
    required this.userAlias,
    required this.userId,
    required this.currentUser,
    required this.showManagerTools,
    required this.canEditUsers,
    required this.canAddUsers,
  });

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen>
    with WindowListener {
  bool _isLoading = false;
  Timer? _connectionCheckTimer;
  Timer? _inactivityTimer;
  String _sessionStatus = 'ACTIVE';
  static const int _inactivityLimit = 480; // 480 seconds = 8 minutes

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initWindow();
    // Check connection every 30 seconds
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) {
      _checkConnectionBackground();
    });
    _startInactivityTimer();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    if (_sessionStatus == 'ACTIVE') {
      _inactivityTimer = Timer(const Duration(seconds: _inactivityLimit), () {
        _handleSessionTimeout();
      });
    }
  }

  void _resetInactivityTimer() {
    if (_sessionStatus == 'ACTIVE') {
      _startInactivityTimer();
    }
  }

  Future<void> _handleSessionTimeout() async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.statusIdle),
        content: Text(AppLocalizations.of(context)!.sessionTimeout),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout(setAutoInactive: true);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSessionStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      // Update local object
      widget.currentUser['is_active'] = AttributeValue(s: newStatus);

      // Save to DB using putItem
      await AwsService().client.putItem(
        tableName: 'cano_users',
        item: widget.currentUser,
      );

      setState(() {
        _sessionStatus = newStatus;
      });
      if (newStatus == 'ACTIVE') {
        _startInactivityTimer();
      } else {
        _inactivityTimer?.cancel();
      }
    } catch (e) {
      print('Error updating session status: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initWindow() async {
    // Prevent default close to show confirmation dialog
    await windowManager.setPreventClose(true);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _connectionCheckTimer?.cancel();
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.areYouSureClose),
            content: Text(AppLocalizations.of(context)!.closeLogOutWarning),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context)!.no),
                onPressed: () {
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.yes),
                onPressed: () async {
                  if (context.mounted) Navigator.of(context).pop();
                  await _logout();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _logout({bool setAutoInactive = false}) async {
    // Navigate immediately to LogoutSplashScreen to prevent UI lag
    if (mounted) {
      await windowManager.setPreventClose(false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              LogoutSplashScreen(currentUser: widget.currentUser),
        ),
        (route) => false, // Remove all previous routes ("reboot")
      );
    }
  }

  Future<void> _checkConnectionBackground() async {
    try {
      final isConnected = await AwsService().checkConnection();
      if (mounted && !isConnected) {
        _connectionCheckTimer
            ?.cancel(); // Stop checking if we are navigating away
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ConnectionErrorPage()),
        );
      }
    } catch (e) {
      print('Background connection check failed: $e');
    }
  }

  // _testConnection removed as it was unused and causing lints

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _resetInactivityTimer(),
      onPointerHover: (_) => _resetInactivityTimer(),
      onPointerMove: (_) => _resetInactivityTimer(),
      child: DefaultTabController(
        length: widget.showManagerTools ? 4 : 3,
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text('${widget.userAlias} | ${widget.title}'),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _sessionStatus == 'ACTIVE'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _sessionStatus == 'ACTIVE'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  child: Text(
                    _sessionStatus == 'ACTIVE'
                        ? AppLocalizations.of(context)!.statusActive
                        : AppLocalizations.of(context)!.statusIdle,
                    style: TextStyle(
                      fontSize: 12,
                      color: _sessionStatus == 'ACTIVE'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  text: AppLocalizations.of(context)!.mainMenu,
                  icon: Icon(Icons.menu),
                ),
                Tab(
                  text: AppLocalizations.of(context)!.operations,
                  icon: Icon(Icons.work),
                ),
                Tab(
                  text: AppLocalizations.of(context)!.stockInventory,
                  icon: Icon(Icons.inventory),
                ),
                if (widget.showManagerTools)
                  Tab(
                    text: AppLocalizations.of(context)!.managerTools,
                    icon: Icon(Icons.admin_panel_settings),
                  ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.fullscreen),
                tooltip: 'Fullscreen',
                onPressed: () async {
                  final isFullScreen = await windowManager.isFullScreen();
                  final newState = !isFullScreen;
                  await windowManager.setFullScreen(newState);
                  await ParametersService().setFullScreen(newState);
                },
              ),
              IconButton(
                icon: const Icon(Icons.update),
                tooltip:
                    'Check for updates', // Hardcoded for now or use localization if strictly needed
                onPressed: () {
                  // Empty function as requested
                },
              ),

              // Removed Session PopupMenuButton
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: AppLocalizations.of(context)!.parameters,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ParametersPage(
                        onThemeChanged: widget.onThemeChanged,
                        onLocaleChanged: widget.onLocaleChanged,
                        currentLocale: widget.currentLocale,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: TabBarView(
            physics:
                const NeverScrollableScrollPhysics(), // Disable swipe to avoid accidental clears? No, swipe is fine but Listener overhead handles it.
            children: [
              // Tab 1: Main Menu
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: _isLoading
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 20),
                                  Text(
                                    AppLocalizations.of(context)!.loggingOut,
                                  ),
                                ],
                              )
                            : Text(
                                AppLocalizations.of(context)!.welcome,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                      ),
                    ),
                    if (!_isLoading)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ParametersPage(
                                      onThemeChanged: widget.onThemeChanged,
                                      onLocaleChanged: widget.onLocaleChanged,
                                      currentLocale: widget.currentLocale,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.settings, size: 32),
                              label: Text(
                                AppLocalizations.of(context)!.parameters,
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 24,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => UserProfileScreen(
                                      currentUser: widget.currentUser,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.person, size: 32),
                              label: const Text(
                                'My Profile',
                              ), // Use localization later
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 24,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                _updateSessionStatus(
                                  _sessionStatus == 'ACTIVE'
                                      ? 'IDLE'
                                      : 'ACTIVE',
                                );
                              },
                              icon: Icon(
                                _sessionStatus == 'ACTIVE'
                                    ? Icons.timer_off
                                    : Icons.timer,
                                size: 32,
                              ),
                              label: Text(
                                _sessionStatus == 'ACTIVE'
                                    ? AppLocalizations.of(context)!.setIdle
                                    : AppLocalizations.of(context)!.setActive,
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 24,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: onWindowClose,
                              icon: const Icon(
                                Icons.logout,
                                size: 32,
                                color: Colors.white,
                              ), // Contrast?
                              label: Text(AppLocalizations.of(context)!.logout),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, // Make it red
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Tab 2: Operations
              const Center(child: Text('Operations')),
              // Tab 3: Stock / Inventory
              const Center(child: Text('Stock / Inventory')),
              // Tab 4: Manager Tools (Conditional)
              if (widget.showManagerTools)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.people),
                        label: Text(AppLocalizations.of(context)!.usersList),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: Text(
                                    AppLocalizations.of(context)!.usersList,
                                  ),
                                ),
                                body: UsersManagementScreen(
                                  canEdit: widget.canEditUsers,
                                  canAdd: widget.canAddUsers,
                                  currentUser: widget.currentUser,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParametersPage extends StatelessWidget {
  final VoidCallback onThemeChanged;
  final Function(Locale) onLocaleChanged;
  final Locale currentLocale;
  const ParametersPage({
    super.key,
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.parameters)),
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
          ListTile(
            title: const Text('Language'),
            subtitle: Text(
              currentLocale.languageCode == 'es' ? 'Español' : 'English',
            ),
            trailing: DropdownButton<Locale>(
              value: currentLocale,
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  onLocaleChanged(newLocale);
                }
              },
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('es'), child: Text('Español')),
              ],
            ),
          ),
          ListTile(
            title: const Text('Peripherals'),
            leading: const Icon(Icons.devices),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PeripheralsPage(),
                ),
              );
            },
            trailing: const Icon(Icons.arrow_forward_ios),
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
            MaterialPageRoute(builder: (context) => const LoginDynamoDBPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.connectionFailed),
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
              Text(
                AppLocalizations.of(
                  context,
                )!.connectionFailed, // Reuse generic fail message or add specific one
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (_isRetrying)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _retryConnection,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    AppLocalizations.of(context)!.testConnection,
                  ), // Reuse test connection string
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

class LogoutSplashScreen extends StatefulWidget {
  final Map<String, AttributeValue> currentUser;
  const LogoutSplashScreen({super.key, required this.currentUser});

  @override
  State<LogoutSplashScreen> createState() => _LogoutSplashScreenState();
}

class _LogoutSplashScreenState extends State<LogoutSplashScreen> {
  @override
  void initState() {
    super.initState();
    _performLogout();
  }

  Future<void> _performLogout() async {
    // Perform the logout logic here
    try {
      // Update local object
      widget.currentUser['is_active'] = AttributeValue(s: 'INACTIVE');

      // Save to DB using putItem
      await AwsService().client.putItem(
        tableName: 'cano_users',
        item: widget.currentUser,
      );

      // Artificial delay for splash effect
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      print('Error during logout splash: $e');
    } finally {
      if (mounted) {
        // Navigate to Login (Reboot)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginDynamoDBPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            // We use a safe fallback text since context might be fresh
            // but usually AppLocalizations works if MaterialApp is parent.
            // Here we are pushing a new route, so it should be fine.
            Text(AppLocalizations.of(context)?.loggingOut ?? 'Logging out...'),
          ],
        ),
      ),
    );
  }
}

// Login DynamoDB Page
class LoginDynamoDBPage extends StatefulWidget {
  const LoginDynamoDBPage({super.key});

  @override
  State<LoginDynamoDBPage> createState() => _LoginDynamoDBPageState();
}

class _LoginDynamoDBPageState extends State<LoginDynamoDBPage> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  String _errorMessage = '';
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final credentials = await SecureStorageService().readJson(
        'login_credentials.json',
      );
      if (credentials != null) {
        setState(() {
          _userController.text = credentials['user'] ?? '';
          _passwordController.text = credentials['password'] ?? '';
          _rememberMe = true;
        });
      }
    } catch (e) {
      print('Error loading credentials: $e');
    }
  }

  Future<void> _loadSettings() async {
    await ParametersService().init();
    setState(() {
      _themeMode = ParametersService().isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light;
      _locale = Locale(ParametersService().currentLocale);
    });
    // Apply FullScreen preference
    final isFullScreen = ParametersService().isFullScreen;
    await windowManager.setFullScreen(isFullScreen);
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

  Future<void> _changeLocale(Locale newLocale) async {
    setState(() {
      _locale = newLocale;
    });
    await ParametersService().setLocale(newLocale.languageCode);
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final user = _userController.text;
    final password = _passwordController.text;

    try {
      final scanOutput = await AwsService().client.scan(
        tableName: 'cano_users',
        filterExpression:
            '(user_alias = :id OR user_phone = :id OR user_mail = :id OR user_curp = :id) AND user_password = :pass',
        expressionAttributeValues: {
          ':id': AttributeValue(s: user),
          ':pass': AttributeValue(s: password),
        },
      );

      if (scanOutput.items != null && scanOutput.items!.isNotEmpty) {
        // Found a user
        final userItem = scanOutput.items!.first;
        final role = userItem['user_role']?.s?.toUpperCase();

        if (mounted) {
          final isActive = userItem['is_active']?.s == 'ACTIVE';
          final userAlias = userItem['user_alias']?.s;
          final userId = userItem['user_id']?.s ?? '';

          if (isActive) {
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.sessionActiveWarning,
                ),
                backgroundColor: Colors.orange,
              ),
            );
            if (mounted) setState(() => _isLoading = false);
            return;
          }

          // Mark as active
          try {
            // Modify local item copy
            final updatedItem = Map<String, AttributeValue>.from(userItem);
            updatedItem['is_active'] = AttributeValue(s: 'ACTIVE');

            // Save credentials if Remember Me is checked
            if (_rememberMe) {
              await SecureStorageService().writeJson('login_credentials.json', {
                'user': user,
                'password': password,
              });
            } else {
              // Optionally clear credentials if unchecked?
              // For now, simpler to just overwrite or ignoring.
              // To respect the user disabling it, we should ideally clear it,
              // but SecureStorageService doesn't have delete exposed in the summary I saw.
              // I'll write empty or invalid to 'forget'.
              await SecureStorageService().writeJson(
                'login_credentials.json',
                {},
              );
            }

            // Save to DB using putItem
            await AwsService().client.putItem(
              tableName: 'cano_users',
              item: updatedItem,
            );
          } catch (e) {
            print('Error setting active status: $e');
          }

          // Simulate a brief delay to show the "charging splash" if network is too fast
          await Future.delayed(const Duration(milliseconds: 800));

          if (userAlias != null) {
            if (role == 'ADMIN') {
              _navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(
                  builder: (context) => AdminDesktop(
                    userAlias: userAlias,
                    userId: userId,
                    currentUser: userItem,
                  ),
                ),
              );
            } else if (role == 'MODERATOR') {
              _navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ModeratorDesktop(
                    userAlias: userAlias,
                    userId: userId,
                    currentUser: userItem,
                  ),
                ),
              );
            } else {
              _navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(
                  builder: (context) => EmployeeDesktop(
                    userAlias: userAlias,
                    userId: userId,
                    currentUser: userItem,
                  ),
                ),
              );
            }
          } else {
            _scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text('Error: User alias missing.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Invalid username or password'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 16,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.power_settings_new,
                          color: Colors.red,
                        ),
                        onPressed: () => exit(0),
                        tooltip: 'Exit App',
                      ),
                      IconButton(
                        icon: const Icon(Icons.fullscreen),
                        onPressed: () async {
                          final isFullScreen = await windowManager
                              .isFullScreen();
                          final newState = !isFullScreen;
                          await windowManager.setFullScreen(newState);
                          await ParametersService().setFullScreen(newState);
                        },
                        tooltip: 'Toggle Fullscreen',
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                        ),
                        onPressed: _toggleTheme,
                        tooltip: 'Toggle Theme',
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<Locale>(
                        value: _locale,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.language),
                        onChanged: (Locale? newLocale) {
                          if (newLocale != null) {
                            _changeLocale(newLocale);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: Locale('en'),
                            child: Text('EN'),
                          ),
                          DropdownMenuItem(
                            value: Locale('es'),
                            child: Text('ES'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.login,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: _userController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.username,
                            border: const OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _signIn(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.password,
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: true,
                          onSubmitted: (_) => _signIn(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                            Text(AppLocalizations.of(context)!.rememberMe),
                          ],
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
                          child: Text(AppLocalizations.of(context)!.signIn),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.of(context)!.verifyingCredentials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Project Powered with Flutter and DynamoDB',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
