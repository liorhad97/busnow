import 'package:flutter/material.dart';

/// Decorative background painter for enhanced visual appeal
///
/// Creates a beautiful grid pattern with lines, curves, and dynamic dots
/// that provides depth and visual interest to sheet backgrounds.
class DecorativeBackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double animationValue;
  final bool isDarkMode;

  DecorativeBackgroundPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.animationValue,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a grid pattern with circles and lines
    final double spacing = 40.0;
    final int horizontalCount = (size.width / spacing).ceil() + 1;
    final int verticalCount = (size.height / spacing).ceil() + 1;

    // Draw connecting lines first
    final linePaint =
        Paint()
          ..color = (isDarkMode ? Colors.white : Colors.black).withOpacity(
            0.03 * animationValue,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

    // Create a path for the lines
    final path = Path();

    // Draw dynamic curved paths for extra visual interest
    for (int i = 0; i < 5; i++) {
      final offset = i * 0.2;
      final control1x = size.width * (0.2 + offset);
      final control1y = size.height * (0.1 + offset * 0.5);
      final control2x = size.width * (0.8 - offset);
      final control2y = size.height * (0.5 + offset * 0.3);

      path.moveTo(0, size.height * (0.3 + offset * 0.2));
      path.cubicTo(
        control1x,
        control1y,
        control2x,
        control2y,
        size.width,
        size.height * (0.7 - offset * 0.1),
      );
    }

    canvas.drawPath(path, linePaint);

    // Create another path for diagonal flowing lines
    final flowPath = Path();

    for (int i = 0; i < 3; i++) {
      final offset = i * 0.3;
      flowPath.moveTo(size.width * offset, 0);
      flowPath.quadraticBezierTo(
        size.width * (0.5 + offset * 0.2),
        size.height * (0.5 + offset * 0.1),
        size.width * (1 - offset),
        size.height,
      );
    }

    canvas.drawPath(
      flowPath,
      Paint()
        ..color = primaryColor.withOpacity(0.03 * animationValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Draw small dots in a grid pattern
    final dotRadius = 1.5;
    final dotPaint =
        Paint()
          ..color = secondaryColor.withOpacity(0.1 * animationValue)
          ..style = PaintingStyle.fill;

    for (int x = 0; x < horizontalCount; x++) {
      for (int y = 0; y < verticalCount; y++) {
        // Skip some dots randomly for more organic look
        if ((x + y) % 3 == 0) continue;

        final xPos = x * spacing;
        final yPos = y * spacing;

        canvas.drawCircle(Offset(xPos, yPos), dotRadius, dotPaint);
      }
    }

    // Draw a few larger circles for accent
    final accentPaint =
        Paint()
          ..color = primaryColor.withOpacity(0.05 * animationValue)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      30 * animationValue,
      accentPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      40 * animationValue,
      accentPaint,
    );

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
