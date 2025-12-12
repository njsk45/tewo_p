import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';

class SecureStorageService {
  // TODO: Use a secure key management solution in production
  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  static final _iv = encrypt.IV.fromLength(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  Future<String> _getFilePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }

  Future<void> writeJson(String filename, Map<String, dynamic> json) async {
    final path = await _getFilePath(filename);
    final jsonString = jsonEncode(json);
    final encrypted = _encrypter.encrypt(jsonString, iv: _iv);
    final file = File(path);
    await file.writeAsString(encrypted.base64);
  }

  Future<Map<String, dynamic>?> readJson(String filename) async {
    try {
      final path = await _getFilePath(filename);
      final file = File(path);
      if (!await file.exists()) return null;

      final encryptedBase64 = await file.readAsString();
      final encrypted = encrypt.Encrypted.fromBase64(encryptedBase64);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      // Return null if decryption fails or file doesn't exist
      return null;
    }
  }
}
