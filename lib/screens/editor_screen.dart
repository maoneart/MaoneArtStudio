import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/editor_provider.dart';
import '../services/export_service.dart';
import '../widgets/canvas_workspace.dart';
import '../widgets/glass_container.dart';
import '../widgets/maone_modal.dart';
import '../widgets/toolbars/background_sheet.dart';
import '../widgets/toolbars/shadow_sheet.dart';
import '../widgets/toolbars/ratio_sheet.dart';
import '../widgets/toolbars/adjustments_sheet.dart';
import '../widgets/toolbars/text_badge_sheet.dart';
import '../widgets/toolbars/layers_sheet.dart';
import 'export_screen.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  Future<void> _handleExport() async {
    final bytes = await ExportService.captureBoundary(
      boundaryKey: _repaintBoundaryKey,
      pixelRatio: 2.0,
      format: ExportFormat.png,
    );

    if (bytes != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExportScreen(
            previewBytes: bytes,
            repaintBoundaryKey: _repaintBoundaryKey,
          ),
        ),
      );
    } else if (mounted) {
      MaoneModal.showAlertModal(
        context: context,
        title: 'Gagal Render',
        message: 'Tidak dapat mengambil gambar dari kanvas editor.',
        icon: Icons.error_outline_rounded,
        iconColor: const Color(0xFFEF4444),
      );
    }
  }

  void _showBottomSheet(Widget sheetWidget) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => sheetWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final confirm = await MaoneModal.showConfirmModal(
          context: context,
          title: 'Tinggalkan Studio?',
          message: 'Perubahan yang belum diekspor akan hilang.',
          confirmText: 'Keluar',
          cancelText: 'Lanjut Edit',
          isDanger: true,
        );
        if (confirm && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C0A09),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // 1. Top Navigation Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // Back Button
                        GlassIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          size: 40,
                          onPressed: () async {
                            final confirm = await MaoneModal.showConfirmModal(
                              context: context,
                              title: 'Tinggalkan Studio?',
                              message: 'Perubahan yang belum diekspor akan hilang.',
                              confirmText: 'Keluar',
                              cancelText: 'Lanjut Edit',
                              isDanger: true,
                            );
                            if (confirm && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        const SizedBox(width: 8),

                        // Undo & Redo
                        GlassIconButton(
                          icon: Icons.undo_rounded,
                          size: 40,
                          iconColor: notifier.canUndo ? Colors.white : Colors.white30,
                          onPressed: notifier.canUndo ? () => notifier.undo() : null,
                        ),
                        const SizedBox(width: 6),
                        GlassIconButton(
                          icon: Icons.redo_rounded,
                          size: 40,
                          iconColor: notifier.canRedo ? Colors.white : Colors.white30,
                          onPressed: notifier.canRedo ? () => notifier.redo() : null,
                        ),
                        const Spacer(),

                        // Aspect Ratio Badge
                        GestureDetector(
                          onTap: () => _showBottomSheet(const RatioSheet()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27272A).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(state.aspectRatio.icon, size: 14, color: const Color(0xFFEA580C)),
                                const SizedBox(width: 6),
                                Text(
                                  state.aspectRatio.label.split(' ').first,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Export Button
                        ElevatedButton.icon(
                          onPressed: _handleExport,
                          icon: const Icon(Icons.file_download_outlined, size: 16, color: Colors.white),
                          label: Text(
                            'Ekspor',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA580C),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Central Interactive Canvas Viewport
                  Expanded(
                    child: CanvasWorkspace(
                      repaintBoundaryKey: _repaintBoundaryKey,
                    ),
                  ),

                  // 3. Floating Glassmorphism Tool Bar
                  Container(
                    margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      borderRadius: BorderRadius.circular(22),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // AI Cutout Toggle
                            _buildToolItem(
                              icon: Icons.auto_fix_high_rounded,
                              label: state.hasCutoutApplied ? 'Objek Asli' : 'AI Cutout',
                              isActive: state.hasCutoutApplied,
                              onTap: () {
                                if (state.hasCutoutApplied) {
                                  notifier.restoreOriginalImage();
                                } else {
                                  notifier.applyAiBackgroundRemoval();
                                }
                              },
                            ),
                            const SizedBox(width: 6),

                            // Background
                            _buildToolItem(
                              icon: Icons.wallpaper_rounded,
                              label: 'Latar',
                              onTap: () => _showBottomSheet(const BackgroundSheet()),
                            ),
                            const SizedBox(width: 6),

                            // Shadow 3D
                            _buildToolItem(
                              icon: Icons.wb_shade_rounded,
                              label: 'Bayangan 3D',
                              onTap: () => _showBottomSheet(const ShadowSheet()),
                            ),
                            const SizedBox(width: 6),

                            // Rasio Kanvas
                            _buildToolItem(
                              icon: Icons.aspect_ratio_rounded,
                              label: 'Rasio',
                              onTap: () => _showBottomSheet(const RatioSheet()),
                            ),
                            const SizedBox(width: 6),

                            // Filter & Adjustments
                            _buildToolItem(
                              icon: Icons.tune_rounded,
                              label: 'Filter EQ',
                              onTap: () => _showBottomSheet(const AdjustmentsSheet()),
                            ),
                            const SizedBox(width: 6),

                            // Text & Badge
                            _buildToolItem(
                              icon: Icons.text_fields_rounded,
                              label: 'Teks & Badge',
                              onTap: () => _showBottomSheet(const TextBadgeSheet()),
                            ),
                            const SizedBox(width: 6),

                            // Layers
                            _buildToolItem(
                              icon: Icons.layers_rounded,
                              label: 'Lapisan',
                              badgeCount: state.layers.length,
                              onTap: () => _showBottomSheet(const LayersSheet()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 4. Loading Overlay during AI Cutout
              if (state.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.65),
                  child: Center(
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SpinKitWaveSpinner(
                            color: Color(0xFFEA580C),
                            trackColor: Color(0xFFF97316),
                            waveColor: Color(0xFFFDBA74),
                            size: 64,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            state.loadingMessage.isNotEmpty
                                ? state.loadingMessage
                                : 'Memproses dengan AI...',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFEA580C).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isActive
              ? Border.all(color: const Color(0xFFEA580C), width: 1.2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isActive ? const Color(0xFFEA580C) : const Color(0xFFE4E4E7),
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEA580C),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFFEA580C) : const Color(0xFFA1A1AA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
