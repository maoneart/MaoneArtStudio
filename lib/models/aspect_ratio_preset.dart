import 'package:flutter/material.dart';

class AspectRatioPreset {
  final String id;
  final String label;
  final String subtitle;
  final double? ratio; // null means auto / original
  final IconData icon;

  const AspectRatioPreset({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.ratio,
    required this.icon,
  });

  static List<AspectRatioPreset> get presets => [
    const AspectRatioPreset(
      id: 'ratio_1_1',
      label: '1:1 Persegi',
      subtitle: 'Shopee, Toko, IG Post',
      ratio: 1.0,
      icon: Icons.crop_square_rounded,
    ),
    const AspectRatioPreset(
      id: 'ratio_4_5',
      label: '4:5 Potret',
      subtitle: 'Instagram Feed Portrait',
      ratio: 4.0 / 5.0,
      icon: Icons.crop_portrait_rounded,
    ),
    const AspectRatioPreset(
      id: 'ratio_9_16',
      label: '9:16 Vertikal',
      subtitle: 'Story, Reels, TikTok, WA',
      ratio: 9.0 / 16.0,
      icon: Icons.smartphone_rounded,
    ),
    const AspectRatioPreset(
      id: 'ratio_3_4',
      label: '3:4 Pas Foto',
      subtitle: 'E-KTP, Ijazah, CV, Visa',
      ratio: 3.0 / 4.0,
      icon: Icons.badge_outlined,
    ),
    const AspectRatioPreset(
      id: 'ratio_16_9',
      label: '16:9 Lanskap',
      subtitle: 'YouTube, Web Banner',
      ratio: 16.0 / 9.0,
      icon: Icons.crop_16_9_rounded,
    ),
    const AspectRatioPreset(
      id: 'ratio_free',
      label: 'Bebas / Asli',
      subtitle: 'Sesuai Ukuran Gambar',
      ratio: null,
      icon: Icons.crop_free_rounded,
    ),
  ];
}
