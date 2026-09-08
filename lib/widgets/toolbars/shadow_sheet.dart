import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/shadow_config.dart';
import '../../providers/editor_provider.dart';

class ShadowSheet extends ConsumerWidget {
  const ShadowSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final shadow = state.shadow;

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bayangan Studio (Shadow 3D)',
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

            // Shadow Type Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeChip(
                    context,
                    ref,
                    label: 'Tanpa Bayangan',
                    type: ShadowType.none,
                    current: shadow.type,
                    icon: Icons.block_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildTypeChip(
                    context,
                    ref,
                    label: 'Lantai 3D (Produk)',
                    type: ShadowType.floorShadow,
                    current: shadow.type,
                    icon: Icons.wb_shade_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildTypeChip(
                    context,
                    ref,
                    label: 'Cast Shadow',
                    type: ShadowType.dropShadow,
                    current: shadow.type,
                    icon: Icons.filter_drama_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildTypeChip(
                    context,
                    ref,
                    label: 'Soft Ambient',
                    type: ShadowType.ambientShadow,
                    current: shadow.type,
                    icon: Icons.blur_on_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            if (shadow.type != ShadowType.none) ...[
              // Opacity Slider
              _buildSliderRow(
                label: 'Kepekatan (Opacity)',
                value: shadow.opacity,
                min: 0.0,
                max: 1.0,
                displayValue: '${(shadow.opacity * 100).round()}%',
                onChanged: (val) {
                  ref.read(editorProvider.notifier).setShadow(
                        shadow.copyWith(opacity: val),
                      );
                },
              ),

              // Blur Radius Slider
              _buildSliderRow(
                label: 'Kelembutan Blur',
                value: shadow.blurRadius,
                min: 0.0,
                max: 50.0,
                displayValue: '${shadow.blurRadius.round()}px',
                onChanged: (val) {
                  ref.read(editorProvider.notifier).setShadow(
                        shadow.copyWith(blurRadius: val),
                      );
                },
              ),

              // Distance / Height Slider
              _buildSliderRow(
                label: shadow.type == ShadowType.floorShadow
                    ? 'Posisi Bawah Produk'
                    : 'Jarak Bayangan (Distance)',
                value: shadow.distance,
                min: -20.0,
                max: 80.0,
                displayValue: '${shadow.distance.round()}px',
                onChanged: (val) {
                  ref.read(editorProvider.notifier).setShadow(
                        shadow.copyWith(distance: val),
                      );
                },
              ),

              if (shadow.type == ShadowType.dropShadow) ...[
                // Angle Slider
                _buildSliderRow(
                  label: 'Arah Cahaya (Sudut)',
                  value: shadow.angle,
                  min: 0.0,
                  max: 360.0,
                  displayValue: '${shadow.angle.round()}°',
                  onChanged: (val) {
                    ref.read(editorProvider.notifier).setShadow(
                          shadow.copyWith(angle: val),
                        );
                  },
                ),
              ],

              if (shadow.type == ShadowType.floorShadow) ...[
                // Floor Spread Slider
                _buildSliderRow(
                  label: 'Lebar Bayangan Lantai',
                  value: shadow.floorScaleX,
                  min: 0.5,
                  max: 2.0,
                  displayValue: '${(shadow.floorScaleX * 100).round()}%',
                  onChanged: (val) {
                    ref.read(editorProvider.notifier).setShadow(
                          shadow.copyWith(floorScaleX: val),
                        );
                  },
                ),
              ],
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required ShadowType type,
    required ShadowType current,
    required IconData icon,
  }) {
    final isSelected = type == current;
    return GestureDetector(
      onTap: () {
        ref.read(editorProvider.notifier).setShadow(
              ref.read(editorProvider).shadow.copyWith(type: type),
            );
      },
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

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD4D4D8),
                ),
              ),
              Text(
                displayValue,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEA580C),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFEA580C),
              inactiveTrackColor: const Color(0xFF27272A),
              thumbColor: const Color(0xFFF97316),
              overlayColor: const Color(0xFFEA580C).withOpacity(0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
