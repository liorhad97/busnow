import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/domain/models/bus_schedule_model.dart';
import 'package:flutter/material.dart';

/// A widget for displaying a single bus schedule item
class BusScheduleItem extends StatefulWidget {
  final BusSchedule schedule;
  final bool isEarliest;

  const BusScheduleItem({
    super.key,
    required this.schedule,
    required this.isEarliest,
  });

  @override
  State<BusScheduleItem> createState() => _BusScheduleItemState();
}

class _BusScheduleItemState extends State<BusScheduleItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: AppDimensions.animDurationExtraLong,
      ),
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
  void didUpdateWidget(BusScheduleItem oldWidget) {
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

    return Card(
      elevation: AppDimensions.elevationSmall,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMedium),
          child: Row(
            children: [
              // Bus number circle
              Container(
                width: AppDimensions.busNumberCircleSize,
                height: AppDimensions.busNumberCircleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.15),
                ),
                child: Center(
                  child: Text(
                    widget.schedule.busNumber,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMedium),

              // Destination and arrival info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.schedule.destination,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingExtraSmall),
                    Text(
                      'Arriving in',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrival time
              AnimatedBuilder(
                animation: _blinkController,
                builder: (context, child) {
                  final bgColor =
                      widget.isEarliest
                          ? isDarkMode
                              ? Color.lerp(
                                AppColors.busScheduleHighlightDark.withOpacity(
                                  0.5,
                                ),
                                AppColors.busScheduleHighlight.withOpacity(0.7),
                                _opacityAnimation.value,
                              )
                              : Color.lerp(
                                const Color(0xFFE8F5E9),
                                AppColors.busScheduleHighlightLight,
                                _opacityAnimation.value,
                              )
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
                    child: Text(
                      '${widget.schedule.arrivalTimeInMinutes} min',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
