import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/status_provider.dart';
import '../services/share_service.dart';

class PhotoOptimizerScreen extends StatelessWidget {
  const PhotoOptimizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shareService = ShareService();

    return Consumer<StatusProvider>(
      builder: (context, provider, _) {
        final file = provider.selectedFile;

        return Scaffold(
          backgroundColor: const Color(0xFF0C0E14),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'SL CAT Ultra HD Photo Status',
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
              ? _buildNoPhotoView(context, provider)
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      Container(
                        height: 380,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161922),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: provider.resultPath != null
                              ? Image.file(File(provider.resultPath!), fit: BoxFit.contain)
                              : Image.file(file, fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (provider.processState == ProcessState.processing)
                        LinearProgressIndicator(
                          value: provider.progress > 0 ? provider.progress : null,
                          color: const Color(0xFF10B981),
                          backgroundColor: const Color(0xFF262D3D),
                        )
                      else if (provider.resultPath != null) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF10B981)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                              const SizedBox(width: 10),
                              Text(
                                'Ultra HD Status Ready! (Zero Blur)',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                shareService.shareToWhatsAppStatus(provider.resultPath!),
                            icon: const Icon(Icons.share, color: Colors.black),
                            label: Text(
                              'POST TO WHATSAPP STATUS',
                              style: GoogleFonts.rajdhani(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () => provider.startPhotoOptimization(),
                            icon: const Icon(Icons.auto_fix_high, color: Colors.black),
                            label: Text(
                              'OPTIMIZE PHOTO FOR STATUS',
                              style: GoogleFonts.rajdhani(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildNoPhotoView(BuildContext context, StatusProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_outlined, size: 70, color: Color(0xFF475569)),
          const SizedBox(height: 16),
          Text(
            'Select a photo to optimize',
            style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => provider.pickPhoto(),
            icon: const Icon(Icons.image),
            label: const Text('Pick Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
