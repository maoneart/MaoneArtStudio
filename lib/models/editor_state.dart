import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'editor_layer.dart';
import 'background_config.dart';
import 'shadow_config.dart';
import 'aspect_ratio_preset.dart';
import 'adjustment_config.dart';

class EditorState {
  final List<EditorLayer> layers;
  final String? selectedLayerId;
  final BackgroundConfig background;
  final ShadowConfig shadow;
  final AspectRatioPreset aspectRatio;
  final AdjustmentConfig adjustments;
  final bool isLoading;
  final String loadingMessage;
  final Uint8List? originalImageBytes;
  final bool hasCutoutApplied;

  const EditorState({
    this.layers = const [],
    this.selectedLayerId,
    this.background = const BackgroundConfig(),
    this.shadow = const ShadowConfig(),
    required this.aspectRatio,
    this.adjustments = const AdjustmentConfig(),
    this.isLoading = false,
    this.loadingMessage = '',
    this.originalImageBytes,
    this.hasCutoutApplied = false,
  });

  EditorLayer? get selectedLayer {
    if (selectedLayerId == null) return null;
    try {
      return layers.firstWhere((l) => l.id == selectedLayerId);
    } catch (_) {
      return layers.isNotEmpty ? layers.last : null;
    }
  }

  EditorLayer? get mainImageLayer {
    try {
      return layers.firstWhere((l) => l.type == LayerType.image);
    } catch (_) {
      return null;
    }
  }

  EditorState copyWith({
    List<EditorLayer>? layers,
    String? selectedLayerId,
    BackgroundConfig? background,
    ShadowConfig? shadow,
    AspectRatioPreset? aspectRatio,
    AdjustmentConfig? adjustments,
    bool? isLoading,
    String? loadingMessage,
    Uint8List? originalImageBytes,
    bool? hasCutoutApplied,
  }) {
    return EditorState(
      layers: layers ?? this.layers,
      selectedLayerId: selectedLayerId ?? this.selectedLayerId,
      background: background ?? this.background,
      shadow: shadow ?? this.shadow,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      adjustments: adjustments ?? this.adjustments,
      isLoading: isLoading ?? this.isLoading,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      originalImageBytes: originalImageBytes ?? this.originalImageBytes,
      hasCutoutApplied: hasCutoutApplied ?? this.hasCutoutApplied,
    );
  }
}
