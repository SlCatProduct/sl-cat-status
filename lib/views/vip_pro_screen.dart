import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/vip_service.dart';

class VipProScreen extends StatefulWidget {
  const VipProScreen({super.key});

  @override
  State<VipProScreen> createState() => _VipProScreenState();
}

class _VipProScreenState extends State<VipProScreen> {
  int _selectedTierIndex = 1; // Default to Yearly (Best Value)
  final TextEditingController _promoController = TextEditingController();
  final TextEditingController _watermarkController = TextEditingController();

  final List<Map<String, dynamic>> _tiers = [
    {
      'id': 'slcat_vip_monthly',
      'title': '1 MONTH',
      'price': '\$2.99',
      'period': '/ month',
      'tag': 'FLEXIBLE',
      'color': const Color(0xFF00F0FF),
    },
    {
      'id': 'slcat_vip_yearly',
      'title': '1 YEAR',
      'price': '\$14.99',
      'period': '/ year (\$1.25/mo)',
      'tag': 'BEST VALUE 60% OFF',
      'color': const Color(0xFFFFD700),
    },
    {
      'id': 'slcat_vip_lifetime',
      'title': 'LIFETIME',
      'price': '\$29.99',
      'period': 'one-time pay',
      'tag': 'FOREVER ACCESS',
      'color': const Color(0xFFFF007A),
    },
  ];

  @override
  void initState() {
    super.initState();
    final vip = context.read<VipService>();
    _watermarkController.text = vip.customWatermarkText;
  }

  @override
  void dispose() {
    _promoController.dispose();
    _watermarkController.dispose();
    super.dispose();
  }

