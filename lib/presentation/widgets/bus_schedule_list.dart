import 'package:busnow/core/constants/dimensions-file.dart';
import 'package:busnow/domain/models/bus_schedule_model.dart';
import 'package:busnow/presentation/widgets/bus_schedule_item.dart';
import 'package:flutter/material.dart';

/// A widget for displaying a list of bus schedules
class BusScheduleList extends StatelessWidget {
  final List<BusSchedule> busSchedules;
  final Map<String, int> earliestTimes;

  const BusScheduleList({
    super.key,
    required this.busSchedules,
    required this.earliestTimes,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMedium,
        AppDimensions.spacingSmall,
        AppDimensions.spacingMedium,
        AppDimensions.spacingMedium,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: busSchedules.length,
      itemBuilder: (context, index) {
        final schedule = busSchedules[index];
        final isEarliest =
            earliestTimes[schedule.busNumber] == schedule.arrivalTimeInMinutes;

        // Add staggered animation for items
        return AnimatedBuilder(
          animation: AlwaysStoppedAnimation(
            1.0 - (index * 0.1).clamp(0.0, 1.0),
          ),
          builder: (context, child) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(
                milliseconds: AppDimensions.animDurationMedium + (index * 50),
              ),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.spacingSmall,
                ),
                child: BusScheduleItem(
                  schedule: schedule,
                  isEarliest: isEarliest,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
