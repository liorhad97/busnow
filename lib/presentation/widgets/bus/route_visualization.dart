import 'package:flutter/material.dart';
import 'package:busnow/core/constants/dimensions.dart';

/// A visual representation of the bus route with start and end points
///
/// Features:
/// - Animated drawing of the route path
/// - Location markers with scaling animations
/// - Adaptive colors based on bus status
/// - Progress indicator showing current bus position
class RouteVisualization extends StatelessWidget {
  final Color statusColor;
  final String originName;
  final String destinationName;
  
  const RouteVisualization({
    Key? key,
    required this.statusColor,
    required this.originName,
    required this.destinationName,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(
        top: AppDimensions.spacingMedium, 
        bottom: AppDimensions.spacingLarge
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        color: theme.cardTheme.color?.withOpacity(0.7) ?? theme.colorScheme.surface.withOpacity(0.7),
        border: Border.all(color: statusColor.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      child: Column(
        children: [
          // Origin point
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
                builder: (context, value, _) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: statusColor,
                        size: 14,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(width: AppDimensions.spacingMedium),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      originName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Animated route progress line
          Container(
            margin: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  builder: (context, value, _) {
                    return Container(
                      width: 2,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            statusColor,
                            Color.lerp(statusColor, Colors.grey.withOpacity(0.5), 1 - value)!,
                          ],
                          stops: [value, value],
                        ),
                      ),
                    );
                  },
                ),
                
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSmall),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Opacity(
                          opacity: value,
                          child: Container(
                            margin: const EdgeInsets.only(left: AppDimensions.spacingExtraLarge),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingSmall,
                              vertical: AppDimensions.spacingExtraSmall,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'En Route',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Destination point
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
                builder: (context, value, _) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            statusColor.withOpacity(0.9),
                            statusColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.flag_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(width: AppDimensions.spacingMedium),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destination',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destinationName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
