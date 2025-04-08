import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:flutter/material.dart';

/// A widget that displays a center cursor for the map
/// Follows OOP principles by encapsulating this UI component into its own class
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: AppDimensions.animDurationShort),
                        width: isMapMoving ? 10 : 8,
                        height: isMapMoving ? 10 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isMapMoving 
                            ? AppColors.primary 
                            : AppColors.primary.withOpacity(0.8),
                          boxShadow: isMapMoving ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 4,
                            ),
                          ] : null,
                        ),
                      ),
                    ),
                  ),
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
