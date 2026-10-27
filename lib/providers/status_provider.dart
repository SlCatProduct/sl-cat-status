import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/compression_preset.dart';
import '../models/split_segment.dart';
import '../services/ffmpeg_service.dart';
import '../services/storage_service.dart';

enum ProcessState { idle, processing, completed, error }

class StatusProvider with ChangeNotifier {
  final FFmpegService _ffmpegService = FFmpegService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  // Selection state
  File? _selectedFile;
  bool _isVideo = true;
  Map<String, dynamic> _fileInfo = {};

  // Compression state
  CompressionPreset _selectedPreset = CompressionPreset.presets.first;
  bool _addWatermark = true;
  ProcessState _processState = ProcessState.idle;
  double _progress = 0.0;
  String _statusMessage = '';
  String? _resultPath;
  int _resultSize = 0;
  String? _errorMessage;

  // Splitter state
  List<SplitSegment> _splitSegments = [];
  int _splitDurationSec = 30;

  // History state
  List<File> _savedExports = [];

  // Getters
  File? get selectedFile => _selectedFile;
  bool get isVideo => _isVideo;
  Map<String, dynamic> get fileInfo => _fileInfo;
  CompressionPreset get selectedPreset => _selectedPreset;
  bool get addWatermark => _addWatermark;
  ProcessState get processState => _processState;
  double get progress => _progress;
  String get statusMessage => _statusMessage;
  String? get resultPath => _resultPath;
  int get resultSize => _resultSize;
  String? get errorMessage => _errorMessage;
  List<SplitSegment> get splitSegments => _splitSegments;
  int get splitDurationSec => _splitDurationSec;
  List<File> get savedExports => _savedExports;

  int get originalSize => _fileInfo['size'] as int? ?? 0;
  int get originalWidth => _fileInfo['width'] as int? ?? 0;
  int get originalHeight => _fileInfo['height'] as int? ?? 0;
  int get originalDurationMs => _fileInfo['durationMs'] as int? ?? 0;

  void setSelectedPreset(CompressionPreset preset) {
    _selectedPreset = preset;
    notifyListeners();
  }

  void setAddWatermark(bool value) {
    _addWatermark = value;
    notifyListeners();
  }

  void setSplitDuration(int seconds) {
    _splitDurationSec = seconds;
    notifyListeners();
  }

  Future<bool> pickVideo() async {
    try {
      if (kIsWeb) {
        _errorMessage = 'Video compression requires native device hardware. Please run the native SL CAT App on your iPhone or Android!';
        notifyListeners();
        return false;
      }
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file == null) return false;

      _selectedFile = File(file.path);
      _isVideo = true;
      _processState = ProcessState.idle;
      _progress = 0.0;
      _resultPath = null;
      _splitSegments = [];

      _fileInfo = await _ffmpegService.getVideoInfo(file.path);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to pick video: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> pickPhoto() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return false;

      _selectedFile = File(file.path);
      _isVideo = false;
      _processState = ProcessState.idle;
      _progress = 0.0;
      _resultPath = null;
      _splitSegments = [];

      final size = await _selectedFile!.length();
      _fileInfo = {'size': size, 'width': 0, 'height': 0, 'durationMs': 0};
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to pick photo: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> startCompression() async {
    if (_selectedFile == null) return;

    _processState = ProcessState.processing;
    _progress = 0.0;
    _statusMessage = 'Initializing SL CAT Engine...';
    _errorMessage = null;
    notifyListeners();

    try {
      final out = await _ffmpegService.compressVideo(
        inputPath: _selectedFile!.path,
        preset: _selectedPreset,
        addWatermark: _addWatermark,
        onProgress: (p, msg) {
          _progress = p;
          _statusMessage = msg;
          notifyListeners();
        },
      );

      if (out != null && File(out).existsSync()) {
        _resultPath = out;
        _resultSize = File(out).lengthSync();
        _processState = ProcessState.completed;
        await _storageService.saveToPermanentStorage(out);
      } else {
        _processState = ProcessState.error;
        _errorMessage = 'Compression failed. Please try a different video format.';
      }
    } catch (e) {
      _processState = ProcessState.error;
      _errorMessage = 'Error during optimization: $e';
    }
    notifyListeners();
  }

  Future<void> startSplitting() async {
    if (_selectedFile == null) return;

    _processState = ProcessState.processing;
    _progress = 0.0;
    _statusMessage = 'Splitting into $_splitDurationSec-second clips...';
    _splitSegments = [];
    _errorMessage = null;
    notifyListeners();

    try {
      final segments = await _ffmpegService.splitVideoIntoStatusClips(
        inputPath: _selectedFile!.path,
        segmentDurationSec: _splitDurationSec,
        addWatermark: _addWatermark,
        onProgress: (p, msg) {
          _progress = p;
          _statusMessage = msg;
          notifyListeners();
        },
      );

      if (segments.isNotEmpty) {
        _splitSegments = segments;
        _processState = ProcessState.completed;
      } else {
        _processState = ProcessState.error;
        _errorMessage = 'Failed to split video.';
      }
    } catch (e) {
      _processState = ProcessState.error;
      _errorMessage = 'Split error: $e';
    }
    notifyListeners();
  }

  Future<void> startPhotoOptimization() async {
    if (_selectedFile == null) return;

    _processState = ProcessState.processing;
    _progress = 0.0;
    _statusMessage = 'Optimizing photo for Ultra HD Status...';
    _errorMessage = null;
    notifyListeners();

    try {
      final out = await _ffmpegService.optimizePhoto(
        inputPath: _selectedFile!.path,
        addWatermark: _addWatermark,
        onProgress: (p, msg) {
          _progress = p;
          _statusMessage = msg;
          notifyListeners();
        },
      );

      if (out != null && File(out).existsSync()) {
        _resultPath = out;
        _resultSize = File(out).lengthSync();
        _processState = ProcessState.completed;
        await _storageService.saveToPermanentStorage(out);
      } else {
        _processState = ProcessState.error;
        _errorMessage = 'Photo optimization failed.';
      }
    } catch (e) {
      _processState = ProcessState.error;
      _errorMessage = 'Error: $e';
    }
    notifyListeners();
  }

  void markSegmentShared(int index) {
    if (index >= 0 && index < _splitSegments.length) {
      _splitSegments[index].isShared = true;
      notifyListeners();
    }
  }

  Future<void> loadSavedExports() async {
    _savedExports = await _storageService.getExportedFiles();
    notifyListeners();
  }

  void reset() {
    _selectedFile = null;
    _resultPath = null;
    _processState = ProcessState.idle;
    _progress = 0.0;
    _statusMessage = '';
    _errorMessage = null;
    _splitSegments = [];
    notifyListeners();
  }
}
