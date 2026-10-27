import 'package:flutter/material.dart';

enum PresetType {
  whatsappHd,
  whatsappUltraHd,
  instagramStory,
  facebookStory,
}

class CompressionPreset {
  final PresetType type;
  final String title;
  final String subtitle;
  final int targetWidth;
  final int targetHeight;
  final int videoBitrateKbps;
  final int maxBitrateKbps;
  final int fps;
  final int gopSize; // Keyframe interval (crucial for WhatsApp blur fix!)
  final IconData icon;

  const CompressionPreset({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.targetWidth,
    required this.targetHeight,
    required this.videoBitrateKbps,
    required this.maxBitrateKbps,
    required this.fps,
    required this.gopSize,
    required this.icon,
  });

  static const List<CompressionPreset> presets = [
    CompressionPreset(
      type: PresetType.whatsappHd,
      title: 'WhatsApp Pure HD (Recommended)',
      subtitle: '720x1280 @ 30fps • Best Anti-Blur algorithm',
      targetWidth: 720,
      targetHeight: 1280,
      videoBitrateKbps: 2800,
      maxBitrateKbps: 3200,
      fps: 30,
      gopSize: 30, // 1 keyframe every 1 sec prevents WA re-encode
      icon: Icons.high_quality,
    ),
    CompressionPreset(
      type: PresetType.whatsappUltraHd,
      title: 'WhatsApp 1080p Ultra HD',
      subtitle: '1080x1920 @ 30fps • Maximum detail for modern devices',
      targetWidth: 1080,
      targetHeight: 1920,
      videoBitrateKbps: 3800,
      maxBitrateKbps: 4200,
      fps: 30,
      gopSize: 30,
      icon: Icons.hd,
    ),
    CompressionPreset(
      type: PresetType.instagramStory,
      title: 'Instagram Story HD',
      subtitle: '1080x1920 @ 30fps • Smooth 4.5 Mbps bitstream',
      targetWidth: 1080,
      targetHeight: 1920,
      videoBitrateKbps: 4500,
      maxBitrateKbps: 5000,
      fps: 30,
      gopSize: 30,
      icon: Icons.camera_alt,
    ),
    CompressionPreset(
      type: PresetType.facebookStory,
      title: 'Facebook Story',
      subtitle: '720x1280 @ 30fps • Optimized for FB feed & story',
      targetWidth: 720,
      targetHeight: 1280,
      videoBitrateKbps: 2400,
      maxBitrateKbps: 2800,
      fps: 30,
      gopSize: 30,
      icon: Icons.facebook,
    ),
  ];
}
