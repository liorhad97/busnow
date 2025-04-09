import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';

/// A beautifully animated handle for bottom sheets
///
/// Features:
/// - Scaling animation based on sheet state
/// - Pulsing dots for dragging indication
/// - Shadow effects for depth
/// - Supports tap to close when expanded
class BottomSheetHandle extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback? onTap;

  const BottomSheetHandle({
    Key? key,
    required this.animation,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: animation.value >= 0.9 ? onTap : null, // Tap to close when expanded
      child: SizedBox(
        height: 40,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shadow layer
              Container(
                width: AppDimensions.pullHandleWidth + 2,
                height: AppDimensions.pullHandleHeight + 2,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusCircular,
                  ),
                ),
              ),

              // Main handle
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 1.0,
                  end: animation.value < 0.5 ? 1.0 : 1.2,
                ),
                duration: const Duration(
                  milliseconds: AppDimensions.animDurationMedium,
                ),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: AppDimensions.pullHandleWidth,
                      height: AppDimensions.pullHandleHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            theme.colorScheme.onSurface.withOpacity(0.2),
                            theme.colorScheme.onSurface.withOpacity(0.3),
                            theme.colorScheme.onSurface.withOpacity(0.2),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusCircular,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Animated dot indicators for drag up when collapsed
              if (animation.value < 0.5)
                Positioned(
                  top: -14,
                  child: Column(
                    children: [
                      _buildPulsingDot(0),
                      SizedBox(height: 3),
                      _buildPulsingDot(100),
                      SizedBox(height: 3),
                      _buildPulsingDot(200),
                    ],
                  ),
                ),

              // Animated dot indicators for drag down when expanded
              if (animation.value > 0.9)
                Positioned(
                  bottom: -14,
                  child: Column(
                    children: [
                      _buildPulsingDot(200),
                      SizedBox(height: 3),
                      _buildPulsingDot(100),
                      SizedBox(height: 3),
                      _buildPulsingDot(0),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulsingDot(int delayMillis) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: math.sin(math.pi * value + (delayMillis / 1000)).abs(),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