  void _showPromoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161922),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.key, color: Color(0xFFFFD700)),
            const SizedBox(width: 10),
            Text(
              'Redeem Promo Code',
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
            Text(
              'Enter your VIP activation code (e.g. SLCATVIP or SLCAT2026):',
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _promoController,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.rajdhani(
                color: const Color(0xFFFFD700),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0C0E14),
                hintText: 'ENTER CODE',
                hintStyle: GoogleFonts.rajdhani(color: Colors.white24, letterSpacing: 2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF242B38)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.rajdhani(color: const Color(0xFF64748B), fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final vip = context.read<VipService>();
              final success = vip.redeemPromoCode(_promoController.text);
              Navigator.pop(ctx);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    content: Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          'SL CAT VIP UNLOCKED SUCCESSFULLY! 👑',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Invalid promo code. Please check and retry.',
                      style: GoogleFonts.inter(),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'ACTIVATE',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomWatermarkDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161922),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.branding_watermark, color: Color(0xFF00F0FF)),
            const SizedBox(width: 10),
            Text(
              'Custom Brand Watermark',
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
            Text(
              'As a VIP member, you can display your own handle or brand name:',
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _watermarkController,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0C0E14),
                hintText: '@yourusername or Business Name',
                hintStyle: GoogleFonts.inter(color: Colors.white24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF242B38)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00F0FF), width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.rajdhani(color: const Color(0xFF64748B), fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<VipService>().setCustomWatermarkText(_watermarkController.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF00F0FF),
                  content: Text(
                    'Custom branding updated!',
                    style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00F0FF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'SAVE',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VipService>(
      builder: (context, vip, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0C0E14),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (vip.isVip)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars, color: Colors.black, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            vip.tierDisplayName,
                            style: GoogleFonts.rajdhani(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // Glowing VIP Badge Header
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.workspace_premium, size: 44, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'SL CAT VIP PRO',
                  style: GoogleFonts.rajdhani(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Unlock Unlimited HD Power & Clean Exports',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF94A3B8),
                  ),
                ),

                const SizedBox(height: 24),

                // VIP Status active banner or Features List
                if (vip.isVip) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFD700).withOpacity(0.15),
                          const Color(0xFFFFA500).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.verified, color: Color(0xFFFFD700), size: 36),
                        const SizedBox(height: 10),
                        Text(
                          'You are an Active VIP Member!',
                          style: GoogleFonts.rajdhani(
                            color: const Color(0xFFFFD700),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enjoy 100% watermark-free exports, turbo processing, and full status saver access.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _showCustomWatermarkDialog,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF00F0FF)),
                            foregroundColor: const Color(0xFF00F0FF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.edit, size: 16),
                          label: Text(
                            'CUSTOMIZE BRAND WATERMARK',
                            style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Perks Grid
                _buildPerksSection(),

                const SizedBox(height: 28),

                // Pricing Tiers (if not VIP or to change tier)
                if (!vip.isVip) ...[
                  Text(
                    'CHOOSE YOUR PLAN',
                    style: GoogleFonts.rajdhani(
                      fontSize: 13,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 14),

                  ...List.generate(_tiers.length, (index) {
                    final tier = _tiers[index];
                    final isSelected = _selectedTierIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTierIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1E2838)
                              : const Color(0xFF141720),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? tier['color'] as Color : const Color(0xFF242B38),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: index,
                              groupValue: _selectedTierIndex,
                              activeColor: tier['color'] as Color,
                              onChanged: (val) => setState(() => _selectedTierIndex = val!),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        tier['title'],
                                        style: GoogleFonts.rajdhani(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (tier['color'] as Color).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          tier['tag'],
                                          style: GoogleFonts.rajdhani(
                                            color: tier['color'] as Color,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tier['period'],
                                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              tier['price'],
                              style: GoogleFonts.rajdhani(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: tier['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Upgrade Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () async {
                        final selected = _tiers[_selectedTierIndex];
                        // If Play Store products loaded, attempt store checkout
                        final matching = vip.products.where((p) => p.id == selected['id']).toList();
                        if (matching.isNotEmpty) {
                          await vip.buyProduct(matching.first);
                        } else {
                          // If store not live yet or in offline sandbox, offer promo redeem
                          _showPromoDialog();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                      ),
                      child: Text(
                        'CONTINUE TO VIP PRO',
                        style: GoogleFonts.rajdhani(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Footer Actions: Promo Code & Restore
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _showPromoDialog,
                      icon: const Icon(Icons.key, color: Color(0xFF00F0FF), size: 16),
                      label: Text(
                        'Redeem Code',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF00F0FF),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Colors.white24)),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => vip.restorePurchases(),
                      icon: const Icon(Icons.restore, color: Color(0xFF94A3B8), size: 16),
                      label: Text(
                        'Restore Purchases',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                if (vip.isVip) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      await vip.resetVipForTesting();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('VIP status reset to Free tier')),
                        );
                      }
                    },
                    child: Text(
                      'Reset to Free Mode (Testing)',
                      style: GoogleFonts.inter(color: Colors.white30, fontSize: 11),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerksSection() {
    final perks = [
      {
        'icon': Icons.water_drop_outlined,
        'color': const Color(0xFF00F0FF),
        'title': '100% Watermark Free',
        'desc': 'Export crisp statuses with zero brand watermarks',
      },
      {
        'icon': Icons.flash_on,
        'color': const Color(0xFFFFD700),
        'title': 'Turbo GPU Engine',
        'desc': '3x faster hardware-accelerated H.264 status encoding',
      },
      {
        'icon': Icons.branding_watermark,
        'color': const Color(0xFFFF007A),
        'title': 'Custom Brand Logo',
        'desc': 'Promote your own business handle on video corners',
      },
      {
        'icon': Icons.download_done,
        'color': const Color(0xFF10B981),
        'title': 'Full WhatsApp Status Saver',
        'desc': 'Save both WhatsApp & Business statuses with zero ads',
      },
      {
        'icon': Icons.block,
        'color': const Color(0xFFA855F7),
        'title': 'Pure Ad-Free Studio',
        'desc': 'Fast, uninterrupted workflow with zero popup ads',
      },
      {
        'icon': Icons.support_agent,
        'color': const Color(0xFF38BDF8),
        'title': 'VIP Priority Updates',
        'desc': 'Immediate access to all upcoming anti-blur algorithms',
      },
    ];

    return Column(
      children: perks.map((perk) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF141720),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF222836)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (perk['color'] as Color).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(perk['icon'] as IconData, color: perk['color'] as Color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      perk['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      perk['desc'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check, color: Color(0xFF10B981), size: 18),
            ],
          ),
        );
      }).toList(),
    );
  }
}
