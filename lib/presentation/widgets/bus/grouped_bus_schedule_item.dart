import 'package:busnow/domain/models/bus_schedule_group_model.dart';
import 'package:busnow/presentation/widgets/bus/bus_number_circle.dart';
import 'package:flutter/material.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/presentation/widgets/bus/grouped_blinking_time_display.dart';

/// A widget for displaying grouped bus schedules for the same bus number
///
/// Features:
/// - Shows multiple arrival times for the same bus route in a single card
/// - Only the earliest arrival time blinks
/// - Clean, card-based design with rounded rectangle bus number
class GroupedBusScheduleItem extends StatelessWidget {
  final BusScheduleGroup scheduleGroup;

  const GroupedBusScheduleItem({Key? key, required this.scheduleGroup})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final arrivalTimes = scheduleGroup.arrivalTimes;
    final earliestTime = scheduleGroup.earliestArrivalTime;

    return Card(
      elevation: AppDimensions.elevationSmall,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMedium),
          child: Row(
            children: [
              // Bus number in rounded rectangle with icon
              BusNumberCircle(
                busNumber: scheduleGroup.busNumber,
                statusColor: primaryColor,
              ),

              const SizedBox(width: AppDimensions.spacingMedium),

              // Destination and arrival info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scheduleGroup.destination,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingExtraSmall),
                    Text(
                      'Next arrivals',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Display multiple arrival times in a row
              GroupedBlinkingTimeDisplay(
                arrivalTimes: arrivalTimes,
                earliestTime: earliestTime,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
