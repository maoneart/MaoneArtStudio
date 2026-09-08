import 'package:flutter/material.dart';

enum ShadowType {
  none,
  dropShadow,    // Cast shadow at an angle
  floorShadow,   // 3D Isometric floor shadow for e-commerce products
  ambientShadow, // Soft ambient contact shadow
  glowOutline,   // Sticker outline / neon glow
}

class ShadowConfig {
  final ShadowType type;
  final Color color;
  final double opacity;      // 0.0 - 1.0
  final double blurRadius;    // 0.0 - 50.0
  final double distance;      // 0.0 - 100.0 (offset distance)
  final double angle;         // 0.0 - 360.0 (degrees)
  final double floorScaleX;   // 0.5 - 2.0 (width of floor shadow)
  final double floorScaleY;   // 0.1 - 0.6 (flat perspective compression)
  final double floorOffset;   // Vertical positioning below product
  final double outlineWidth;  // 1.0 - 20.0 for glow/sticker outline

  const ShadowConfig({
    this.type = ShadowType.floorShadow,
    this.color = Colors.black,
    this.opacity = 0.5,
    this.blurRadius = 18.0,
    this.distance = 25.0,
    this.angle = 90.0,
    this.floorScaleX = 1.1,
    this.floorScaleY = 0.25,
    this.floorOffset = 15.0,
    this.outlineWidth = 4.0,
  });

  ShadowConfig copyWith({
    ShadowType? type,
    Color? color,
    double? opacity,
    double? blurRadius,
    double? distance,
    double? angle,
    double? floorScaleX,
    double? floorScaleY,
    double? floorOffset,
    double? outlineWidth,
  }) {
    return ShadowConfig(
      type: type ?? this.type,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      blurRadius: blurRadius ?? this.blurRadius,
      distance: distance ?? this.distance,
      angle: angle ?? this.angle,
      floorScaleX: floorScaleX ?? this.floorScaleX,
      floorScaleY: floorScaleY ?? this.floorScaleY,
      floorOffset: floorOffset ?? this.floorOffset,
      outlineWidth: outlineWidth ?? this.outlineWidth,
    );
  }
}
