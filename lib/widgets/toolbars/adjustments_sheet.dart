import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/editor_provider.dart';

class AdjustmentsSheet extends ConsumerWidget {
  const AdjustmentsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final adj = state.adjustments;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Koreksi & Filter Foto (Studio EQ)',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(editorProvider.notifier).resetAdjustments();
                  },
                  child: Text(
                    'Reset',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFEA580C),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Brightness
            _buildSliderRow(
              label: 'Kecerahan (Brightness)',
              value: adj.brightness,
              min: -0.5,
              max: 0.5,
              displayValue: '${(adj.brightness * 100).round()}',
              onChanged: (val) {
                ref.read(editorProvider.notifier).setAdjustments(
                      adj.copyWith(brightness: val),
                    );
              },
            ),

            // Contrast
            _buildSliderRow(
              label: 'Kontras (Contrast)',
              value: adj.contrast,
              min: 0.5,
              max: 1.8,
              displayValue: '${(adj.contrast * 100).round()}%',
              onChanged: (val) {
                ref.read(editorProvider.notifier).setAdjustments(
                      adj.copyWith(contrast: val),
                    );
              },
            ),

            // Saturation
            _buildSliderRow(
              label: 'Saturasi Warna (Vibrance)',
              value: adj.saturation,
              min: 0.0,
              max: 2.0,
              displayValue: '${(adj.saturation * 100).round()}%',
              onChanged: (val) {
                ref.read(editorProvider.notifier).setAdjustments(
                      adj.copyWith(saturation: val),
                    );
              },
            ),

            // Warmth
            _buildSliderRow(
              label: 'Suhu Warna (Warmth / Tint)',
              value: adj.warmth,
              min: -0.5,
              max: 0.5,
              displayValue: '${(adj.warmth * 100).round()}',
              onChanged: (val) {
                ref.read(editorProvider.notifier).setAdjustments(
                      adj.copyWith(warmth: val),
                    );
              },
            ),
            const SizedBox(height: 12),
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
