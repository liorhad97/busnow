import 'package:busnow/core/constants/dir/lottie_dir.dart';
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
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: AppDimensions.animDurationExtraLong),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
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
                '${widget.minutes} min',
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
                  repeat: false,
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
