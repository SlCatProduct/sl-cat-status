import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../models/status_media_item.dart';

class StatusSaverService {
  static final StatusSaverService _instance = StatusSaverService._internal();
  factory StatusSaverService() => _instance;
  StatusSaverService._internal();

  // Known WhatsApp status paths across Android versions
  static const List<Map<String, String>> _statusDirectories = [
    {
      'source': 'WhatsApp',
      'path': '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
    },
    {
      'source': 'WhatsApp Business',
      'path': '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
    },
    {
      'source': 'WhatsApp',
      'path': '/storage/emulated/0/WhatsApp/Media/.Statuses',
    },
    {
      'source': 'WhatsApp Business',
      'path': '/storage/emulated/0/WhatsApp Business/Media/.Statuses',
    },
  ];

  Future<bool> checkPermission() async {
    if (!Platform.isAndroid) return true;

    final manageStatus = await Permission.manageExternalStorage.status;
    if (manageStatus.isGranted) return true;

    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) return true;

    final photosStatus = await Permission.photos.status;
    final videosStatus = await Permission.videos.status;
    if (photosStatus.isGranted && videosStatus.isGranted) return true;

    return false;
  }

  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return true;

    // First try manageExternalStorage for Android 11+ full WhatsApp folder access
    final manageStatus = await Permission.manageExternalStorage.request();
    if (manageStatus.isGranted) return true;

    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) return true;

    final mediaStatus = await [Permission.photos, Permission.videos].request();
    return mediaStatus[Permission.photos]?.isGranted == true ||
        mediaStatus[Permission.videos]?.isGranted == true;
  }

  Future<List<StatusMediaItem>> fetchAllStatuses({String filterSource = 'All'}) async {
    final List<StatusMediaItem> items = [];
    final savedFileNames = await _getSavedFileNames();

    for (final dirConfig in _statusDirectories) {
      final source = dirConfig['source']!;
      if (filterSource != 'All' && source != filterSource) {
        continue;
      }

      final dirPath = dirConfig['path']!;
      final dir = Directory(dirPath);

      if (await dir.exists()) {
        try {
          final files = dir.listSync();
          for (final entity in files) {
            if (entity is File) {
              final ext = p.extension(entity.path).toLowerCase();
              final isImg = ext == '.jpg' || ext == '.jpeg' || ext == '.png';
              final isVid = ext == '.mp4' || ext == '.mkv';

              if (isImg || isVid) {
                final stat = entity.statSync();
                final fileName = p.basename(entity.path);

                // Avoid duplicate items if directory scanned under different alias
                final alreadyAdded = items.any((i) => i.fileName == fileName);
                if (!alreadyAdded) {
                  items.add(
                    StatusMediaItem(
                      path: entity.path,
                      isVideo: isVid,
                      dateModified: stat.modified,
                      sizeBytes: stat.size,
                      appSource: source,
                      isSaved: savedFileNames.contains(fileName),
                    ),
                  );
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Error reading status dir $dirPath: $e');
        }
      }
    }

    // Sort by latest first
    items.sort((a, b) => b.dateModified.compareTo(a.dateModified));
    return items;
  }

  Future<Directory> getSaveDirectory() async {
    if (Platform.isAndroid) {
      final picturesDir = Directory('/storage/emulated/0/Pictures/SL_CAT_Saved');
      if (await picturesDir.exists()) {
        return picturesDir;
      }
      try {
        return await picturesDir.create(recursive: true);
      } catch (_) {
        // Fallback to app documents
      }
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final fallback = Directory(p.join(appDocDir.path, 'SL_CAT_Saved'));
    if (!await fallback.exists()) {
      await fallback.create(recursive: true);
    }
    return fallback;
  }

  Future<Set<String>> _getSavedFileNames() async {
    try {
      final dir = await getSaveDirectory();
      if (await dir.exists()) {
        return dir
            .listSync()
            .whereType<File>()
            .map((f) => p.basename(f.path))
            .toSet();
      }
    } catch (e) {
      debugPrint('Error getting saved files: $e');
    }
    return {};
  }

  Future<String?> saveStatus(StatusMediaItem item) async {
    try {
      final saveDir = await getSaveDirectory();
      final destinationPath = p.join(saveDir.path, item.fileName);
      final sourceFile = File(item.path);

      if (await sourceFile.exists()) {
        await sourceFile.copy(destinationPath);
        item.isSaved = true;
        return destinationPath;
      }
    } catch (e) {
      debugPrint('Error saving status: $e');
    }
    return null;
  }

  Future<List<StatusMediaItem>> fetchSavedStatuses() async {
    final List<StatusMediaItem> savedItems = [];
    try {
      final saveDir = await getSaveDirectory();
      if (await saveDir.exists()) {
        final files = saveDir.listSync();
        for (final entity in files) {
          if (entity is File) {
            final ext = p.extension(entity.path).toLowerCase();
            final isImg = ext == '.jpg' || ext == '.jpeg' || ext == '.png';
            final isVid = ext == '.mp4' || ext == '.mkv';

            if (isImg || isVid) {
              final stat = entity.statSync();
              savedItems.add(
                StatusMediaItem(
                  path: entity.path,
                  isVideo: isVid,
                  dateModified: stat.modified,
                  sizeBytes: stat.size,
                  appSource: 'Saved Vault',
                  isSaved: true,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching saved statuses: $e');
    }
    savedItems.sort((a, b) => b.dateModified.compareTo(a.dateModified));
    return savedItems;
  }

  Future<void> shareStatus(StatusMediaItem item) async {
    try {
      await Share.shareXFiles(
        [XFile(item.path)],
        text: 'Shared via SL CAT Pure Status',
      );
    } catch (e) {
      debugPrint('Error sharing status: $e');
    }
  }

  Future<void> repostToWhatsApp(StatusMediaItem item) async {
    try {
      await Share.shareXFiles(
        [XFile(item.path)],
        text: 'Re-posted via SL CAT',
      );
    } catch (e) {
      debugPrint('Error reposting status: $e');
    }
  }
}
