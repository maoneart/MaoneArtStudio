import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/editor_provider.dart';

class TextBadgeSheet extends ConsumerStatefulWidget {
  const TextBadgeSheet({super.key});

  @override
  ConsumerState<TextBadgeSheet> createState() => _TextBadgeSheetState();
}

class _TextBadgeSheetState extends ConsumerState<TextBadgeSheet> {
  final TextEditingController _textController = TextEditingController();
  Color _selectedTextColor = Colors.white;

  final List<Map<String, dynamic>> _quickBadges = [
    {
      'label': '🔥 BEST SELLER',
      'bgColor': const Color(0xFFDC2626),
      'textColor': Colors.white,
    },
    {
      'label': '⚡ FLASH SALE',
      'bgColor': const Color(0xFFEA580C),
      'textColor': Colors.white,
    },
    {
      'label': '🎉 DISKON 50%',
      'bgColor': const Color(0xFFE11D48),
      'textColor': Colors.white,
    },
    {
      'label': '⭐ ORIGINAL 100%',
      'bgColor': const Color(0xFF059669),
      'textColor': Colors.white,
    },
    {
      'label': '🚚 GRATIS ONGKIR',
      'bgColor': const Color(0xFF0284C7),
      'textColor': Colors.white,
    },
    {
      'label': '✨ NEW ARRIVAL',
      'bgColor': const Color(0xFF7C3AED),
      'textColor': Colors.white,
    },
    {
      'label': '💎 PREMIUM QUALITY',
      'bgColor': const Color(0xFFD97706),
      'textColor': Colors.black,
    },
    {
      'label': '🏷️ PROMO SPESIAL',
      'bgColor': const Color(0xFF0F172A),
      'textColor': const Color(0xFFFBBF24),
    },
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF18181B).withOpacity(0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1.2,
        ),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tambah Teks & Badge Toko',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Badge E-Commerce Presets
            Text(
              'Badge Produk Toko Online',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFA1A1AA),
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickBadges.map((badge) {
                return ActionChip(
                  label: Text(
                    badge['label'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: badge['textColor'],
                    ),
                  ),
                  backgroundColor: badge['bgColor'],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.white.withOpacity(0.15)),
                  ),
                  onPressed: () {
                    ref.read(editorProvider.notifier).addBadgeLayer(
                          badge['label'],
                          badge['bgColor'],
                          badge['textColor'],
                        );
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Custom Text Field
            Text(
              'Teks Kustom',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFA1A1AA),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Tulis teks di sini...',
                      hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF71717A)),
                      filled: true,
                      fillColor: const Color(0xFF27272A),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFFEA580C), width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_textController.text.trim().isNotEmpty) {
                      ref.read(editorProvider.notifier).addTextLayer(
                            _textController.text.trim(),
                            textColor: _selectedTextColor,
                          );
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tambah',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
