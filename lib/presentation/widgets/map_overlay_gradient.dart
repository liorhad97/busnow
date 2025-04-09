import 'package:busnow/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// A widget that displays a gradient overlay on the map.
/// This follows single responsibility principle by encapsulating the gradient functionality.
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

class GradientOverlayPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;

  GradientOverlayPainter({
    required this.animationValue,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw gradient overlay
    final Paint gradientPaint = Paint();
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    gradientPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.1 * animationValue),
        Colors.black.withOpacity(0.3 * animationValue),
      ],
      stops: const [0.6, 0.75, 1.0],
    ).createShader(rect);

    canvas.drawRect(rect, gradientPaint);

    // Add a subtle wave at the bottom
    final wavePaint =
        Paint()
          ..color = primaryColor.withOpacity(0.07 * animationValue)
          ..style = PaintingStyle.fill;

    final wavePath = Path();
    wavePath.moveTo(0, size.height);

    // Create a gentle wave pattern
    final waveHeight = 40.0 * animationValue;
    final segments = 4;
    final segmentWidth = size.width / segments;

    for (int i = 0; i <= segments; i++) {
      final x = i * segmentWidth;
      final y = size.height - (i.isEven ? 0 : waveHeight);

      if (i == 0) {
        wavePath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * segmentWidth;
        final prevY = size.height - ((i - 1).isEven ? 0 : waveHeight);

        // Use quadratic bezier curve for smooth wave
        final controlX = (prevX + x) / 2;
        final controlY = prevY > y ? size.height : size.height - waveHeight;

        wavePath.quadraticBezierTo(controlX, controlY, x, y);
      }
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
