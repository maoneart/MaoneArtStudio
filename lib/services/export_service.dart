import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ExportFormat {
  png,
  jpeg,
}

enum ExportResolution {
  standard(1.0, '1x Standar'),
  highDef(2.0, '2x HD'),
  ultraHd(3.5, '4x Ultra HD');

  final double pixelRatio;
  final String label;
  const ExportResolution(this.pixelRatio, this.label);
}

class ExportResult {
  final bool success;
  final String? filePath;
  final Uint8List? imageBytes;
  final String message;

  const ExportResult({
    required this.success,
    this.filePath,
    this.imageBytes,
    required this.message,
  });
}

class ExportService {
  /// Renders a RepaintBoundary widget into raw bytes
  static Future<Uint8List?> captureBoundary({
    required GlobalKey boundaryKey,
    double pixelRatio = 2.0,
    ExportFormat format = ExportFormat.png,
  }) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(
        format: format == ExportFormat.png ? ui.ImageByteFormat.png : ui.ImageByteFormat.rawRgba,
      );

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing canvas boundary: $e');
      return null;
    }
  }

  /// Saves rendered image to device storage (/sdcard/Download/MaoneArtStudio)
  static Future<ExportResult> saveToDevice({
    required Uint8List bytes,
    required ExportFormat format,
    String? filenamePrefix,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = format == ExportFormat.png ? 'png' : 'jpg';
      final fileName = '${filenamePrefix ?? 'MaoneArt_Studio'}_$timestamp.$extension';

      // 1. Try public Download folder on Android (/sdcard/Download/MaoneArtStudio)
      Directory? targetDir;
      final downloadPath = Directory('/sdcard/Download/MaoneArtStudio');
      
      try {
        if (await downloadPath.exists() || await downloadPath.create(recursive: true).then((_) => true).catchError((_) => false)) {
          targetDir = downloadPath;
        }
      } catch (_) {}

      // 2. Fallback to App Documents Directory
      if (targetDir == null) {
        targetDir = await getApplicationDocumentsDirectory();
      }

      final file = File('${targetDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      return ExportResult(
        success: true,
        filePath: file.path,
        imageBytes: bytes,
        message: 'Foto berhasil disimpan di ${file.path}',
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Gagal menyimpan foto: $e',
      );
    }
  }

  /// Shares image to other apps (WhatsApp, Instagram, Telegram, Drive)
  static Future<void> shareImage({
    required Uint8List bytes,
    required ExportFormat format,
    String? caption,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final extension = format == ExportFormat.png ? 'png' : 'jpg';
      final file = File('${tempDir.path}/shared_maoneart_${DateTime.now().millisecondsSinceEpoch}.$extension');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: format == ExportFormat.png ? 'image/png' : 'image/jpeg')],
        text: caption ?? 'Dibuat dengan MaoneArt Studio (AI Product Studio)',
      );
    } catch (e) {
      debugPrint('Share failed: $e');
    }
  }
}
