import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../domain/models/bus_stop_model.dart';
import '../../domain/models/bus_schedule_model.dart';
import '../providers/bus_providers.dart';
import 'animated_loading_indicator.dart';
import 'bus_refresh_button.dart';
import 'bus_schedule_list.dart';

class MapBottomSheet extends ConsumerWidget {
  final Animation<double> animation;
  final BusStop? selectedBusStop;
  final bool isBottomSheetOpen;
  final BusScheduleStateStatus status;
  final List<BusSchedule> busSchedules;
  final Map<String, int> earliestTimes;
  final VoidCallback onClose;

  const MapBottomSheet({
    super.key,
    required this.animation,
    required this.selectedBusStop,
    required this.isBottomSheetOpen,
    required this.status,
    required this.busSchedules,
    required this.earliestTimes,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: isBottomSheetOpen
              ? 0
              : -MediaQuery.of(context).size.height *
                  AppDimensions.bottomSheetHeight,
          height: MediaQuery.of(context).size.height *
              AppDimensions.bottomSheetHeight,
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! > 500) {
                ref.read(busScheduleProvider.notifier).closeBottomSheet();
                // Call the onClose callback
                onClose();
                HapticFeedback.mediumImpact();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.borderRadiusLarge),
                  topRight: Radius.circular(AppDimensions.borderRadiusLarge),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackWithOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.borderRadiusLarge),
                  topRight: Radius.circular(AppDimensions.borderRadiusLarge),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Pull handle indicator
                      _buildPullHandle(theme),
                      
                      // Bus stop name and info
                      if (selectedBusStop != null)
                        _buildBusStopHeader(theme, ref, selectedBusStop!, status),

                      // Bus schedule list
                      Expanded(
                        child: status == BusScheduleStateStatus.loading
                            ? const Center(
                                child: AnimatedLoadingIndicator(),
                              )
                            : busSchedules.isEmpty
                                ? _buildEmptyState(theme)
                                : BusScheduleList(
                                    busSchedules: busSchedules,
                                    earliestTimes: earliestTimes,
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPullHandle(ThemeData theme) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(
          top: AppDimensions.spacingMedium - 4,
          bottom: AppDimensions.spacingSmall,
        ),
        width: AppDimensions.pullHandleWidth,
        height: AppDimensions.pullHandleHeight,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(
            AppDimensions.borderRadiusSmall / 2,
          ),
        ),
      ),
    );
  }

  Widget _buildBusStopHeader(
    ThemeData theme, 
    WidgetRef ref, 
    BusStop busStop, 
    BusScheduleStateStatus status
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingLarge,
        AppDimensions.spacingMedium - 4,
        AppDimensions.spacingLarge,
        AppDimensions.spacingExtraSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              busStop.name,
              style: theme.textTheme.headlineMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Refresh button
          BusRefreshButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(busScheduleProvider.notifier).refreshBusSchedules();
            },
            isLoading: status == BusScheduleStateStatus.loading,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_bus_outlined,
            size: AppDimensions.iconSizeExtraLarge,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            "No buses yet—check back soon!",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}