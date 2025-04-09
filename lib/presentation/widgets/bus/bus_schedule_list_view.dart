import 'package:flutter/material.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/domain/models/bus_schedule_model.dart';
import 'package:busnow/presentation/widgets/bus/bus_schedule_item.dart';

/// A beautifully animated list of bus schedules
///
/// Features:
/// - Staggered entrance animations for items
/// - Fade and slide effects synced with parent animation
/// - Custom scroll physics for smooth scrolling
/// - Highlighting for earliest arrivals
class BusScheduleListView extends StatelessWidget {
  final ScrollController scrollController;
  final Animation<double> contentAnimation;
  final List<BusSchedule> busSchedules;
  final Map<String, int> earliestTimes;
  
  const BusScheduleListView({
    Key? key,
    required this.scrollController,
    required this.contentAnimation,
    required this.busSchedules,
    required this.earliestTimes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: contentAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: contentAnimation.value,
          child: child,
        );
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacingMedium,
          AppDimensions.spacingSmall,
          AppDimensions.spacingMedium,
          AppDimensions.spacingLarge,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: busSchedules.length,
        itemBuilder: (context, index) {
          final schedule = busSchedules[index];
          final isEarliest = earliestTimes[schedule.busNumber] == schedule.arrivalTimeInMinutes;

          // Create a staggered animation for each item
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(
              milliseconds: AppDimensions.animDurationMedium + (index * 50),
            ),
            curve: Curves.easeOutQuart,
            builder: (context, value, child) {
              // Only animate once content animation is active
              final adjustedValue = value * contentAnimation.value;

              return Transform.translate(
                offset: Offset(0, 20 * (1 - adjustedValue)),
                child: Opacity(opacity: adjustedValue, child: child),
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
      ),
    );
  }
}
