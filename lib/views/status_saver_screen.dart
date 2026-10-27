import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../models/status_media_item.dart';
import '../services/status_saver_service.dart';

class StatusSaverScreen extends StatefulWidget {
  const StatusSaverScreen({super.key});

  @override
  State<StatusSaverScreen> createState() => _StatusSaverScreenState();
}

class _StatusSaverScreenState extends State<StatusSaverScreen>
    with SingleTickerProviderStateMixin {
  final StatusSaverService _service = StatusSaverService();
  late TabController _tabController;

  bool _isLoading = true;
  bool _hasPermission = true;
  String _selectedSource = 'All';

  List<StatusMediaItem> _images = [];
  List<StatusMediaItem> _videos = [];
  List<StatusMediaItem> _saved = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkAndLoad();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAndLoad() async {
    setState(() => _isLoading = true);
    final granted = await _service.checkPermission();
    if (!granted) {
      final requested = await _service.requestPermission();
      setState(() => _hasPermission = requested);
      if (!requested) {
        setState(() => _isLoading = false);
        return;
      }
    } else {
      setState(() => _hasPermission = true);
    }

    await _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    setState(() => _isLoading = true);
    try {
      final all = await _service.fetchAllStatuses(filterSource: _selectedSource);
      final saved = await _service.fetchSavedStatuses();

      setState(() {
        _images = all.where((i) => !i.isVideo).toList();
        _videos = all.where((i) => i.isVideo).toList();
        _saved = saved;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading statuses: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveItem(StatusMediaItem item) async {
    final result = await _service.saveStatus(item);
    if (result != null && mounted) {
      setState(() {
        item.isSaved = true;
      });
      _loadStatuses();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Saved to Gallery (Pictures/SL_CAT_Saved)!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Failed to save status. Storage access might be restricted.',
            style: GoogleFonts.inter(),
          ),
        ),
      );
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161922),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: Color(0xFF25D366)),
            const SizedBox(width: 10),
            Text(
              'How to Download Statuses',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepRow(1, 'Open WhatsApp or WhatsApp Business'),
            const SizedBox(height: 12),
            _buildStepRow(2, 'View the status story (Photo or Video) in WhatsApp'),
            const SizedBox(height: 12),
            _buildStepRow(3, 'Come back to SL CAT Status Saver'),
            const SizedBox(height: 12),
            _buildStepRow(4, 'Tap Save or Share to keep it permanently in Ultra HD!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'GOT IT',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF00F0FF),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(int num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFF25D366).withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF25D366)),
          ),
          alignment: Alignment.center,
          child: Text(
            '$num',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF25D366),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: const Color(0xFFCBD5E1),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _openPreview(StatusMediaItem item) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (ctx) => _StatusPreviewDialog(
        item: item,
        onSave: () => _saveItem(item),
        onShare: () => _service.shareStatus(item),
        onRepost: () => _service.repostToWhatsApp(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.download_for_offline, color: Color(0xFF25D366), size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Status Saver',
              style: GoogleFonts.rajdhani(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Color(0xFF00F0FF)),
            tooltip: 'Filter Source',
            color: const Color(0xFF161922),
            onSelected: (val) {
              setState(() => _selectedSource = val);
              _loadStatuses();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'All', child: Text('All WhatsApps', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'WhatsApp', child: Text('WhatsApp Only', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'WhatsApp Business', child: Text('WA Business Only', style: TextStyle(color: Colors.white))),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _loadStatuses,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF94A3B8)),
            tooltip: 'How to use',
            onPressed: _showHelpDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF25D366),
          indicatorWeight: 3,
          labelColor: const Color(0xFF25D366),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 15),
          tabs: [
            Tab(text: 'Photos (${_images.length})'),
            Tab(text: 'Videos (${_videos.length})'),
            Tab(text: 'Saved (${_saved.length})'),
          ],
        ),
      ),
      body: !_hasPermission
          ? _buildPermissionWarning()
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFF25D366)),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMediaGrid(_images, isVideo: false),
                    _buildMediaGrid(_videos, isVideo: true),
                    _buildMediaGrid(_saved, isSavedTab: true),
                  ],
                ),
    );
  }

  Widget _buildPermissionWarning() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.folder_shared, size: 50, color: Color(0xFFF59E0B)),
            ),
            const SizedBox(height: 20),
            Text(
              'Storage Access Required',
              style: GoogleFonts.rajdhani(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'To detect and download statuses from WhatsApp, please grant storage/all files permission.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _checkAndLoad,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.security, size: 20),
              label: Text(
                'GRANT ACCESS',
                style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(List<StatusMediaItem> items, {bool isVideo = false, bool isSavedTab = false}) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isVideo
                    ? Icons.videocam_off_outlined
                    : isSavedTab
                        ? Icons.folder_open
                        : Icons.photo_size_select_actual_outlined,
                size: 64,
                color: const Color(0xFF334155),
              ),
              const SizedBox(height: 16),
              Text(
                isSavedTab ? 'No Saved Statuses Yet' : 'No Statuses Found',
                style: GoogleFonts.rajdhani(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSavedTab
                    ? 'Statuses you download will appear here permanently.'
                    : 'Open WhatsApp, view your friends\' statuses, then pull down to refresh!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _loadStatuses,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF25D366)),
                  foregroundColor: const Color(0xFF25D366),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(
                  'CHECK AGAIN',
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStatuses,
      color: const Color(0xFF25D366),
      backgroundColor: const Color(0xFF161922),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildStatusCard(item);
        },
      ),
    );
  }

  Widget _buildStatusCard(StatusMediaItem item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isSaved ? const Color(0xFF10B981).withOpacity(0.5) : const Color(0xFF242B38),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail / Content
          GestureDetector(
            onTap: () => _openPreview(item),
            child: item.isVideo
                ? Container(
                    color: const Color(0xFF0F172A),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F0FF).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow, color: Color(0xFF00F0FF), size: 36),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.formattedSize,
                            style: GoogleFonts.rajdhani(
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Image.file(
                    File(item.path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.white24),
                    ),
                  ),
          ),

          // Top Badges
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // App Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.appSource == 'WhatsApp Business' ? 'WA BIZ' : 'WA',
                    style: GoogleFonts.rajdhani(
                      color: const Color(0xFF25D366),
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                if (item.isSaved)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, size: 10, color: Colors.white),
                        const SizedBox(width: 2),
                        Text(
                          'SAVED',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.95),
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Save Button
                  IconButton(
                    icon: Icon(
                      item.isSaved ? Icons.check_circle : Icons.file_download,
                      color: item.isSaved ? const Color(0xFF10B981) : const Color(0xFF00F0FF),
                      size: 22,
                    ),
                    tooltip: 'Save',
                    onPressed: () => _saveItem(item),
                  ),
                  // Repost Button
                  IconButton(
                    icon: const Icon(Icons.reply, color: Color(0xFF25D366), size: 22),
                    tooltip: 'Re-post',
                    onPressed: () => _service.repostToWhatsApp(item),
                  ),
                  // Share Button
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white70, size: 20),
                    tooltip: 'Share',
                    onPressed: () => _service.shareStatus(item),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPreviewDialog extends StatefulWidget {
  final StatusMediaItem item;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onRepost;

  const _StatusPreviewDialog({
    required this.item,
    required this.onSave,
    required this.onShare,
    required this.onRepost,
  });

  @override
  State<_StatusPreviewDialog> createState() => _StatusPreviewDialogState();
}

