import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class BackgroundRemovalResult {
  final Uint8List resultBytes;
  final bool isAiProcessed;
  final String? message;

  const BackgroundRemovalResult({
    required this.resultBytes,
    this.isAiProcessed = true,
    this.message,
  });
}

class BackgroundRemovalService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  /// Primary AI Cutout method with automatic fallback
  static Future<BackgroundRemovalResult> removeBackground({
    required Uint8List inputBytes,
    String? customApiKey,
    String? customEndpoint,
  }) async {
    try {
      // 1. If custom API endpoint is provided
      if (customEndpoint != null && customEndpoint.isNotEmpty) {
        final result = await _callCustomApi(
          inputBytes: inputBytes,
          endpoint: customEndpoint,
          apiKey: customApiKey,
        );
        if (result != null) {
          return BackgroundRemovalResult(
            resultBytes: result,
            isAiProcessed: true,
            message: 'Berhasil diproses dengan Custom AI API',
          );
        }
      }

      // 2. Try Free HuggingFace RMBG-1.4 / BiRefNet Inference
      final aiResult = await _callHuggingFaceRmbg(inputBytes);
      if (aiResult != null) {
        return BackgroundRemovalResult(
          resultBytes: aiResult,
          isAiProcessed: true,
          message: 'Berhasil diproses dengan AI Studio RMBG-1.4',
        );
      }
    } catch (e) {
      debugPrint('AI Background removal API failed: $e. Falling back to local engine.');
    }

    // 3. Fallback: Local Smart Dart Image Processor
    final localProcessed = await compute(_processLocalSmartCutout, inputBytes);
    return BackgroundRemovalResult(
      resultBytes: localProcessed,
      isAiProcessed: false,
      message: 'Diproses dengan Offline Smart Cutout Engine',
    );
  }

  /// Call Free RMBG-1.4 model on HuggingFace Inference API
  static Future<Uint8List?> _callHuggingFaceRmbg(Uint8List inputBytes) async {
    const endpoints = [
      'https://api-inference.huggingface.co/models/briaai/RMBG-1.4',
      'https://api-inference.huggingface.co/models/ZhengPeng7/BiRefNet',
    ];

    for (final url in endpoints) {
      try {
        final response = await _dio.post<List<int>>(
          url,
          data: inputBytes,
          options: Options(
            headers: {
              'Content-Type': 'application/octet-stream',
            },
            responseType: ResponseType.bytes,
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          return Uint8List.fromList(response.data!);
        }
      } catch (e) {
        debugPrint('Endpoint $url failed: $e');
      }
    }
    return null;
  }

  /// Call Custom API (Remove.bg or Clipdrop style)
  static Future<Uint8List?> _callCustomApi({
    required Uint8List inputBytes,
    required String endpoint,
    String? apiKey,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image_file': MultipartFile.fromBytes(
          inputBytes,
          filename: 'input.png',
        ),
        'size': 'auto',
      });

      final response = await _dio.post<List<int>>(
        endpoint,
        data: formData,
        options: Options(
          headers: {
            if (apiKey != null) 'X-API-Key': apiKey,
          },
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Uint8List.fromList(response.data!);
      }
    } catch (e) {
      debugPrint('Custom API failed: $e');
    }
    return null;
  }

  /// Local offline smart background removal using Dart image processing
  /// Analyzes corner pixels to detect solid background color and removes it with smooth alpha feathering
  static Uint8List _processLocalSmartCutout(Uint8List bytes) {
    final original = img.decodeImage(bytes);
    if (original == null) return bytes;

    final width = original.width;
    final height = original.height;

    // Convert to RGBA
    final output = img.Image(
      width: width,
      height: height,
      numChannels: 4,
    );

    // Sample background color from 4 corners
    final c1 = original.getPixel(0, 0);
    final c2 = original.getPixel(width - 1, 0);
    final c3 = original.getPixel(0, height - 1);
    final c4 = original.getPixel(width - 1, height - 1);

    final bgR = (c1.r + c2.r + c3.r + c4.r) / 4.0;
    final bgG = (c1.g + c2.g + c3.g + c4.g) / 4.0;
    final bgB = (c1.b + c2.b + c3.b + c4.b) / 4.0;

    const threshold = 35.0;
    const feather = 20.0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = original.getPixel(x, y);
        final pr = pixel.r;
        final pg = pixel.g;
        final pb = pixel.b;

        // Euclidean color distance from estimated background
        final dist = (pr - bgR).abs() * 0.3 +
            (pg - bgG).abs() * 0.59 +
            (pb - bgB).abs() * 0.11;

        int alpha = 255;
        if (dist < threshold) {
          alpha = 0;
        } else if (dist < threshold + feather) {
          alpha = (((dist - threshold) / feather) * 255).round().clamp(0, 255);
        }

        output.setPixelRgba(x, y, pr.toInt(), pg.toInt(), pb.toInt(), alpha);
      }
    }

    return Uint8List.fromList(img.encodePng(output));
  }
}
