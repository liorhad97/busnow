import 'package:busnow/presentation/widgets/animations/animated_time_display.dart';
import 'package:flutter/material.dart';
import 'package:busnow/core/constants/dimensions.dart';

/// A widget displaying arrival time information
///
/// Features:
/// - Shows time remaining until arrival
/// - Combines clock widget with text information
/// - Animated entrance and transitions
/// - Color adapts to the bus status
class BusTimeInfo extends StatelessWidget {
  final DateTime? arrivalTime;
  final Color statusColor;

  const BusTimeInfo({
    Key? key,
    required this.arrivalTime,
    required this.statusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes =
        arrivalTime != null
            ? arrivalTime!.difference(DateTime.now()).inMinutes
            : null;
    final minutesText = minutes != null ? '$minutes min' : '--';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMedium),
      child: Row(
        children: [
          // Clock display
          AnimatedTimeDisplay(
            arrivalTime: arrivalTime,
            color: statusColor,
            isCompact: false,
          ),

          const SizedBox(width: AppDimensions.spacingMedium),

          // Minutes remaining
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      'Arrives in',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: Text(
                          minutesText,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
