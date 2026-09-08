import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/aspect_ratio_preset.dart';
import '../models/background_config.dart';
import '../models/shadow_config.dart';
import '../providers/editor_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/maone_modal.dart';
import 'editor_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _pickImage(BuildContext context, WidgetRef ref, ImageSource source, {String mode = 'default'}) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 95,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();

        // Configure initial preset depending on chosen mode
        ref.read(editorProvider.notifier).initializeWithImage(bytes, autoRemoveBg: true);

        if (mode == 'pas_foto') {
          ref.read(editorProvider.notifier).setAspectRatio(
                AspectRatioPreset.presets.firstWhere((r) => r.id == 'ratio_3_4'),
              );
          ref.read(editorProvider.notifier).setBackground(
                BackgroundConfig.studioPresets.firstWhere((p) => p.id == 'pas_red').config,
              );
          ref.read(editorProvider.notifier).setShadow(
                const ShadowConfig(type: ShadowType.none),
              );
        } else if (mode == 'ecommerce') {
          ref.read(editorProvider.notifier).setAspectRatio(
                AspectRatioPreset.presets.firstWhere((r) => r.id == 'ratio_1_1'),
              );
          ref.read(editorProvider.notifier).setBackground(
                BackgroundConfig.studioPresets.firstWhere((p) => p.id == 'ecom_pure_white').config,
              );
          ref.read(editorProvider.notifier).setShadow(
                const ShadowConfig(type: ShadowType.floorShadow),
              );
        }

        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EditorScreen()),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        MaoneModal.showAlertModal(
          context: context,
          title: 'Gagal Membuka Gambar',
          message: 'Terjadi kesalahan saat memuat gambar: $e',
          icon: Icons.error_outline_rounded,
          iconColor: const Color(0xFFEF4444),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final confirm = await MaoneModal.showConfirmModal(
          context: context,
          title: 'Keluar Aplikasi?',
          message: 'Apakah Anda yakin ingin keluar dari MaoneArt Studio?',
          confirmText: 'Keluar',
          cancelText: 'Batal',
          icon: Icons.exit_to_app_rounded,
        );
        if (confirm) {
          exit(0);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C0A09),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEA580C), Color(0xFFC2410C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEA580C).withOpacity(0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.auto_fix_high_rounded, color: Colors.white, size: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MaoneArt Studio',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              'AI Photo & Product Studio',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: const Color(0xFFA1A1AA),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF047857).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF059669).withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          Text(
                            'PRO AI',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Hero Banner
                GlassContainer(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA580C).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFEA580C).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          '⚡ 1-Tap AI Magic Cutout',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF97316),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Hapus Latar Belakang &\nBuat Foto Produk Menjual',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Otomatisasi cutout presisi tinggi, bayangan 3D realistis, dan preset studio katalog e-commerce.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: const Color(0xFFA1A1AA),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Symmetrical Action Buttons: Galeri & Kamera
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(context, ref, ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_rounded, size: 18, color: Colors.white),
                              label: Text(
                                'Pilih Galeri',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEA580C),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(context, ref, ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_rounded, size: 18, color: Color(0xFFE4E4E7)),
                              label: Text(
                                'Buka Kamera',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFE4E4E7),
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF27272A),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(color: Colors.white.withOpacity(0.15)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Mode Studio Cepat
                Text(
                  'Mode Studio Cepat',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),

                // 3 Quick Mode Cards
                _buildQuickCard(
                  context: context,
                  title: '🛍️ Foto Produk E-Commerce',
                  subtitle: 'Rasio 1:1 Shopee/Tokopedia dengan bayangan lantai 3D & background putih studio bersih.',
                  accentColor: const Color(0xFFEA580C),
                  onTap: () => _pickImage(context, ref, ImageSource.gallery, mode: 'ecommerce'),
                ),
                const SizedBox(height: 12),

                _buildQuickCard(
                  context: context,
                  title: '🪪 Pas Foto Formal 3x4 / 4x6',
                  subtitle: 'Ganti latar merah, biru, atau putih instan untuk E-KTP, Ijazah, CV, dan Dokumen Resmi.',
                  accentColor: const Color(0xFF0284C7),
                  onTap: () => _pickImage(context, ref, ImageSource.gallery, mode: 'pas_foto'),
                ),
                const SizedBox(height: 12),

                _buildQuickCard(
                  context: context,
                  title: '✨ Magic Cutout Transparan',
                  subtitle: 'Ekstrak objek bersih format PNG transparan berkualitas tinggi untuk desain bebas.',
                  accentColor: const Color(0xFF059669),
                  onTap: () => _pickImage(context, ref, ImageSource.gallery, mode: 'default'),
                ),
                const SizedBox(height: 28),

                // Footer Info
                Center(
                  child: Text(
                    'MaoneArt Studio v1.0.0 • Dibuat untuk Kreator & Seller',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF71717A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFFA1A1AA),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: accentColor.withOpacity(0.8),
          ),
        ],
      ),
    );
  }
}
