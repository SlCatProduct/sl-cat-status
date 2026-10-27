import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/status_provider.dart';
import '../services/share_service.dart';

class VideoSplitterScreen extends StatelessWidget {
  const VideoSplitterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shareService = ShareService();

    return Consumer<StatusProvider>(
      builder: (context, provider, _) {
        final file = provider.selectedFile;
        final totalDurationSec = provider.originalDurationMs ~/ 1000;
        final numClips = totalDurationSec > 0
            ? (totalDurationSec / provider.splitDurationSec).ceil()
            : 0;

        return Scaffold(
          backgroundColor: const Color(0xFF0C0E14),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'SL CAT 30s Status Slicer',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: file == null
              ? _buildNoFileView(context, provider)
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Info & Clip Calculation
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1F1A2C), Color(0xFF13151D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFF007A).withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Video Length',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF007A).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${totalDurationSec}s (${(totalDurationSec / 60).toStringAsFixed(1)} min)',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFFF007A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Will create $numClips Status Clips',
                              style: GoogleFonts.rajdhani(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Split without losing audio sync or HD resolution.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'CHOOSE STATUS CLIP DURATION',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildDurationOption(provider, 30, 'WhatsApp', '30s'),
                          const SizedBox(width: 10),
                          _buildDurationOption(provider, 60, 'Instagram', '60s'),
                          const SizedBox(width: 10),
                          _buildDurationOption(provider, 20, 'Facebook', '20s'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (provider.processState == ProcessState.processing)
                        _buildProcessingView(provider)
                      else if (provider.splitSegments.isNotEmpty) ...[
                        Text(
                          'STATUS CLIPS READY TO UPLOAD',
                          style: GoogleFonts.rajdhani(
                            fontSize: 13,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...provider.splitSegments.map((segment) {
                          return _buildSegmentCard(segment, shareService, provider);
                        }),
                      ] else ...[
                        _buildSplitButton(context, provider),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildDurationOption(
    StatusProvider provider,
    int seconds,
    String platform,
    String durationLabel,
  ) {
    final isSelected = provider.splitDurationSec == seconds;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setSplitDuration(seconds),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF281F38) : const Color(0xFF141720),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF007A) : const Color(0xFF222836),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Text(
                durationLabel,
                style: GoogleFonts.rajdhani(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? const Color(0xFFFF007A) : Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                platform,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentCard(
    dynamic segment,
    ShareService shareService,
    StatusProvider provider,
  ) {
    final isShared = segment.isShared as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isShared ? const Color(0xFF10B981) : const Color(0xFF242B38),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isShared
                  ? const Color(0xFF10B981).withOpacity(0.15)
                  : const Color(0xFFFF007A).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '#${segment.index}',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isShared ? const Color(0xFF10B981) : const Color(0xFFFF007A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Part ${segment.index} (${segment.durationString})',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  segment.formattedSize,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await shareService.shareToWhatsAppStatus(segment.outputPath);
              provider.markSegmentShared(segment.index - 1);
            },
            icon: Icon(
              isShared ? Icons.check : Icons.share,
              size: 16,
              color: isShared ? Colors.white : Colors.black,
            ),
            label: Text(
              isShared ? 'Shared' : 'Post Status',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isShared ? Colors.white : Colors.black,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isShared ? const Color(0xFF10B981) : const Color(0xFF00F0FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView(StatusProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF171B26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: provider.progress > 0 ? provider.progress : null,
            color: const Color(0xFFFF007A),
            backgroundColor: const Color(0xFF262D3D),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Text(
            provider.statusMessage,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitButton(BuildContext context, StatusProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => provider.startSplitting(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF007A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.content_cut, size: 22),
            const SizedBox(width: 8),
            Text(
              'SPLIT VIDEO INTO CLIPS',
              style: GoogleFonts.rajdhani(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFileView(BuildContext context, StatusProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.content_cut, size: 70, color: Color(0xFF475569)),
          const SizedBox(height: 16),
          Text(
            'Select a video to split',
            style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => provider.pickVideo(),
            icon: const Icon(Icons.file_upload),
            label: const Text('Pick Video'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF007A),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
