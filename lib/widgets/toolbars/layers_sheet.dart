import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/editor_layer.dart';
import '../../providers/editor_provider.dart';
import '../glass_container.dart';

class LayersSheet extends ConsumerWidget {
  const LayersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final layers = state.layers;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Lapisan (Layers: ${layers.length})',
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

          if (layers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada objek atau lapisan',
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF71717A)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: layers.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final layer = layers[i];
                final isSelected = layer.id == state.selectedLayerId;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFEA580C).withOpacity(0.15)
                        : const Color(0xFF27272A).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFEA580C)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon/Preview
                      Icon(
                        layer.type == LayerType.image
                            ? Icons.image_rounded
                            : layer.type == LayerType.badge
                                ? Icons.verified_rounded
                                : Icons.text_fields_rounded,
                        color: isSelected ? const Color(0xFFEA580C) : const Color(0xFFD4D4D8),
                        size: 20,
                      ),
                      const SizedBox(width: 10),

                      // Label
                      Expanded(
                        child: Text(
                          layer.type == LayerType.image
                              ? 'Foto Objek Produk'
                              : layer.text.isNotEmpty
                                  ? layer.text
                                  : 'Teks Layer',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFFE4E4E7),
                          ),
                        ),
                      ),

                      // Actions
                      IconButton(
                        icon: const Icon(Icons.flip_rounded, size: 18, color: Colors.white70),
                        tooltip: 'Balik Horizontal',
                        onPressed: () {
                          ref.read(editorProvider.notifier).toggleFlipX(layer.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.restart_alt_rounded, size: 18, color: Colors.white70),
                        tooltip: 'Reset Posisi',
                        onPressed: () {
                          ref.read(editorProvider.notifier).resetLayerTransform(layer.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.white70),
                        tooltip: 'Duplikat',
                        onPressed: () {
                          ref.read(editorProvider.notifier).duplicateLayer(layer.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                        tooltip: 'Hapus',
                        onPressed: () {
                          ref.read(editorProvider.notifier).deleteLayer(layer.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
