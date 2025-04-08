import 'package:flutter/material.dart';

/// A widget that displays a gradient overlay on the map.
/// This follows single responsibility principle by encapsulating the gradient functionality.
class MapOverlayGradient extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const MapOverlayGradient({
    Key? key,
    required this.fadeAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1 * fadeAnimation.value),
                    Colors.black.withOpacity(0.3 * fadeAnimation.value),
                  ],
                  stops: const [0.6, 0.75, 1.0],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
