import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/statistics.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/compression_preset.dart';
import '../models/split_segment.dart';

class FFmpegService {
  static final FFmpegService _instance = FFmpegService._internal();
  factory FFmpegService() => _instance;
  FFmpegService._internal();

  /// Extracts the SL CAT watermark asset to persistent app documents directory
  Future<String?> _getWatermarkPath() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final watermarkFile = File(p.join(docDir.path, 'sl_cat_watermark.png'));
      final byteData = await rootBundle.load('assets/images/sl_cat_watermark.png');
      if (!watermarkFile.existsSync() || watermarkFile.lengthSync() != byteData.lengthInBytes) {
        await watermarkFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
      }
      return watermarkFile.path;
    } catch (e) {
      debugPrint('Error preparing watermark asset: $e');
      return null;
    }
  }

  /// Gets media information safely
  Future<Map<String, dynamic>> getVideoInfo(String filePath) async {
    try {
      final session = await FFprobeKit.getMediaInformation(filePath);
      final info = session.getMediaInformation();
      if (info == null) {
        final file = File(filePath);
        return {
          'durationMs': 0,
          'width': 720,
          'height': 1280,
          'size': file.existsSync() ? file.lengthSync() : 0,
          'hasAudio': true,
        };
      }

      final durationSec = double.tryParse(info.getDuration() ?? '0') ?? 0;
      final size = int.tryParse(info.getSize() ?? '0') ?? 0;

      int width = 720;
      int height = 1280;
      bool hasAudio = false;

      final streams = info.getStreams();
      for (var stream in streams) {
        if (stream.getType() == 'video') {
          width = stream.getWidth() ?? 720;
          height = stream.getHeight() ?? 1280;
        } else if (stream.getType() == 'audio') {
          hasAudio = true;
        }
      }

      return {
        'durationMs': (durationSec * 1000).toInt(),
        'width': width,
        'height': height,
        'size': size > 0 ? size : (File(filePath).existsSync() ? File(filePath).lengthSync() : 0),
        'hasAudio': hasAudio,
      };
    } catch (e) {
      debugPrint('Error getting video info: $e');
      final file = File(filePath);
      return {
        'durationMs': 0,
        'width': 720,
        'height': 1280,
        'size': file.existsSync() ? file.lengthSync() : 0,
        'hasAudio': true,
      };
    }
  }

  /// Compress Video using SL CAT ByeBye Blur Algorithm with rock-solid Watermark
  Future<String?> compressVideo({
    required String inputPath,
    required CompressionPreset preset,
    bool addWatermark = true,
    required Function(double progress, String status) onProgress,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'slcat_pure_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final outputPath = p.join(tempDir.path, fileName);

      final info = await getVideoInfo(inputPath);
      final totalDurationMs = info['durationMs'] as int;
      final hasAudio = info['hasAudio'] as bool? ?? true;

      // Statistics callback for progress
      FFmpegKitConfig.enableStatisticsCallback((Statistics statistics) {
        if (totalDurationMs > 0) {
          final timeMs = statistics.getTime();
          double progress = (timeMs / totalDurationMs).clamp(0.0, 0.99);
          onProgress(progress, 'Optimizing with SL CAT: ${(progress * 100).toInt()}%');
        }
      });

      final targetW = preset.targetWidth;
      final targetH = preset.targetHeight;
      final vBitrate = '${preset.videoBitrateKbps}k';
      final maxBitrate = '${preset.maxBitrateKbps}k';
      final bufSize = '${preset.videoBitrateKbps * 2}k';
      final fps = preset.fps;
      final gop = preset.gopSize;

      String? watermarkPath;
      if (addWatermark) {
        watermarkPath = await _getWatermarkPath();
      }

      final List<String> args = [
        '-y',
        '-i', inputPath,
      ];

      if (addWatermark && watermarkPath != null && File(watermarkPath).existsSync()) {
        // Direct single-image overlay with eof_action=repeat (No -loop 1 memory leaks, no unaligned scaling)
        final filterComplex =
            '[0:v]scale=w=$targetW:h=$targetH:force_original_aspect_ratio=decrease,pad=$targetW:$targetH:(ow-iw)/2:(oh-ih)/2:black,format=yuv420p[base];'
            '[base][1:v]overlay=W-w:H-h:eof_action=repeat[v]';

        args.addAll([
          '-i', watermarkPath,
          '-filter_complex', filterComplex,
          '-map', '[v]',
        ]);
      } else {
        final videoFilter =
            'scale=w=$targetW:h=$targetH:force_original_aspect_ratio=decrease,pad=$targetW:$targetH:(ow-iw)/2:(oh-ih)/2:black,format=yuv420p';
        args.addAll([
          '-vf', videoFilter,
          '-map', '0:v',
        ]);
      }

      if (hasAudio) {
        args.addAll([
          '-map', '0:a',
          '-c:a', 'aac',
          '-b:a', '128k',
          '-ar', '44100',
          '-ac', '2',
        ]);
      } else {
        args.add('-an');
      }

      args.addAll([
        '-c:v', 'libx264',
        '-preset', 'ultrafast',
        '-profile:v', 'baseline',
        '-level', '3.1',
        '-b:v', vBitrate,
        '-maxrate', maxBitrate,
        '-bufsize', bufSize,
        '-r', '$fps',
        '-g', '$gop',
        '-keyint_min', '$gop',
        '-sc_threshold', '0',
        '-movflags', '+faststart',
        outputPath,
      ]);

      debugPrint('Executing SL CAT FFmpeg args count: ${args.length}');
      onProgress(0.05, 'Starting SL CAT Compression...');

      final session = await FFmpegKit.executeWithArguments(args);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        onProgress(1.0, 'Optimization Complete!');
        return outputPath;
      } else {
        final logs = await session.getAllLogsAsString();
        debugPrint('FFmpeg Error: $logs');
        return null;
      }
    } catch (e, stack) {
      debugPrint('compressVideo Exception: $e\n$stack');
      return null;
    }
  }

  /// Split long video into consecutive 30-second clips for WhatsApp Status
  Future<List<SplitSegment>> splitVideoIntoStatusClips({
    required String inputPath,
    int segmentDurationSec = 30,
    bool addWatermark = true,
    required Function(double progress, String status) onProgress,
  }) async {
    try {
      final info = await getVideoInfo(inputPath);
      final totalDurationMs = info['durationMs'] as int;
      final totalDurationSec = totalDurationMs / 1000.0;
      final hasAudio = info['hasAudio'] as bool? ?? true;

      if (totalDurationSec <= 0) return [];

      final tempDir = await getTemporaryDirectory();
      final List<SplitSegment> segments = [];
      final int numSegments = (totalDurationSec / segmentDurationSec).ceil();

      String? watermarkPath;
      if (addWatermark) {
        watermarkPath = await _getWatermarkPath();
      }

      for (int i = 0; i < numSegments; i++) {
        final startSec = i * segmentDurationSec;
        double endSec = (i + 1) * segmentDurationSec.toDouble();
        if (endSec > totalDurationSec) {
          endSec = totalDurationSec;
        }

        final outPath = p.join(
          tempDir.path,
          'slcat_part_${i + 1}_of_${numSegments}_${DateTime.now().millisecondsSinceEpoch}.mp4',
        );

        final progressVal = i / numSegments;
        onProgress(progressVal, 'Splitting segment ${i + 1} of $numSegments...');

        final List<String> args = [
          '-y',
          '-ss', '$startSec',
          '-i', inputPath,
        ];

        if (addWatermark && watermarkPath != null && File(watermarkPath).existsSync()) {
          args.addAll([
            '-i', watermarkPath,
            '-t', '${endSec - startSec}',
            '-filter_complex', '[0:v]format=yuv420p[base];[base][1:v]overlay=W-w:H-h:eof_action=repeat[v]',
            '-map', '[v]',
          ]);
        } else {
          args.addAll([
            '-t', '${endSec - startSec}',
            '-map', '0:v',
          ]);
        }

        if (hasAudio) {
          args.addAll([
            '-map', '0:a',
            '-c:a', 'aac',
            '-b:a', '128k',
          ]);
        } else {
          args.add('-an');
        }

        args.addAll([
          '-c:v', 'libx264',
          '-preset', 'ultrafast',
          '-crf', '20',
          '-movflags', '+faststart',
          outPath,
        ]);

        final session = await FFmpegKit.executeWithArguments(args);
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          final file = File(outPath);
          if (file.existsSync()) {
            segments.add(
              SplitSegment(
                index: i + 1,
                startTime: Duration(seconds: startSec),
                endTime: Duration(seconds: endSec.toInt()),
                outputPath: outPath,
                fileSize: file.lengthSync(),
              ),
            );
          }
        }
      }

      onProgress(1.0, 'Splitting Completed!');
      return segments;
    } catch (e, stack) {
      debugPrint('splitVideo error: $e\n$stack');
      return [];
    }
  }

  /// Optimize high resolution photo for WhatsApp/Instagram status
  Future<String?> optimizePhoto({
    required String inputPath,
    bool addWatermark = true,
    required Function(double progress, String status) onProgress,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outPath = p.join(tempDir.path, 'slcat_photo_${DateTime.now().millisecondsSinceEpoch}.jpg');

      onProgress(0.2, 'Optimizing Image Clarity...');

      String? watermarkPath;
      if (addWatermark) {
        watermarkPath = await _getWatermarkPath();
      }

      final List<String> args = ['-y', '-i', inputPath];

      if (addWatermark && watermarkPath != null && File(watermarkPath).existsSync()) {
        args.addAll([
          '-i', watermarkPath,
          '-filter_complex',
          '[0:v]scale=w=1080:h=1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black[base];'
          '[base][1:v]overlay=W-w:H-h[v]',
          '-map', '[v]',
        ]);
      } else {
        args.addAll([
          '-vf',
          'scale=w=1080:h=1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black',
        ]);
      }

      args.addAll([
        '-q:v', '2',
        outPath,
      ]);

      final session = await FFmpegKit.executeWithArguments(args);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        onProgress(1.0, 'Image Ready in Ultra HD!');
        return outPath;
      }
      return null;
    } catch (e, stack) {
      debugPrint('optimizePhoto error: $e\n$stack');
      return null;
    }
  }
}
