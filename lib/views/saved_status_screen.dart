import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/status_provider.dart';
import '../services/share_service.dart';

class SavedStatusScreen extends StatefulWidget {
  const SavedStatusScreen({super.key});

  @override
  State<SavedStatusScreen> createState() => _SavedStatusScreenState();
}

class _SavedStatusScreenState extends State<SavedStatusScreen> {
  final ShareService _shareService = ShareService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatusProvider>().loadSavedExports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SL CAT Exports Vault',
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
      body: Consumer<StatusProvider>(
        builder: (context, provider, _) {
          final files = provider.savedExports;

          if (files.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 70, color: Color(0xFF475569)),
                  const SizedBox(height: 16),
                  Text(
                    'No saved statuses yet',
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Videos optimized with SL CAT will appear here',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              final sizeMb = (file.lengthSync() / (1024 * 1024)).toStringAsFixed(2);
              final name = file.path.split('/').last.split('\\').last;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF161922),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF242B38)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F0FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.videocam, color: Color(0xFF00F0FF)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$sizeMb MB • Anti-Blur Optimized',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Color(0xFF00F0FF)),
                      onPressed: () => _shareService.shareToWhatsAppStatus(file.path),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                      onPressed: () {
                        file.deleteSync();
                        provider.loadSavedExports();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
