import 'package:flutter/material.dart';
import 'package:busnow/presentation/providers/bus_providers.dart';
import 'package:busnow/presentation/widgets/bottom_sheets/enhanced_bottom_sheet.dart';

/// A component that manages the bottom sheet display and interactions
/// 
/// Responsible for displaying:
/// - The enhanced bottom sheet with bus schedules
/// - Handling drag interactions for expanding/collapsing
class BottomSheetView extends StatelessWidget {
  final AnimationController bottomSheetController;
  final AnimationController mapFadeController;
  final BusScheduleState busScheduleState;
  final double Function(Size) calculateSheetHeight;
  final VoidCallback onCollapseBottomSheet;
  final void Function(DragUpdateDetails, Size) onDragUpdate;
  final void Function(DragEndDetails) onDragEnd;

  const BottomSheetView({
    Key? key,
    required this.bottomSheetController,
    required this.mapFadeController,
    required this.busScheduleState,
    required this.calculateSheetHeight,
    required this.onCollapseBottomSheet,
    required this.onDragUpdate,
    required this.onDragEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final selectedBusStop = busScheduleState.selectedBusStop;
    final status = busScheduleState.status;
    final busSchedules = busScheduleState.busSchedules;

    return AnimatedBuilder(
      animation: bottomSheetController,
      builder: (context, child) {
        final height = calculateSheetHeight(screenSize);

        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: bottomSheetController.value > 0 ? height : 0,
          child: GestureDetector(
            onVerticalDragUpdate: (details) => onDragUpdate(details, screenSize),
            onVerticalDragEnd: onDragEnd,
            child: EnhancedBottomSheet(
              animation: bottomSheetController,
              selectedBusStop: selectedBusStop,
              nearbyBusStops: busScheduleState.nearbyBusStops,
              status: status,
              busSchedules: busSchedules,
              earliestTimes: busScheduleState.getEarliestArrivalTimes(),
              onClose: () {
                onCollapseBottomSheet();
                mapFadeController.reverse();
              },
              onRefresh: () {
                busScheduleState.notifier.refreshBusSchedules();
              },
            ),
          ),
        );
      },
    );
  }
}
