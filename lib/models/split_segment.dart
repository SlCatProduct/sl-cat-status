class SplitSegment {
  final int index;
  final Duration startTime;
  final Duration endTime;
  final String outputPath;
  final int fileSize;
  bool isShared;

  SplitSegment({
    required this.index,
    required this.startTime,
    required this.endTime,
    required this.outputPath,
    required this.fileSize,
    this.isShared = false,
  });

  String get durationString {
    final diff = endTime - startTime;
    return '${diff.inSeconds}s';
  }

  String get formattedSize {
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
