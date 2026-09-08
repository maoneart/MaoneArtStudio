import 'dart:typed_data';
import 'package:flutter/material.dart';

enum LayerType {
  image,
  text,
  badge,
}

class EditorLayer {
  final String id;
  final LayerType type;
  final Uint8List? imageBytes;
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final double fontSize;
  final FontWeight fontWeight;
  final String fontFamily;
  
  // Transform properties
  final Offset offset;
  final double scale;
  final double rotation; // In radians
  final bool isFlippedX;
  final bool isFlippedY;
  final double opacity;
  final bool isLocked;
  final bool isVisible;

  const EditorLayer({
    required this.id,
    required this.type,
    this.imageBytes,
    this.text = '',
    this.textColor = Colors.white,
    this.backgroundColor = Colors.transparent,
    this.fontSize = 24.0,
    this.fontWeight = FontWeight.bold,
    this.fontFamily = 'Inter',
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.isFlippedX = false,
    this.isFlippedY = false,
    this.opacity = 1.0,
    this.isLocked = false,
    this.isVisible = true,
  });

  EditorLayer copyWith({
    String? id,
    LayerType? type,
    Uint8List? imageBytes,
    String? text,
    Color? textColor,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    String? fontFamily,
    Offset? offset,
    double? scale,
    double? rotation,
    bool? isFlippedX,
    bool? isFlippedY,
    double? opacity,
    bool? isLocked,
    bool? isVisible,
  }) {
    return EditorLayer(
      id: id ?? this.id,
      type: type ?? this.type,
      imageBytes: imageBytes ?? this.imageBytes,
      text: text ?? this.text,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontFamily: fontFamily ?? this.fontFamily,
      offset: offset ?? this.offset,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      isFlippedX: isFlippedX ?? this.isFlippedX,
      isFlippedY: isFlippedY ?? this.isFlippedY,
      opacity: opacity ?? this.opacity,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}
