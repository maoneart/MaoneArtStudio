import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/background_config.dart';
import '../../providers/editor_provider.dart';
import '../glass_container.dart';

class BackgroundSheet extends ConsumerStatefulWidget {
  const BackgroundSheet({super.key});

  @override
  ConsumerState<BackgroundSheet> createState() => _BackgroundSheetState();
}

class _BackgroundSheetState extends ConsumerState<BackgroundSheet> {
  int _selectedTabIndex = 0; // 0: Studio Presets, 1: Solid Colors, 2: Gradients

  final List<Color> _paletteColors = const [
    Color(0xFFFFFFFF),
    Color(0xFFF4F4F5),
    Color(0xFFE4E4E7),
    Color(0xFFD4D4D8),
    Color(0xFFA1A1AA),
    Color(0xFF71717A),
    Color(0xFF27272A),
    Color(0xFF09090B),
    Color(0xFFD32F2F), // Merah Pas Foto
    Color(0xFF1976D2), // Biru Pas Foto
    Color(0xFFEA580C), // MaoneArt Orange
    Color(0xFF059669), // Emerald
    Color(0xFF7C3AED), // Purple
    Color(0xFFDB2777), // Pink
    Color(0xFFF59E0B), // Amber
    Color(0xFF06B6D4), // Cyan
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final presets = BackgroundConfig.studioPresets;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF18181B).withOpacity(0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latar Belakang (Background)',
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

          // Tab Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabChip(0, 'Preset Studio', Icons.auto_awesome_rounded),
                const SizedBox(width: 8),
                _buildTabChip(1, 'Warna Solid', Icons.palette_rounded),
                const SizedBox(width: 8),
                _buildTabChip(2, 'Galeri Kustom', Icons.image_rounded),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content Area
          if (_selectedTabIndex == 0)
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: presets.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                itemBuilder: (ctx, i) {
                  final preset = presets[i];
                  return _buildPresetCard(preset);
                },
              ),
            )
          else if (_selectedTabIndex == 1)
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _paletteColors.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  final color = _paletteColors[i];
                  final isSelected = state.background.type == BackgroundType.solid &&
                      state.background.solidColor.value == color.value;
                  return GestureDetector(
                    onTap: () {
                      ref.read(editorProvider.notifier).setBackground(
                            BackgroundConfig(
                              type: BackgroundType.solid,
                              solidColor: color,
                            ),
                          );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFEA580C)
                              : Colors.white.withOpacity(0.2),
                          width: isSelected ? 3.0 : 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFEA580C).withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Center(
                              child: Icon(
                                Icons.check_rounded,
                                color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                size: 24,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            )
          else
            // Custom Gallery Background
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        final bytes = await picked.readAsBytes();
                        ref.read(editorProvider.notifier).setBackground(
                              BackgroundConfig(
                                type: BackgroundType.customImage,
                                customImageBytes: bytes,
                              ),
                            );
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                    label: Text(
                      'Pilih Gambar dari Galeri',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTabChip(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEA580C)
              : const Color(0xFF27272A).withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFF97316) : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFFA1A1AA),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFFA1A1AA),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetCard(StudioPreset preset) {
    return GestureDetector(
      onTap: () {
        ref.read(editorProvider.notifier).setBackground(preset.config);
      },
      child: Container(
        width: 76,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: _buildPresetThumbnail(preset.config),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              color: const Color(0xFF27272A),
              child: Text(
                preset.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetThumbnail(BackgroundConfig config) {
    if (config.type == BackgroundType.transparent) {
      return Container(
        color: const Color(0xFF3F3F46),
        child: const Center(
          child: Icon(Icons.grid_view_rounded, size: 20, color: Colors.white54),
        ),
      );
    } else if (config.type == BackgroundType.solid) {
      return Container(color: config.solidColor);
    } else if (config.type == BackgroundType.gradient) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: config.gradientColors,
          ),
        ),
      );
    }
    return Container(color: Colors.black);
  }
}
