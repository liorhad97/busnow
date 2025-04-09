import 'package:busnow/presentation/widgets/bus/bus_number_circle.dart';
import 'package:flutter/material.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/domain/models/bus_schedule_model.dart';
import 'package:busnow/presentation/widgets/bus/blinking_time_display.dart';

/// A widget for displaying a single bus schedule item
///
/// Features:
/// - Clean, card-based design for schedule entries
/// - Displays bus number, destination, and arrival time
/// - Special highlighting for the earliest bus
/// - Animated blinking effect for imminent arrivals
class BusScheduleItem extends StatelessWidget {
  final BusSchedule schedule;
  final bool isEarliest;

  const BusScheduleItem({
    Key? key,
    required this.schedule,
    required this.isEarliest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

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
              BusNumberCircle(
                busNumber: schedule.busNumber,
                statusColor: primaryColor,
              ),

              const SizedBox(width: AppDimensions.spacingMedium),

              // Destination and arrival info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.destination,
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

              // Arrival time with blinking effect for earliest bus
              BlinkingTimeDisplay(
                minutes: schedule.arrivalTimeInMinutes,
                isEarliest: isEarliest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
