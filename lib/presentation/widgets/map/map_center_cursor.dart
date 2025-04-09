import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/presentation/widgets/map/pulsing_cursor_dot.dart';

/// A widget that displays a center cursor for the map
///
/// Features:
/// - Circular cursor that indicates map center point
/// - Pulsing animation when the map is being moved
/// - Status label that appears during movement
/// - Smooth transitions between states
class MapCenterCursor extends StatelessWidget {
  final bool isMapMoving;
  
  const MapCenterCursor({
    Key? key,
    required this.isMapMoving,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Positioned.fill(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 1.0, end: 1.3),
          duration: const Duration(milliseconds: AppDimensions.animDurationLoading),
          curve: Curves.easeInOut,
          key: ValueKey(isMapMoving), // Reset animation when state changes
          // Add auto-repeat to make animation continuous
          onEnd: () {
            if (isMapMoving) {
              // This forces a rebuild with a new key to restart the animation
              (context as Element).markNeedsBuild();
            }
          },
          builder: (context, scale, child) {
            return Transform.scale(
              scale: isMapMoving ? scale : 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cursor circle container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surface.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowMedium,
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: PulsingCursorDot(isActive: isMapMoving),
                    ),
                  ),
                  
                  // Status label
                  const SizedBox(height: 4),
                  AnimatedOpacity(
                    opacity: isMapMoving ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: AppDimensions.animDurationShort),
                    child: Text(
                      "Finding bus stops...",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: AppDimensions.textSizeSmall,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: theme.colorScheme.surface.withOpacity(0.8),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
