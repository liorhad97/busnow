import 'package:busnow/core/constants/dir/lottie_dir.dart';
import 'package:busnow/core/rtl/rtl_row.dart';
import 'package:busnow/core/rtl/translator_helper.dart';
import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:lottie/lottie.dart';

/// A time display that blinks to highlight the earliest bus arrival
///
/// Features:
/// - Animated blinking effect for earliest arrival
/// - Adaptive colors for light and dark themes
/// - Responsive typography with proper contrast
class BlinkingTimeDisplay extends StatefulWidget {
  final int minutes;
  final bool isEarliest;

  const BlinkingTimeDisplay({
    Key? key,
    required this.minutes,
    required this.isEarliest,
  }) : super(key: key);

  @override
  State<BlinkingTimeDisplay> createState() => _BlinkingTimeDisplayState();
}

class _BlinkingTimeDisplayState extends State<BlinkingTimeDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: AppDimensions.animDurationExtraLong),
    );

    if (widget.isEarliest) {
      _blinkController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BlinkingTimeDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEarliest && !oldWidget.isEarliest) {
      _blinkController.repeat(reverse: true);
    } else if (!widget.isEarliest && oldWidget.isEarliest) {
      _blinkController.stop();
      _blinkController.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        final bgColor =
            widget.isEarliest
                ? isDarkMode
                    ? AppColors.busScheduleHighlightDark
                    : AppColors.busScheduleHighlightTextLight.withOpacity(0.05)
                : Colors.transparent;

        final textColor =
            widget.isEarliest
                ? isDarkMode
                    ? AppColors.busScheduleHighlightTextDark
                    : AppColors.busScheduleHighlightTextLight
                : theme.colorScheme.onSurface;

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMedium - 4,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMedium - 4,
            vertical: AppDimensions.spacingSmall,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadiusCircular,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: AppDimensions.spacingMedium),
              Text(
                L10n.of(context).minutesAbbreviated(widget.minutes),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Transform.rotate(
                angle: 45 * (3.14159 / 180), // 45 degrees in radians
                child: Lottie.asset(
                  LottieDir.wifi,
                  width: AppDimensions.iconSizeLarge,
                  height: AppDimensions.iconSizeLarge,
                  repeat: true,
                  controller: _blinkController,
                  onLoaded: (composition) {
                    _blinkController.duration = composition.duration;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
