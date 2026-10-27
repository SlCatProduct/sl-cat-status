import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  /// Share file directly via standard system share sheet
  Future<void> shareFile(String filePath, {String? text}) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        text: text ?? 'Shared via SL CAT: ByeBye Blur Status',
      );
    } catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }

  /// Direct attempt to launch WhatsApp Status share
  Future<bool> shareToWhatsAppStatus(String filePath) async {
    try {
      final file = XFile(filePath);
      // Share with XFile allows user to pick WhatsApp -> "My Status" seamlessly
      final result = await Share.shareXFiles(
        [file],
        text: 'Uploaded via SL CAT HD Status',
      );
      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('WhatsApp share error: $e');
      return false;
    }
  }

  /// Launch WhatsApp App if installed
  Future<void> openWhatsApp() async {
    final uri = Uri.parse('whatsapp://');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
