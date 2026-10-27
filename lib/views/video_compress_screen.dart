import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/compression_preset.dart';
import '../providers/status_provider.dart';
import '../services/vip_service.dart';
import '../widgets/stats_badge.dart';
import 'result_screen.dart';
import 'vip_pro_screen.dart';

class VideoCompressScreen extends StatelessWidget {
  const VideoCompressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatusProvider>(
      builder: (context, provider, _) {
        final file = provider.selectedFile;
        final durationSec = (provider.originalDurationMs / 1000).toStringAsFixed(1);
        final sizeMb = (provider.originalSize / (1024 * 1024)).toStringAsFixed(2);
        final resolution = '${provider.originalWidth}x${provider.originalHeight}';

        return Scaffold(
          backgroundColor: const Color(0xFF0C0E14),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'SL CAT Anti-Blur Optimizer',
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
            actions: [
              IconButton(
                icon: const Icon(Icons.workspace_premium, color: Color(0xFFFFD700)),
                tooltip: 'VIP PRO',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VipProScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: file == null
              ? _buildNoFileView(context, provider)
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Stats Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161922),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF242B38)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.movie, color: Color(0xFF00F0FF), size: 22),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    file.path.split('/').last.split('\\').last,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => provider.pickVideo(),
                                  icon: const Icon(Icons.swap_horiz, size: 16, color: Color(0xFF00F0FF)),
                                  label: Text(
                                    'Change',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF00F0FF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                StatsBadge(
                                  icon: Icons.timer,
                                  label: 'Duration',
                                  value: '${durationSec}s',
                                ),
                                StatsBadge(
                                  icon: Icons.data_usage,
                                  label: 'Original Size',
                                  value: '$sizeMb MB',
                                  color: const Color(0xFFF59E0B),
                                ),
                                StatsBadge(
                                  icon: Icons.aspect_ratio,
                                  label: 'Resolution',
                                  value: resolution == '0x0' ? 'Auto' : resolution,
                                  color: const Color(0xFF10B981),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'SELECT ANTI-BLUR PRESET',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...CompressionPreset.presets.map((preset) {
                        final isSelected = provider.selectedPreset.type == preset.type;
                        return GestureDetector(
                          onTap: () => provider.setSelectedPreset(preset),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF1E2838) : const Color(0xFF141720),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF00F0FF) : const Color(0xFF222836),
                                width: isSelected ? 1.8 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  preset.icon,
                                  color: isSelected ? const Color(0xFF00F0FF) : const Color(0xFF64748B),
                                  size: 26,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        preset.title,
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        preset.subtitle,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Radio<PresetType>(
                                  value: preset.type,
                                  groupValue: provider.selectedPreset.type,
                                  activeColor: const Color(0xFF00F0FF),
                                  onChanged: (_) => provider.setSelectedPreset(preset),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      // Watermark Toggle Card with VIP Integration
                      Consumer<VipService>(
                        builder: (context, vip, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161922),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: vip.isVip
                                    ? const Color(0xFFFFD700).withOpacity(0.5)
                                    : (provider.addWatermark
                                        ? const Color(0xFF00F0FF).withOpacity(0.4)
                                        : const Color(0xFF222836)),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      vip.isVip ? Icons.stars : Icons.verified,
                                      color: vip.isVip ? const Color(0xFFFFD700) : const Color(0xFF00F0FF),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'SL CAT Watermark',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: vip.isVip
                                                      ? const Color(0xFFFFD700).withOpacity(0.15)
                                                      : Colors.white10,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  vip.isVip ? 'VIP UNLOCKED' : 'FREE',
                                                  style: GoogleFonts.rajdhani(
                                                    color: vip.isVip ? const Color(0xFFFFD700) : Colors.white60,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            vip.isVip
                                                ? (provider.addWatermark
                                                    ? 'Watermark enabled (Corner flush)'
                                                    : '100% Watermark-Free Export Active 👑')
                                                : 'Subtle watermark in bottom-right corner',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: vip.isVip && !provider.addWatermark
                                                  ? const Color(0xFF10B981)
                                                  : const Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: provider.addWatermark,
                                      activeColor: vip.isVip ? const Color(0xFFFFD700) : const Color(0xFF00F0FF),
                                      onChanged: (val) {
                                        if (!val && !vip.isVip) {
                                          // Prompt to upgrade to VIP to remove watermark
                                          _showWatermarkVipPrompt(context);
                                        } else {
                                          provider.setAddWatermark(val);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                if (provider.addWatermark) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: Image.asset(
                                      'assets/images/sl_cat_watermark.png',
                                      height: 36,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      if (provider.processState == ProcessState.processing)
                        _buildProcessingCard(provider)
                      else
                        _buildCompressButton(context, provider),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildNoFileView(BuildContext context, StatusProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.video_file_outlined, size: 70, color: Color(0xFF475569)),
          const SizedBox(height: 16),
          Text(
            'No video selected',
            style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => provider.pickVideo(),
            icon: const Icon(Icons.file_upload),
            label: const Text('Pick Video from Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00F0FF),
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingCard(StatusProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF171B26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SL CAT Engine Processing...',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${(provider.progress * 100).toInt()}%',
                style: GoogleFonts.rajdhani(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF00F0FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: provider.progress > 0 ? provider.progress : null,
              backgroundColor: const Color(0xFF262D3D),
              color: const Color(0xFF00F0FF),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            provider.statusMessage,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF94A3B8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompressButton(BuildContext context, StatusProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          await provider.startCompression();
          if (provider.processState == ProcessState.completed && context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ResultScreen()),
            );
          } else if (provider.processState == ProcessState.error && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage ?? 'Compression error'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00F0FF),
          foregroundColor: const Color(0xFF0C0E14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF00F0FF).withOpacity(0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt, size: 24, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              'APPLY SL CAT ANTI-BLUR',
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

  void _showWatermarkVipPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161922),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 28),
            const SizedBox(width: 10),
            Text(
              'SL CAT VIP PRO',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Watermark-Free Export is an exclusive VIP PRO feature.',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upgrade to SL CAT VIP to export 100% clean videos with zero watermarks, turbo encoding, and custom branding.',
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'KEEP WATERMARK',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VipProScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'GET VIP PRO',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
