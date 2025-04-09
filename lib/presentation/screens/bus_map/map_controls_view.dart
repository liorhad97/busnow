import 'package:flutter/material.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/presentation/widgets/map/map_controls_panel.dart';

/// A component that manages the map control buttons
/// 
/// Positions and animates the controls panel based on the bottom sheet state
class MapControlsView extends StatelessWidget {
  final AnimationController bottomSheetController;
  final double expandedSheetHeight;
  final PlatformMapController? mapController;
  final double currentZoom;
  final LatLng userLocation;
  final VoidCallback onLocate;

  const MapControlsView({
    Key? key,
    required this.bottomSheetController,
    required this.expandedSheetHeight,
    required this.mapController,
    required this.currentZoom,
    required this.userLocation,
    required this.onLocate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      right: AppDimensions.spacingMedium,
      bottom: bottomSheetController.value > 0.05
          ? screenSize.height *
                  expandedSheetHeight *
                  bottomSheetController.value +
              AppDimensions.spacingMedium
          : AppDimensions.spacingExtraLarge,
      child: MapControlsPanel(
        mapController: mapController,
        userLocation: userLocation,
        onZoomIn: () {
          if (mapController != null && currentZoom < 20) {
            mapController!.animateCamera(CameraUpdate.zoomIn());
          }
        },
        onZoomOut: () {
          if (mapController != null && currentZoom > 5) {
            mapController!.animateCamera(CameraUpdate.zoomOut());
          }
        },
        onLocate: onLocate,
      ),
    );
  }
}
