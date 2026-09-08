import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/editor_state.dart';
import '../models/editor_layer.dart';
import '../models/background_config.dart';
import '../models/shadow_config.dart';
import '../providers/editor_provider.dart';
import '../services/image_filter_service.dart';

class CanvasWorkspace extends ConsumerWidget {
  final GlobalKey repaintBoundaryKey;

  const CanvasWorkspace({
    super.key,
    required this.repaintBoundaryKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final ratio = state.aspectRatio.ratio;

    return Center(
      child: AspectRatio(
        aspectRatio: ratio ?? 1.0,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: RepaintBoundary(
              key: repaintBoundaryKey,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Background Layer (Checkerboard, Solid, Gradient, or Image)
                  _buildBackground(state.background),

                  // 2. Interactive Layers with Shadows
                  ...state.layers.map((layer) {
                    final isSelected = layer.id == state.selectedLayerId;
                    return _buildLayerItem(context, ref, state, layer, isSelected);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(BackgroundConfig bg) {
    switch (bg.type) {
      case BackgroundType.transparent:
        return const CustomPaint(
          painter: CheckerboardPainter(),
          size: Size.infinite,
        );

      case BackgroundType.solid:
        return Container(color: bg.solidColor);

      case BackgroundType.gradient:
        if (bg.gradientType == StudioGradientType.radial) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.85,
                colors: bg.gradientColors,
                stops: bg.gradientStops,
              ),
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: bg.gradientBegin,
                end: bg.gradientEnd,
                colors: bg.gradientColors,
                stops: bg.gradientStops,
              ),
            ),
          );
        }

      case BackgroundType.studioTexture:
      case BackgroundType.customImage:
        if (bg.customImageBytes != null) {
          return Image.memory(
            bg.customImageBytes!,
            fit: BoxFit.cover,
          );
        }
        return Container(color: Colors.white);
    }
  }

  Widget _buildLayerItem(
    BuildContext context,
    WidgetRef ref,
    EditorState state,
    EditorLayer layer,
    bool isSelected,
  ) {
    if (!layer.isVisible) return const SizedBox.shrink();

    // Shadow calculation for image layer
    Widget renderedContent;

    if (layer.type == LayerType.image && layer.imageBytes != null) {
      final colorFilter = ImageFilterService.getColorFilter(state.adjustments);

      Widget imageWidget = ColorFiltered(
        colorFilter: colorFilter,
        child: Image.memory(
          layer.imageBytes!,
          fit: BoxFit.contain,
        ),
      );

      // Apply Shadow if enabled
      renderedContent = Stack(
        alignment: Alignment.center,
        children: [
          // Render Shadow beneath the cutout object
          if (state.shadow.type != ShadowType.none)
            _buildShadowEffect(state.shadow, layer),

          // Main Image
          imageWidget,
        ],
      );
    } else if (layer.type == LayerType.badge) {
      renderedContent = Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: layer.backgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          layer.text,
          style: TextStyle(
            color: layer.textColor,
            fontSize: layer.fontSize,
            fontWeight: layer.fontWeight,
            letterSpacing: 1.2,
          ),
        ),
      );
    } else {
      // Regular Text Layer
      renderedContent = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: layer.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          layer.text,
          style: TextStyle(
            color: layer.textColor,
            fontSize: layer.fontSize,
            fontWeight: layer.fontWeight,
            shadows: const [
              Shadow(
                color: Colors.black45,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      );
    }

    // Apply Flip transforms
    if (layer.isFlippedX || layer.isFlippedY) {
      renderedContent = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(layer.isFlippedX ? -1.0 : 1.0, layer.isFlippedY ? -1.0 : 1.0),
        child: renderedContent,
      );
    }

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              ref.read(editorProvider.notifier).selectLayer(layer.id);
            },
            onScaleUpdate: (details) {
              if (layer.isLocked) return;

              ref.read(editorProvider.notifier).selectLayer(layer.id);

              final newOffset = layer.offset + details.focalPointDelta;
              final newScale = (layer.scale * details.scale).clamp(0.2, 5.0);
              final newRotation = layer.rotation + details.rotation;

              ref.read(editorProvider.notifier).updateLayerTransform(
                    layer.id,
                    offset: newOffset,
                    scale: newScale,
                    rotation: newRotation,
                  );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: layer.offset,
                  child: Transform.rotate(
                    angle: layer.rotation,
                    child: Transform.scale(
                      scale: layer.scale,
                      child: Opacity(
                        opacity: layer.opacity,
                        child: Container(
                          decoration: isSelected
                              ? BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFEA580C).withOpacity(0.85),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                )
                              : null,
                          child: renderedContent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShadowEffect(ShadowConfig shadow, EditorLayer layer) {
    if (shadow.type == ShadowType.floorShadow) {
      // 3D Isometric Floor Shadow for E-Commerce Products
      return Transform.translate(
        offset: Offset(0, shadow.distance + shadow.floorOffset),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(shadow.floorScaleX, shadow.floorScaleY),
          child: Container(
            width: 220,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: shadow.color.withOpacity(shadow.opacity),
                  blurRadius: shadow.blurRadius * 1.5,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
        ),
      );
    } else if (shadow.type == ShadowType.dropShadow) {
      // Directional Cast Shadow
      final rad = shadow.angle * (math.pi / 180.0);
      final dx = shadow.distance * math.cos(rad);
      final dy = shadow.distance * math.sin(rad);

      return Transform.translate(
        offset: Offset(dx, dy),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            shadow.color.withOpacity(shadow.opacity),
            BlendMode.srcIn,
          ),
          child: Image.memory(
            layer.imageBytes!,
            fit: BoxFit.contain,
          ),
        ),
      );
    } else if (shadow.type == ShadowType.ambientShadow) {
      return Container(
        width: 200,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: shadow.color.withOpacity(shadow.opacity),
              blurRadius: shadow.blurRadius,
              spreadRadius: 4,
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

/// Checkerboard painter for transparent canvas background
class CheckerboardPainter extends CustomPainter {
  final double squareSize;
  const CheckerboardPainter({this.squareSize = 14.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLight = Paint()..color = const Color(0xFF27272A);
    final paintDark = Paint()..color = const Color(0xFF18181B);

    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        final isEven = ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0;
        final paint = isEven ? paintLight : paintDark;
        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
