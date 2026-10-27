import 'dart:io';

class StatusMediaItem {
  final String path;
  final bool isVideo;
  final DateTime dateModified;
  final int sizeBytes;
  final String appSource;
  bool isSaved;

  StatusMediaItem({
    required this.path,
    required this.isVideo,
    required this.dateModified,
    required this.sizeBytes,
    required this.appSource,
    this.isSaved = false,
  });

  String get fileName => path.split(Platform.pathSeparator).last;

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
