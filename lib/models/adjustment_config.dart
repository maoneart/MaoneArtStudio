class AdjustmentConfig {
  final double brightness; // -1.0 to 1.0 (default 0.0)
  final double contrast;   // 0.0 to 2.0 (default 1.0)
  final double saturation; // 0.0 to 2.0 (default 1.0)
  final double warmth;     // -1.0 to 1.0 (default 0.0)

  const AdjustmentConfig({
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.warmth = 0.0,
  });

  AdjustmentConfig copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
    double? warmth,
  }) {
    return AdjustmentConfig(
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      warmth: warmth ?? this.warmth,
    );
  }

  bool get isDefault =>
      brightness == 0.0 &&
      contrast == 1.0 &&
      saturation == 1.0 &&
      warmth == 0.0;
}
