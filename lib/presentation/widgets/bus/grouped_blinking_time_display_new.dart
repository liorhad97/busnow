import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/core/constants/dir/lottie_dir.dart';
import 'package:lottie/lottie.dart';

/// A compact display for multiple bus arrival times
///
/// Features:
/// - Shows multiple arrival times in a space-efficient horizontal layout
/// - Animated blinking effect only for the earliest arrival time
/// - Adaptive colors for light and dark themes
/// - Clean typography with proper contrast
/// - Lottie animation for visual appeal
class GroupedBlinkingTimeDisplay extends StatefulWidget {
  final List<int> arrivalTimes;
  final int earliestTime;

  const GroupedBlinkingTimeDisplay({
    Key? key,
    required this.arrivalTimes,
    required this.earliestTime,
  }) : super(key: key);

  @override
  State<GroupedBlinkingTimeDisplay> createState() =>
      _GroupedBlinkingTimeDisplayState();
}

class _GroupedBlinkingTimeDisplayState extends State<GroupedBlinkingTimeDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: AppDimensions.animDurationLoading),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedTimes = List<int>.from(widget.arrivalTimes)..sort();

    // Limit to showing only the first 3 arrival times
    final timesToShow = sortedTimes.take(3).toList();
    final hasMoreTimes = sortedTimes.length > 3;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < timesToShow.length; i++)
          _buildTimeChip(
            context,
            timesToShow[i],
            timesToShow[i] == widget.earliestTime,
            i < timesToShow.length - 1,
          ),
        // Show a "+more" indicator if there are additional times
        if (hasMoreTimes)
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              "+${sortedTimes.length - 3}",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeChip(
    BuildContext context,
    int minutes,
    bool isEarliest,
    bool hasNext,
  ) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(right: hasNext ? 4.0 : 0.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base container with time text
          AnimatedBuilder(
            animation: _blinkController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color:
                      isEarliest
                          ? color.withOpacity(
                            0.1 + (_blinkController.value * 0.15),
                          )
                          : color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusSmall,
                  ),
                ),
                child: Text(
                  "${minutes}m",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        isEarliest ? FontWeight.bold : FontWeight.normal,
                    color: color.withOpacity(
                      isEarliest ? 0.7 + (_blinkController.value * 0.3) : 0.7,
                    ),
                  ),
                ),
              );
            },
          ),

          // Lottie animation for earliest time
          if (isEarliest)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Opacity(
                  opacity: 0.7,
                  child: Lottie.asset(
                    LottieDir.wifi,
                    animate: true,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
