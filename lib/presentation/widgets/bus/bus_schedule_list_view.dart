import 'package:busnow/presentation/widgets/bus/grouped_bus_schedule_item.dart';
import 'package:flutter/material.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/domain/models/bus_schedule_group_model.dart';

/// A beautifully animated list of grouped bus schedules
///
/// Features:
/// - Shows multiple arrival times for the same bus route in a single item
/// - Staggered entrance animations for items
/// - Fade and slide effects synced with parent animation
/// - Custom scroll physics for smooth scrolling
/// - Highlighting for earliest arrivals within each group
class BusScheduleListView extends StatelessWidget {
  final ScrollController scrollController;
  final Animation<double> contentAnimation;
  final List<BusScheduleGroup> scheduleGroups;

  const BusScheduleListView({
    super.key,
    required this.scrollController,
    required this.contentAnimation,
    required this.scheduleGroups,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: contentAnimation,
      builder: (context, child) {
        return Opacity(opacity: contentAnimation.value, child: child);
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
        itemCount: scheduleGroups.length,
        itemBuilder: (context, index) {
          final scheduleGroup = scheduleGroups[index];

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
              child: GroupedBusScheduleItem(scheduleGroup: scheduleGroup),
            ),
          );
        },
      ),
    );
  }
}
