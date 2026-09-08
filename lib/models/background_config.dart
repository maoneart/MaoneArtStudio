import 'dart:typed_data';
import 'package:flutter/material.dart';

enum BackgroundType {
  transparent,
  solid,
  gradient,
  studioTexture,
  customImage,
}

enum StudioGradientType {
  linear,
  radial,
  sweep,
}

class StudioPreset {
  final String id;
  final String name;
  final String category; // 'Solid', 'Studio Light', 'E-Commerce', 'Pas Foto', 'Texture'
  final BackgroundConfig config;
  final String? previewAsset;

  const StudioPreset({
    required this.id,
    required this.name,
    required this.category,
    required this.config,
    this.previewAsset,
  });
}

class BackgroundConfig {
  final BackgroundType type;
  final Color solidColor;
  final List<Color> gradientColors;
  final List<double>? gradientStops;
  final Alignment gradientBegin;
  final Alignment gradientEnd;
  final StudioGradientType gradientType;
  final String? textureAssetOrUrl;
  final Uint8List? customImageBytes;
  final double blurRadius;

  const BackgroundConfig({
    this.type = BackgroundType.transparent,
    this.solidColor = Colors.white,
    this.gradientColors = const [Color(0xFF2C3E50), Color(0xFF000000)],
    this.gradientStops,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.gradientType = StudioGradientType.linear,
    this.textureAssetOrUrl,
    this.customImageBytes,
    this.blurRadius = 0.0,
  });

  BackgroundConfig copyWith({
    BackgroundType? type,
    Color? solidColor,
    List<Color>? gradientColors,
    List<double>? gradientStops,
    Alignment? gradientBegin,
    Alignment? gradientEnd,
    StudioGradientType? gradientType,
    String? textureAssetOrUrl,
    Uint8List? customImageBytes,
    double? blurRadius,
  }) {
    return BackgroundConfig(
      type: type ?? this.type,
      solidColor: solidColor ?? this.solidColor,
      gradientColors: gradientColors ?? this.gradientColors,
      gradientStops: gradientStops ?? this.gradientStops,
      gradientBegin: gradientBegin ?? this.gradientBegin,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      gradientType: gradientType ?? this.gradientType,
      textureAssetOrUrl: textureAssetOrUrl ?? this.textureAssetOrUrl,
      customImageBytes: customImageBytes ?? this.customImageBytes,
      blurRadius: blurRadius ?? this.blurRadius,
    );
  }

  // Predefined Studio Presets
  static List<StudioPreset> get studioPresets => [
    // 1. Transparent
    const StudioPreset(
      id: 'trans_1',
      name: 'Transparan',
      category: 'Dasar',
      config: BackgroundConfig(type: BackgroundType.transparent),
    ),
    
    // 2. Pas Foto / Formal Colors
    const StudioPreset(
      id: 'pas_red',
      name: 'Merah Pas Foto (Ganjil)',
      category: 'Pas Foto',
      config: BackgroundConfig(
        type: BackgroundType.solid,
        solidColor: Color(0xFFD32F2F),
      ),
    ),
    const StudioPreset(
      id: 'pas_blue',
      name: 'Biru Pas Foto (Genap)',
      category: 'Pas Foto',
      config: BackgroundConfig(
        type: BackgroundType.solid,
        solidColor: Color(0xFF1976D2),
      ),
    ),
    const StudioPreset(
      id: 'pas_white',
      name: 'Putih Bersih (E-KTP/Visa)',
      category: 'Pas Foto',
      config: BackgroundConfig(
        type: BackgroundType.solid,
        solidColor: Color(0xFFFFFFFF),
      ),
    ),

    // 3. E-Commerce Solid
    const StudioPreset(
      id: 'ecom_pure_white',
      name: 'Pure White (Shopee/Tokopedia)',
      category: 'E-Commerce',
      config: BackgroundConfig(
        type: BackgroundType.solid,
        solidColor: Color(0xFFFAFAFA),
      ),
    ),
    const StudioPreset(
      id: 'ecom_soft_gray',
      name: 'Soft Studio Gray',
      category: 'E-Commerce',
      config: BackgroundConfig(
        type: BackgroundType.solid,
        solidColor: Color(0xFFE5E7EB),
      ),
    ),
    const StudioPreset(
      id: 'ecom_warm_cream',
      name: 'Warm Cream Silk',
      category: 'E-Commerce',
      config: BackgroundConfig(
        type: BackgroundType.solid,
        solidColor: Color(0xFFFDFBF7),
      ),
    ),
    const StudioPreset(
      id: 'ecom_luxury_black',
      name: 'Luxury Velvet Dark',
      category: 'E-Commerce',
      config: BackgroundConfig(
        type: BackgroundType.solid,
        solidColor: Color(0xFF0F172A),
      ),
    ),

    // 4. Studio Lighting & Gradients
    const StudioPreset(
      id: 'studio_spotlight',
      name: 'Studio Spotlight Glow',
      category: 'Studio Lighting',
      config: BackgroundConfig(
        type: BackgroundType.gradient,
        gradientType: StudioGradientType.radial,
        gradientColors: [Color(0xFFE2E8F0), Color(0xFF64748B)],
      ),
    ),
    const StudioPreset(
      id: 'studio_dark_podium',
      name: 'Cyber Dark Glow',
      category: 'Studio Lighting',
      config: BackgroundConfig(
        type: BackgroundType.gradient,
        gradientType: StudioGradientType.radial,
        gradientColors: [Color(0xFF1E293B), Color(0xFF090D16)],
      ),
    ),
    const StudioPreset(
      id: 'studio_orange_ember',
      name: 'MaoneArt Amber Studio',
      category: 'Studio Lighting',
      config: BackgroundConfig(
        type: BackgroundType.gradient,
        gradientType: StudioGradientType.linear,
        gradientBegin: Alignment.topLeft,
        gradientEnd: Alignment.bottomRight,
        gradientColors: [Color(0xFFEA580C), Color(0xFF7C2D12), Color(0xFF18181B)],
      ),
    ),
    const StudioPreset(
      id: 'studio_emerald_luxury',
      name: 'Emerald Botanic Studio',
      category: 'Studio Lighting',
      config: BackgroundConfig(
        type: BackgroundType.gradient,
        gradientType: StudioGradientType.linear,
        gradientBegin: Alignment.topCenter,
        gradientEnd: Alignment.bottomCenter,
        gradientColors: [Color(0xFF065F46), Color(0xFF022C22), Color(0xFF0B0F17)],
      ),
    ),
    const StudioPreset(
      id: 'studio_pastel_dream',
      name: 'Pastel Blush Aesthetic',
      category: 'Studio Lighting',
      config: BackgroundConfig(
        type: BackgroundType.gradient,
        gradientType: StudioGradientType.linear,
        gradientColors: [Color(0xFFFFE4E6), Color(0xFFCCFBF1)],
      ),
    ),
    const StudioPreset(
      id: 'studio_neon_cyber',
      name: 'Neon Cyberpunk Duotone',
      category: 'Studio Lighting',
      config: BackgroundConfig(
        type: BackgroundType.gradient,
        gradientType: StudioGradientType.linear,
        gradientBegin: Alignment.topLeft,
        gradientEnd: Alignment.bottomRight,
        gradientColors: [Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFF3B82F6)],
      ),
    ),
  ];
}