class _StatusPreviewDialogState extends State<_StatusPreviewDialog> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.item.isVideo) {
      _videoController = VideoPlayerController.file(File(widget.item.path))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController?.play();
            _videoController?.setLooping(true);
          }
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header / Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.item.isVideo ? 'Video Status' : 'Photo Status',
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Main media display
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.black,
                child: widget.item.isVideo
                    ? (_videoController != null && _videoController!.value.isInitialized)
                        ? AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                VideoPlayer(_videoController!),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_videoController!.value.isPlaying) {
                                        _videoController!.pause();
                                      } else {
                                        _videoController!.play();
                                      }
                                    });
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: AnimatedOpacity(
                                        opacity: _videoController!.value.isPlaying ? 0.0 : 0.8,
                                        duration: const Duration(milliseconds: 200),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(
                            height: 250,
                            child: Center(
                              child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
                            ),
                          )
                    : InteractiveViewer(
                        maxScale: 4.0,
                        child: Image.file(
                          File(widget.item.path),
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bottom Action Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF161922),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF242B38)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: widget.item.isSaved ? Icons.check_circle : Icons.download,
                  label: widget.item.isSaved ? 'Saved' : 'Save',
                  color: widget.item.isSaved ? const Color(0xFF10B981) : const Color(0xFF00F0FF),
                  onTap: () {
                    widget.onSave();
                    Navigator.pop(context);
                  },
                ),
                _buildActionButton(
                  icon: Icons.reply,
                  label: 'Re-Post',
                  color: const Color(0xFF25D366),
                  onTap: () {
                    widget.onRepost();
                    Navigator.pop(context);
                  },
                ),
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  color: const Color(0xFFFF007A),
                  onTap: () {
                    widget.onShare();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
