import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

class MapLocationButton extends StatelessWidget {
  final PlatformMapController? mapController;
  final LatLng initialPosition;
  final double initialZoom;
  final bool isBottomSheetOpen;

  const MapLocationButton({
    super.key,
    required this.mapController,
    required this.initialPosition,
    required this.initialZoom,
    required this.isBottomSheetOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Positioned(
      right: AppDimensions.spacingMedium,
      bottom: isBottomSheetOpen
          ? MediaQuery.of(context).size.height *
                  AppDimensions.bottomSheetHeight +
              AppDimensions.spacingMedium
          : AppDimensions.spacingExtraLarge,
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: initialPosition,
                zoom: initialZoom,
              ),
            ),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
