import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

class BpService {
  /// Unzips a .twbp file to the specified destination directory.
  ///
  /// [twbpPath] is the absolute or relative path to the .twbp file.
  /// [destinationDir] is the target directory, defaulting to 'dynamic_json_widgets_test/bp'.
  static Future<void> extractBehaviorPack(
    String twbpPath, {
    String destinationDir = 'dynamic_json_widgets_test/bp',
  }) async {
    final file = File(twbpPath);

    if (!file.existsSync()) {
      throw FileSystemException('File not found', twbpPath);
    }

    if (p.extension(twbpPath).toLowerCase() != '.twbp') {
      throw FormatException('File is not a .twbp archive', twbpPath);
    }

    final targetDir = Directory(destinationDir);
    if (!targetDir.existsSync()) {
      await targetDir.create(recursive: true);
    }

    try {
      final bytes = File(twbpPath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Extract the archive to the destination directory
      await extractArchiveToDisk(archive, destinationDir);
      print('Successfully extracted $twbpPath to $destinationDir');
    } catch (e) {
      print('Error extracting .twbp file: $e');
      rethrow;
    }
  }
}
