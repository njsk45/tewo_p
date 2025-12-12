import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ParametersService {
  static final ParametersService _instance = ParametersService._internal();

  factory ParametersService() {
    return _instance;
  }

  ParametersService._internal();

  Map<String, dynamic> _parameters = {};

  Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/parameters.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        _parameters = jsonDecode(content);
      }
    } catch (e) {
      print('Error loading parameters: $e');
    }
  }

  Future<void> _save() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/parameters.json');
      await file.writeAsString(jsonEncode(_parameters));
    } catch (e) {
      print('Error saving parameters: $e');
    }
  }

  bool get isDarkMode => _parameters['isDarkMode'] ?? true; // Default to dark
  String get currentLocale =>
      _parameters['locale'] ?? 'en'; // Default to English

  Future<void> setTheme(bool isDark) async {
    _parameters['isDarkMode'] = isDark;
    await _save();
  }

  Future<void> setLocale(String localeCode) async {
    _parameters['locale'] = localeCode;
    await _save();
  }

  bool get isFullScreen => _parameters['isFullScreen'] ?? false;

  Future<void> setFullScreen(bool isFull) async {
    _parameters['isFullScreen'] = isFull;
    await _save();
  }
}
