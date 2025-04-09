import 'package:busnow/presentation/widgets/bus/bus_refresh_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';

/// Header for displaying bus stop information with animations
///
/// Features:
/// - Animated entrance with sliding and fade effects
/// - Glowing bus icon with shadow effects
/// - Bus count badge and live update indicator
/// - Refresh button with loading state support
class BusStopHeader extends StatelessWidget {
  final Animation<double> animation;
  final String title;
  final int busCount;
  final VoidCallback onRefresh;
  final bool isLoading;

  const BusStopHeader({
    Key? key,
    required this.animation,
    required this.title,
    required this.busCount,
    required this.onRefresh,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacingLarge,
          0,
          AppDimensions.spacingLarge,
          AppDimensions.spacingExtraSmall,
        ),
        child: Row(
          children: [
            // Glow effect on bus icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.directions_bus_rounded,
                color: AppColors.primary,
                size: AppDimensions.iconSizeMedium,
              ),
            ),

            const SizedBox(width: AppDimensions.spacingMedium),

            // Bus stop name and info with layout animation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingSmall,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusCircular,
                          ),
                        ),
                        child: Text(
                          "$busCount Buses",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: AppDimensions.spacingSmall),

                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),

                      const SizedBox(width: 2),

                      Text(
                        "Live Updates",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingMedium),
                      BusRefreshButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          onRefresh();
                        },
                        isLoading: isLoading,
                        enableHaptics: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Refresh button with haptic feedback
          ],
        ),
      ),
    );
  }
}
