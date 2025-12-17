import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _kLanguageKey = 'language_code';
  static const String _kSettingsFileName = 'settings.json';
  static const String _kDataFolder = 'TeWo_Data';

  static const String _kFullscreenKey = 'fullscreen';

  Future<void> saveFullscreen(bool isFullscreen) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final currentLocale = await loadLocale();
      await _saveToDesktopJson(
        currentLocale?.languageCode ?? 'en',
        isFullscreen,
      );
    }
  }

  Future<bool> loadFullscreen() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final json = await _loadJsonMap();
      if (json != null && json.containsKey(_kFullscreenKey)) {
        return json[_kFullscreenKey] as bool;
      }
    }
    return false;
  }

  Future<void> saveLocale(Locale locale) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLanguageKey, locale.languageCode);
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final currentFullscreen = await loadFullscreen();
      await _saveToDesktopJson(locale.languageCode, currentFullscreen);
    }
  }

  Future<Locale?> loadLocale() async {
    String? languageCode;
    if (Platform.isAndroid || Platform.isIOS) {
      final prefs = await SharedPreferences.getInstance();
      languageCode = prefs.getString(_kLanguageKey);
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final json = await _loadJsonMap();
      languageCode = json?[_kLanguageKey] as String?;
    }

    if (languageCode != null) {
      return Locale(languageCode);
    }
    return null;
  }

  Future<void> _saveToDesktopJson(
    String languageCode,
    bool isFullscreen,
  ) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final dataDir = Directory('${docsDir.path}/$_kDataFolder');
      if (!await dataDir.exists()) {
        await dataDir.create(recursive: true);
      }
      final file = File('${dataDir.path}/$_kSettingsFileName');
      final Map<String, dynamic> data = {
        _kLanguageKey: languageCode,
        _kFullscreenKey: isFullscreen,
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving settings to JSON: $e');
    }
  }

  Future<Map<String, dynamic>?> _loadJsonMap() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final file = File('${docsDir.path}/$_kDataFolder/$_kSettingsFileName');
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error loading settings from JSON: $e');
    }
    return null;
  }
}
