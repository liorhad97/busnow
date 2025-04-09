import 'package:flutter/material.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/core/localization/app_localizations.dart';
import 'package:busnow/domain/models/bus_schedule_model.dart';
import 'package:busnow/presentation/widgets/bus/bus_schedule_row.dart';

/// A widget that displays a list of bus schedules grouped by route
class BusScheduleListView extends StatelessWidget {
  final ScrollController scrollController;
  final Animation<double> contentAnimation;
  final List<BusScheduleGroup> scheduleGroups;

  const BusScheduleListView({
    Key? key,
    required this.scrollController,
    required this.contentAnimation,
    required this.scheduleGroups,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    return AnimatedBuilder(
      animation: contentAnimation,
      builder: (context, child) {
        // Apply slide-up animation
        final slideDistance = (1 - contentAnimation.value) * 100;

        return Opacity(
          opacity: contentAnimation.value,
          child: Transform.translate(
            offset: Offset(0, slideDistance),
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(
                left: AppDimensions.spacingMedium,
                right: AppDimensions.spacingMedium,
                bottom: AppDimensions.spacingLarge,
              ),
              itemCount: scheduleGroups.length,
              itemBuilder: (context, index) {
                final group = scheduleGroups[index];
                final schedules = group.schedules;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group header with route number
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingSmall,
                      ),
                      child: Row(
                        children: [
                          // Route number badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingSmall,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusSmall,
                              ),
                            ),
                            child: Text(
                              group.routeNumber,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingSmall),
                          // Destination text
                          Expanded(
                            child: Text(
                              group.destination,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Schedule count
                          Text(
                            schedules.length == 1
                                ? '1 ${localizations.translate("departure")}'
                                : '${schedules.length} ${localizations.translate("departures")}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Schedule rows
                    ...schedules.map((schedule) => BusScheduleRow(
                          schedule: schedule,
                        )),

                    // Divider between groups
                    if (index < scheduleGroups.length - 1)
                      const Divider(height: AppDimensions.spacingLarge),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
