import 'dart:math';
import 'package:flutter/material.dart';
import '../models/adjustment_config.dart';

class ImageFilterService {
  /// Generates a combined 4x5 ColorFilter matrix from AdjustmentConfig
  static ColorFilter getColorFilter(AdjustmentConfig config) {
    if (config.isDefault) {
      return const ColorFilter.mode(Colors.transparent, BlendMode.dst);
    }

    final matrix = _calculateColorMatrix(
      brightness: config.brightness,
      contrast: config.contrast,
      saturation: config.saturation,
      warmth: config.warmth,
    );

    return ColorFilter.matrix(matrix);
  }

  static List<double> _calculateColorMatrix({
    required double brightness,
    required double contrast,
    required double saturation,
    required double warmth,
  }) {
    // 1. Brightness offset (-255 to 255)
    final b = brightness * 255;

    // 2. Contrast scale
    final c = contrast;
    final cOffset = 128 * (1 - c);

    // 3. Saturation factors (standard luminance weights)
    final lumR = 0.3086;
    final lumG = 0.6094;
    final lumB = 0.0820;
    final s = saturation;
    final sr = (1 - s) * lumR;
    final sg = (1 - s) * lumG;
    final sb = (1 - s) * lumB;

    // 4. Warmth (adjusts Red up and Blue down)
    final wR = 1.0 + (warmth * 0.2);
    final wB = 1.0 - (warmth * 0.2);

    // Combine into standard 5x4 RGBA color matrix
    return [
      (sr + s) * c * wR, sg * c,           sb * c,           0, b + cOffset,
      sr * c,           (sg + s) * c,      sb * c,           0, b + cOffset,
      sr * c,           sg * c,           (sb + s) * c * wB, 0, b + cOffset,
      0,                0,                0,                1, 0,
    ];
  }
}
