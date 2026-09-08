import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/export_service.dart';
import '../widgets/glass_container.dart';
import '../widgets/maone_modal.dart';

class ExportScreen extends StatefulWidget {
  final Uint8List previewBytes;
  final GlobalKey repaintBoundaryKey;

  const ExportScreen({
    super.key,
    required this.previewBytes,
    required this.repaintBoundaryKey,
  });

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  ExportFormat _selectedFormat = ExportFormat.png;
  ExportResolution _selectedResolution = ExportResolution.highDef;
  bool _isSaving = false;

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      // High-res re-render if higher resolution is selected
      Uint8List bytesToSave = widget.previewBytes;
      if (_selectedResolution != ExportResolution.standard) {
        final highResBytes = await ExportService.captureBoundary(
          boundaryKey: widget.repaintBoundaryKey,
          pixelRatio: _selectedResolution.pixelRatio,
          format: _selectedFormat,
        );
        if (highResBytes != null) {
          bytesToSave = highResBytes;
        }
      }

      final result = await ExportService.saveToDevice(
        bytes: bytesToSave,
        format: _selectedFormat,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        if (result.success) {
          MaoneModal.showAlertModal(
            context: context,
            title: 'Berhasil Disimpan!',
            message: 'Foto karya Anda telah disimpan ke folder Download:\n\n${result.filePath}',
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF10B981),
          );
        } else {
          MaoneModal.showAlertModal(
            context: context,
            title: 'Gagal Menyimpan',
            message: result.message,
            icon: Icons.error_outline_rounded,
            iconColor: const Color(0xFFEF4444),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        MaoneModal.showAlertModal(
          context: context,
          title: 'Error Ekspor',
          message: 'Terjadi masalah: $e',
          icon: Icons.error_outline_rounded,
          iconColor: const Color(0xFFEF4444),
        );
      }
    }
  }

  Future<void> _handleShare() async {
    setState(() => _isSaving = true);
    try {
      final highResBytes = await ExportService.captureBoundary(
        boundaryKey: widget.repaintBoundaryKey,
        pixelRatio: _selectedResolution.pixelRatio,
        format: _selectedFormat,
      );

      final bytesToShare = highResBytes ?? widget.previewBytes;

      await ExportService.shareImage(
        bytes: bytesToShare,
        format: _selectedFormat,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0A09),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Simpan & Bagikan',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Box
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 340),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      widget.previewBytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Format Selector
              Text(
                'Format Gambar',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildOptionChip(
                      label: 'PNG (Transparan/HQ)',
                      isSelected: _selectedFormat == ExportFormat.png,
                      onTap: () => setState(() => _selectedFormat = ExportFormat.png),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildOptionChip(
                      label: 'JPG (Standar Web)',
                      isSelected: _selectedFormat == ExportFormat.jpeg,
                      onTap: () => setState(() => _selectedFormat = ExportFormat.jpeg),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Resolution Selector
              Text(
                'Resolusi & Kualitas Ekspor',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: ExportResolution.values.map((res) {
                  final isSelected = _selectedResolution == res;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildOptionChip(
                        label: res.label,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedResolution = res),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Symmetrical 2-Column Action Buttons: Simpan & Bagikan
              if (_isSaving)
                const Center(
                  child: SpinKitThreeBounce(
                    color: Color(0xFFEA580C),
                    size: 28,
                  ),
                )
              else
                Row(
                  children: [
                    // Bagikan Button
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF27272A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _handleShare,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.share_rounded, size: 18, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Bagikan',
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
                    ),
                    const SizedBox(width: 12),

                    // Simpan ke Galeri / Download Button
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEA580C), Color(0xFFF97316)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEA580C).withOpacity(0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _handleSave,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.download_rounded, size: 18, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Simpan Galeri',
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
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEA580C).withOpacity(0.2)
              : const Color(0xFF27272A).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFEA580C)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFFA1A1AA),
            ),
          ),
        ),
      ),
    );
  }
}
