import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// Save processed video/image to App's persistent document directory
  Future<String?> saveToPermanentStorage(String tempPath, {String? customName}) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final slCatFolder = Directory(p.join(docDir.path, 'SL_CAT_Exports'));
      if (!slCatFolder.existsSync()) {
        slCatFolder.createSync(recursive: true);
      }

      final ext = p.extension(tempPath);
      final fileName = customName ?? 'SLCAT_${DateTime.now().millisecondsSinceEpoch}$ext';
      final targetPath = p.join(slCatFolder.path, fileName);

      final tempFile = File(tempPath);
      final newFile = await tempFile.copy(targetPath);
      return newFile.path;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }

  /// Get list of all exported videos from SL CAT folder
  Future<List<File>> getExportedFiles() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final slCatFolder = Directory(p.join(docDir.path, 'SL_CAT_Exports'));
      if (!slCatFolder.existsSync()) {
        return [];
      }

      final files = slCatFolder
          .listSync()
          .whereType<File>()
          .toList()
        ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      return files;
    } catch (e) {
      debugPrint('Error listing files: $e');
      return [];
    }
  }

  /// Clean up temporary video cache
  Future<void> clearTempCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      for (var file in files) {
        if (file.path.contains('slcat_')) {
          file.deleteSync(recursive: true);
        }
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}
