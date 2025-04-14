import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/core/rtl/rtl_padding.dart';
import 'package:busnow/core/rtl/translator_helper.dart';
import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
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
    final timesToShow = sortedTimes.take(2).toList();
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
              "+${sortedTimes.length - 2}",
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
    // Use green color for earliest time and black for other times

    return RtlPadding(
      right: hasNext ? 4.0 : 0.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color:
              isEarliest
                  ? AppColors.busEarlyColor.withOpacity(
                    0.1 + (_blinkController.value * 0.15),
                  )
                  : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        ),
        child: Row(
          children: [
            // Text on top for readability
            Text(
              L10n.of(context).minutesAbbreviated(minutes),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.0, // Bigger font size
                fontWeight: isEarliest ? FontWeight.bold : FontWeight.normal,
                color: isEarliest ? AppColors.busEarlyColor : Colors.black87,
              ),
            ),

            // Lottie animation behind the text, tilted 45 degrees
            if (isEarliest)
              SizedBox(
                width: 20.0,
                height: 20.0,
                child: Transform.rotate(
                  angle: 45 * 3.14159 / 180, // 45 degrees in radians
                  child: Lottie.asset(
                    LottieDir.wifi,
                    animate: true,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
