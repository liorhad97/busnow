import 'package:flutter/material.dart';

/// A custom painter for drawing the loading indicator
///
/// Creates a visually appealing loading indicator with:
/// - Circle with gradient fill
/// - Inner white ring
/// - Center dot
/// - Subtle shadow effects
class LoadingIndicatorPainter extends CustomPainter {
  final Color color;

  LoadingIndicatorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    // Draw outer shadow
    final shadowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawCircle(center, radius, shadowPaint);

    // Draw main circle with gradient
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color,
          color.withBlue((color.blue + 20).clamp(0, 255)),
        ],
        center: const Alignment(0.2, 0.2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, gradientPaint);

    // Draw inner white ring
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius * 0.7, ringPaint);

    // Draw center dot
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(center, radius * 0.4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
