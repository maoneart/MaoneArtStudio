import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/editor_state.dart';
import '../models/editor_layer.dart';
import '../models/background_config.dart';
import '../models/shadow_config.dart';
import '../models/aspect_ratio_preset.dart';
import '../models/adjustment_config.dart';
import '../services/background_removal_service.dart';

class EditorNotifier extends StateNotifier<EditorState> {
  final List<EditorState> _history = [];
  final List<EditorState> _redoStack = [];
  static const int _maxHistory = 20;

  EditorNotifier()
      : super(
          EditorState(
            aspectRatio: AspectRatioPreset.presets.first, // 1:1 Default
          ),
        );

  bool get canUndo => _history.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void _recordHistory() {
    _history.add(state);
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    }
    _redoStack.clear();
  }

  /// Initialize editor with picked image
  void initializeWithImage(Uint8List imageBytes, {bool autoRemoveBg = true}) {
    final imageLayer = EditorLayer(
      id: 'layer_main_${DateTime.now().millisecondsSinceEpoch}',
      type: LayerType.image,
      imageBytes: imageBytes,
      offset: Offset.zero,
      scale: 1.0,
    );

    _history.clear();
    _redoStack.clear();

    state = EditorState(
      layers: [imageLayer],
      selectedLayerId: imageLayer.id,
      aspectRatio: AspectRatioPreset.presets.first,
      background: BackgroundConfig.studioPresets[4].config, // Soft studio white
      shadow: const ShadowConfig(type: ShadowType.floorShadow),
      originalImageBytes: imageBytes,
      hasCutoutApplied: false,
    );

    if (autoRemoveBg) {
      applyAiBackgroundRemoval();
    }
  }

  /// Trigger AI Background Removal
  Future<void> applyAiBackgroundRemoval({
    String? customApiKey,
    String? customEndpoint,
  }) async {
    final mainLayer = state.mainImageLayer;
    final bytesToProcess = state.originalImageBytes ?? mainLayer?.imageBytes;
    if (bytesToProcess == null) return;

    state = state.copyWith(
      isLoading: true,
      loadingMessage: 'AI sedang memisahkan objek & latar belakang...',
    );

    try {
      final result = await BackgroundRemovalService.removeBackground(
        inputBytes: bytesToProcess,
        customApiKey: customApiKey,
        customEndpoint: customEndpoint,
      );

      _recordHistory();

      // Update the main image layer with the cutout bytes
      final updatedLayers = state.layers.map((l) {
        if (l.id == (mainLayer?.id ?? state.selectedLayerId)) {
          return l.copyWith(imageBytes: result.resultBytes);
        }
        return l;
      }).toList();

      state = state.copyWith(
        layers: updatedLayers,
        hasCutoutApplied: true,
        isLoading: false,
        loadingMessage: '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        loadingMessage: '',
      );
    }
  }

  /// Restore original un-cut image
  void restoreOriginalImage() {
    if (state.originalImageBytes == null) return;
    _recordHistory();

    final updatedLayers = state.layers.map((l) {
      if (l.type == LayerType.image) {
        return l.copyWith(imageBytes: state.originalImageBytes);
      }
      return l;
    }).toList();

    state = state.copyWith(
      layers: updatedLayers,
      hasCutoutApplied: false,
    );
  }

  /// Select a layer
  void selectLayer(String? layerId) {
    state = state.copyWith(selectedLayerId: layerId);
  }

  /// Update layer transform (Drag offset, Scale, Rotation, Opacity)
  void updateLayerTransform(
    String layerId, {
    Offset? offset,
    double? scale,
    double? rotation,
    bool? flipX,
    bool? flipY,
    double? opacity,
  }) {
    final index = state.layers.indexWhere((l) => l.id == layerId);
    if (index == -1) return;

    final target = state.layers[index];
    final updated = target.copyWith(
      offset: offset ?? target.offset,
      scale: scale ?? target.scale,
      rotation: rotation ?? target.rotation,
      isFlippedX: flipX ?? target.isFlippedX,
      isFlippedY: flipY ?? target.isFlippedY,
      opacity: opacity ?? target.opacity,
    );

    final updatedList = List<EditorLayer>.from(state.layers);
    updatedList[index] = updated;

    state = state.copyWith(layers: updatedList);
  }

  /// Flip layer horizontally
  void toggleFlipX(String layerId) {
    _recordHistory();
    final index = state.layers.indexWhere((l) => l.id == layerId);
    if (index == -1) return;
    final target = state.layers[index];
    final updatedList = List<EditorLayer>.from(state.layers);
    updatedList[index] = target.copyWith(isFlippedX: !target.isFlippedX);
    state = state.copyWith(layers: updatedList);
  }

  /// Flip layer vertically
  void toggleFlipY(String layerId) {
    _recordHistory();
    final index = state.layers.indexWhere((l) => l.id == layerId);
    if (index == -1) return;
    final target = state.layers[index];
    final updatedList = List<EditorLayer>.from(state.layers);
    updatedList[index] = target.copyWith(isFlippedY: !target.isFlippedY);
    state = state.copyWith(layers: updatedList);
  }

  /// Reset layer scale, position and rotation to center
  void resetLayerTransform(String layerId) {
    _recordHistory();
    final index = state.layers.indexWhere((l) => l.id == layerId);
    if (index == -1) return;
    final target = state.layers[index];
    final updatedList = List<EditorLayer>.from(state.layers);
    updatedList[index] = target.copyWith(
      offset: Offset.zero,
      scale: 1.0,
      rotation: 0.0,
      isFlippedX: false,
      isFlippedY: false,
    );
    state = state.copyWith(layers: updatedList);
  }

  /// Add text layer
  void addTextLayer(
    String text, {
    Color textColor = Colors.white,
    Color backgroundColor = Colors.transparent,
    double fontSize = 28.0,
    FontWeight fontWeight = FontWeight.bold,
    String fontFamily = 'Inter',
  }) {
    _recordHistory();
    final newLayer = EditorLayer(
      id: 'layer_text_${DateTime.now().millisecondsSinceEpoch}',
      type: LayerType.text,
      text: text,
      textColor: textColor,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: fontFamily,
      offset: const Offset(0, -50),
    );

    state = state.copyWith(
      layers: [...state.layers, newLayer],
      selectedLayerId: newLayer.id,
    );
  }

  /// Add e-commerce badge layer (e.g. "50% OFF", "BEST SELLER")
  void addBadgeLayer(String text, Color bgColor, Color textColor) {
    _recordHistory();
    final newLayer = EditorLayer(
      id: 'layer_badge_${DateTime.now().millisecondsSinceEpoch}',
      type: LayerType.badge,
      text: text,
      textColor: textColor,
      backgroundColor: bgColor,
      fontSize: 16.0,
      fontWeight: FontWeight.w900,
      offset: const Offset(-80, -120),
    );

    state = state.copyWith(
      layers: [...state.layers, newLayer],
      selectedLayerId: newLayer.id,
    );
  }

  /// Delete layer
  void deleteLayer(String layerId) {
    _recordHistory();
    final updated = state.layers.where((l) => l.id != layerId).toList();
    state = state.copyWith(
      layers: updated,
      selectedLayerId: updated.isNotEmpty ? updated.last.id : null,
    );
  }

  /// Duplicate layer
  void duplicateLayer(String layerId) {
    final index = state.layers.indexWhere((l) => l.id == layerId);
    if (index == -1) return;
    _recordHistory();

    final original = state.layers[index];
    final duplicated = original.copyWith(
      id: 'layer_dup_${DateTime.now().millisecondsSinceEpoch}',
      offset: Offset(original.offset.dx + 20, original.offset.dy + 20),
    );

    state = state.copyWith(
      layers: [...state.layers, duplicated],
      selectedLayerId: duplicated.id,
    );
  }

  /// Change Background Configuration
  void setBackground(BackgroundConfig config) {
    _recordHistory();
    state = state.copyWith(background: config);
  }

  /// Change Shadow Configuration
  void setShadow(ShadowConfig config) {
    _recordHistory();
    state = state.copyWith(shadow: config);
  }

  /// Change Aspect Ratio
  void setAspectRatio(AspectRatioPreset ratio) {
    _recordHistory();
    state = state.copyWith(aspectRatio: ratio);
  }

  /// Change Image Adjustments (Brightness, Contrast, Saturation, Warmth)
  void setAdjustments(AdjustmentConfig adjustments) {
    state = state.copyWith(adjustments: adjustments);
  }

  /// Reset Adjustments
  void resetAdjustments() {
    _recordHistory();
    state = state.copyWith(adjustments: const AdjustmentConfig());
  }

  /// Undo
  void undo() {
    if (_history.isEmpty) return;
    _redoStack.add(state);
    state = _history.removeLast();
  }

  /// Redo
  void redo() {
    if (_redoStack.isEmpty) return;
    _history.add(state);
    state = _redoStack.removeLast();
  }
}

final editorProvider = StateNotifierProvider<EditorNotifier, EditorState>((ref) {
  return EditorNotifier();
});
