import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/status_provider.dart';
import '../services/share_service.dart';
import '../widgets/stats_badge.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  VideoPlayerController? _controller;
  final ShareService _shareService = ShareService();

  @override
  void initState() {
    super.initState();
    final provider = context.read<StatusProvider>();
    if (provider.resultPath != null) {
      _controller = VideoPlayerController.file(File(provider.resultPath!))
        ..initialize().then((_) {
          setState(() {});
          _controller?.setLooping(true);
          _controller?.play();
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatusProvider>();
    final originalMb = (provider.originalSize / (1024 * 1024)).toStringAsFixed(1);
    final optimizedMb = (provider.resultSize / (1024 * 1024)).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Optimization Complete!',
          style: GoogleFonts.rajdhani(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF10B981),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              provider.reset();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Video Player Box
            Container(
              height: 380,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: _controller != null && _controller!.value.isInitialized
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _controller!.value.isPlaying
                                    ? _controller!.pause()
                                    : _controller!.play();
                              });
                            },
                            child: AnimatedOpacity(
                              opacity: _controller!.value.isPlaying ? 0.0 : 0.8,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_arrow, size: 40, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Performance & Anti-Blur Metric Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161922),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF242B38)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StatsBadge(
                        icon: Icons.unarchive,
                        label: 'Original Size',
                        value: '$originalMb MB',
                        color: const Color(0xFF94A3B8),
                      ),
                      const Icon(Icons.arrow_forward, color: Color(0xFF00F0FF), size: 18),
                      StatsBadge(
                        icon: Icons.verified,
                        label: 'SL CAT HD Size',
                        value: '$optimizedMb MB',
                        color: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield, color: Color(0xFF10B981), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'WhatsApp Blur Blocked: 100% Verified',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 1-Click WhatsApp Status Share Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (provider.resultPath != null) {
                    _shareService.shareToWhatsAppStatus(provider.resultPath!);
                  }
                },
                icon: const Icon(Icons.send_rounded, color: Colors.black, size: 22),
                label: Text(
                  'POST DIRECT TO WHATSAPP STATUS',
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Other Share Options
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (provider.resultPath != null) {
                        _shareService.shareFile(provider.resultPath!);
                      }
                    },
                    icon: const Icon(Icons.share, color: Colors.white, size: 18),
                    label: Text(
                      'More Options',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF334155)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      provider.reset();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.refresh, color: Color(0xFF00F0FF), size: 18),
                    label: Text(
                      'Optimize Another',
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF00F0FF)),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF00F0FF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
