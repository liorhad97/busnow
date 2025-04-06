import 'dart:ui';

import 'package:busnow/core/constants/dimensions.dart';
import 'package:flutter/material.dart';

/// An animated loading indicator for the app
class AnimatedLoadingIndicator extends StatefulWidget {
  const AnimatedLoadingIndicator({super.key});

  @override
  State<AnimatedLoadingIndicator> createState() =>
      _AnimatedLoadingIndicatorState();
}

class _AnimatedLoadingIndicatorState extends State<AnimatedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final position = _animation.value;
        final theme = Theme.of(context);

        return SizedBox(
          width: 200,
          height: 100,
          child: CustomPaint(
            painter: BusAnimationPainter(
              position: position,
              color: theme.colorScheme.primary,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.spacingExtraLarge + 8,
                ),
                child: Text(
                  'Loading schedules...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for drawing the animated bus
class BusAnimationPainter extends CustomPainter {
  final double position;
  final Color color;

  BusAnimationPainter({required this.position, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width,
      size.height * 0.4,
    );

    // Draw the path as a guide line (optional)
    final guidePaint =
        Paint()
          ..color = color.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppDimensions.strokeWidthMedium;
    canvas.drawPath(path, guidePaint);

    // Calculate the position along the path
    final PathMetrics metrics = path.computeMetrics();
    final PathMetric pathMetric = metrics.first;
    final double length = pathMetric.length;
    final double distance = length * position;
    final Tangent? tangent = pathMetric.getTangentForOffset(distance);

    if (tangent != null) {
      final busPosition = tangent.position;

      // Draw the bus
      final busPaint =
          Paint()
            ..color = color
            ..style = PaintingStyle.fill;

      // Rotate canvas to follow path tangent
      canvas.save();
      canvas.translate(busPosition.dx, busPosition.dy);
      canvas.rotate(tangent.angle);

      // Draw bus (simplified rectangle with rounded corners)
      final busRect = Rect.fromCenter(
        center: Offset.zero,
        width: 20,
        height: 10,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(busRect, const Radius.circular(3)),
        busPaint,
      );

      // Draw wheels
      final wheelPaint =
          Paint()
            ..color = Colors.black.withOpacity(0.6)
            ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(-5, 5), 2, wheelPaint);
      canvas.drawCircle(Offset(5, 5), 2, wheelPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(BusAnimationPainter oldDelegate) {
    return position != oldDelegate.position || color != oldDelegate.color;
  }
}
