import 'package:busnow/core/constants/colors.dart';
import 'package:flutter/material.dart';

class MapOverlayGradient extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const MapOverlayGradient({
    super.key,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            ignoring: true,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.blackWithOpacity(
                      0.1 * fadeAnimation.value,
                    ),
                    AppColors.blackWithOpacity(
                      0.3 * fadeAnimation.value,
                    ),
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
