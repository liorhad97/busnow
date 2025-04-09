import 'package:flutter/material.dart';
import 'package:busnow/presentation/widgets/decorations/gradient_overlay_painter.dart';

/// A widget that displays a gradient overlay on the map
///
/// Features:
/// - Dark gradient at the bottom for better contrast with UI elements
/// - Subtle wave effect for visual interest
/// - Fade in/out animation based on external animation controller
/// - Ignores pointer events to allow interaction with the map underneath
class MapOverlayGradient extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const MapOverlayGradient({Key? key, required this.fadeAnimation})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: CustomPaint(
              painter: GradientOverlayPainter(
                animationValue: fadeAnimation.value,
                primaryColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}
