import 'package:flutter/material.dart';
import 'package:busnow/core/l10n/app_localizations.dart';
import 'package:busnow/presentation/providers/bus_providers.dart';
import 'package:busnow/presentation/widgets/language_indicator.dart';

class BottomSheetView extends StatelessWidget {
  final AnimationController bottomSheetController;
  final Function calculateSheetHeight;
  final BusScheduleState busScheduleState;
  final BusScheduleNotifier busScheduleNotifier;
  final AnimationController mapFadeController;
  final VoidCallback onCollapseBottomSheet;
  final Function(DragUpdateDetails) onDragUpdate;
  final Function(DragEndDetails) onDragEnd;

  const BottomSheetView({
    Key? key,
    required this.bottomSheetController,
    required this.calculateSheetHeight,
    required this.busScheduleState,
    required this.busScheduleNotifier,
    required this.mapFadeController,
    required this.onCollapseBottomSheet,
    required this.onDragUpdate,
    required this.onDragEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: bottomSheetController,
      builder: (context, child) {
        final height = calculateSheetHeight(bottomSheetController.value);
        
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: height,
          child: GestureDetector(
            onVerticalDragUpdate: onDragUpdate,
            onVerticalDragEnd: onDragEnd,
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle and controls
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Language indicator (compact for the bottom sheet)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Bus stop info or loading indicator
                        if (busScheduleState.status == BusScheduleStateStatus.loading)
                          Text(l10n.loading),
                        if (busScheduleState.status == BusScheduleStateStatus.loaded && 
                            busScheduleState.selectedBusStop != null)
                          Text(
                            busScheduleState.selectedBusStop!.name,
                            style: theme.textTheme.titleMedium,
                          ),
                        
                        // Language indicator
                        const LanguageIndicator(compact: true),
                      ],
                    ),
                  ),
                  
                  // Content placeholder - replace with actual content
                  Expanded(
                    child: Center(
                      child: busScheduleState.status == BusScheduleStateStatus.loading
                          ? CircularProgressIndicator()
                          : Text(l10n.detailsMessage),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
