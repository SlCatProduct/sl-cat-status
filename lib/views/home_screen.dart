import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/status_provider.dart';
import '../services/vip_service.dart';
import '../widgets/feature_card.dart';
import '../widgets/sl_cat_brand_header.dart';
import 'photo_optimizer_screen.dart';
import 'saved_status_screen.dart';
import 'status_saver_screen.dart';
import 'video_compress_screen.dart';
import 'video_splitter_screen.dart';
import 'vip_pro_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const SlCatBrandHeader(compact: true),
        actions: [
          Consumer<VipService>(
            builder: (context, vip, _) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VipProScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: vip.isVip
                          ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                          : [const Color(0xFF242B38), const Color(0xFF161922)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: vip.isVip ? const Color(0xFFFFD700) : const Color(0xFFFFD700).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: vip.isVip ? Colors.black : const Color(0xFFFFD700),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vip.isVip ? 'VIP' : 'PRO',
                        style: GoogleFonts.rajdhani(
                          color: vip.isVip ? Colors.black : const Color(0xFFFFD700),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.folder_special, color: Color(0xFF00F0FF)),
            tooltip: 'Saved Statuses',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedStatusScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SlCatBrandHeader(),
            const SizedBox(height: 16),

            // Top VIP Promo / Active Banner
            Consumer<VipService>(
              builder: (context, vip, _) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VipProScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: vip.isVip
                            ? [
                                const Color(0xFFFFD700).withOpacity(0.18),
                                const Color(0xFFFFA500).withOpacity(0.08),
                              ]
                            : [
                                const Color(0xFFFFD700).withOpacity(0.12),
                                const Color(0xFF00F0FF).withOpacity(0.06),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: vip.isVip
                            ? const Color(0xFFFFD700).withOpacity(0.5)
                            : const Color(0xFFFFD700).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.stars, color: Color(0xFFFFD700), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vip.isVip ? 'SL CAT VIP ACTIVE' : 'UPGRADE TO SL CAT VIP',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: const Color(0xFFFFD700),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vip.isVip
                                    ? 'Watermark-free exports & Turbo mode active'
                                    : 'Remove watermark, turbo encode & unlock status saver',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFFCBD5E1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Color(0xFFFFD700), size: 14),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            Text(
              'CHOOSE TOOL',
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            FeatureCard(
              title: 'Pure HD Video Status',
              subtitle: 'Eliminate blur with SL CAT 1-Second GOP & H.264 profile',
              tag: 'ANTI-BLUR',
              icon: Icons.video_collection,
              iconGradient: const LinearGradient(
                colors: [Color(0xFF00F0FF), Color(0xFF0072FF)],
              ),
              onTap: () async {
                final provider = context.read<StatusProvider>();
                final picked = await provider.pickVideo();
                if (picked && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VideoCompressScreen()),
                  );
                } else if (!picked && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        provider.errorMessage ?? 'Please install the native SL CAT App on your device for hardware video compression.',
                        style: GoogleFonts.inter(),
                      ),
                    ),
                  );
                }
              },
            ),
            FeatureCard(
              title: 'WhatsApp Status Saver',
              subtitle: 'Download full HD photos & videos from WhatsApp & WA Business',
              tag: 'STATUS SAVER',
              icon: Icons.download_for_offline,
              iconGradient: const LinearGradient(
                colors: [Color(0xFF25D366), Color(0xFF128C7E)],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatusSaverScreen()),
                );
              },
            ),
            FeatureCard(
              title: '30-Second Status Splitter',
              subtitle: 'Slice long videos into consecutive 30s HD status clips',
              tag: 'SMART SLICE',
              icon: Icons.content_cut,
              iconGradient: const LinearGradient(
                colors: [Color(0xFFFF007A), Color(0xFF7928CA)],
              ),
              onTap: () async {
                final provider = context.read<StatusProvider>();
                final picked = await provider.pickVideo();
                if (picked && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VideoSplitterScreen()),
                  );
                } else if (!picked && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        provider.errorMessage ?? 'Please install the native SL CAT App on your device for hardware video compression.',
                        style: GoogleFonts.inter(),
                      ),
                    ),
                  );
                }
              },
            ),
            FeatureCard(
              title: 'Ultra HD Photo Status',
              subtitle: 'Pre-scale photos to 1080x1920 without WhatsApp blur',
              tag: 'LOSSLESS',
              icon: Icons.photo_filter,
              iconGradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              onTap: () async {
                final provider = context.read<StatusProvider>();
                final picked = await provider.pickPhoto();
                if (picked && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PhotoOptimizerScreen()),
                  );
                }
              },
            ),
            FeatureCard(
              title: 'Saved Exports Vault',
              subtitle: 'Access and re-share all your optimized status videos',
              tag: 'GALLERY',
              icon: Icons.history,
              iconGradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavedStatusScreen()),
                );
              },
            ),
            FeatureCard(
              title: 'SL CAT VIP PRO',
              subtitle: 'Zero watermark, turbo engine & custom brand branding',
              tag: 'VIP ACCESS',
              icon: Icons.workspace_premium,
              iconGradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VipProScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildHowItWorksTip(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksTip() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E2638)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 8),
              Text(
                'How SL CAT Fixes WhatsApp Blur?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'WhatsApp automatically damages videos exceeding 720p or high bitrate using aggressive compression. SL CAT pre-compresses your video locally to the exact target bitrate and 1-second keyframe GOP, fooling WhatsApp into skipping its blurry re-compression!',
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.5,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
