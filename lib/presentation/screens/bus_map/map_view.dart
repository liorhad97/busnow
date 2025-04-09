import 'package:flutter/material.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/presentation/widgets/map/map_center_cursor.dart';
import 'package:busnow/presentation/widgets/map/map_overlay_gradient.dart';

/// A component that manages the map display and interactions
/// 
/// Responsible for displaying:
/// - The map with markers
/// - The center cursor when appropriate
/// - The map overlay gradient
class MapView extends StatelessWidget {
  final bool isBottomSheetExpanded;
  final bool isMapMoving;
  final PlatformMapController? mapController;
  final Set<Marker> markers;
  final LatLng? userLocation;
  final LatLng defaultPosition;
  final AnimationController mapFadeController;
  final void Function(PlatformMapController) onMapCreated;
  final void Function(CameraPosition) onCameraMove;
  final VoidCallback onCameraIdle;

  const MapView({
    Key? key,
    required this.isBottomSheetExpanded,
    required this.isMapMoving,
    required this.mapController,
    required this.markers,
    required this.userLocation,
    required this.defaultPosition,
    required this.mapFadeController,
    required this.onMapCreated,
    required this.onCameraMove,
    required this.onCameraIdle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the initial camera position based on user location or default
    final initialCameraPosition = CameraPosition(
      target: userLocation ?? defaultPosition,
      zoom: AppDimensions.mapInitialZoom,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // The actual map
        PlatformMap(
          initialCameraPosition: initialCameraPosition,
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          markers: markers,
          onMapCreated: onMapCreated,
          onCameraMove: onCameraMove,
          onCameraIdle: onCameraIdle,
        ),

        // Target cursor in center of screen - only shown when bottom sheet is not expanded
        if (!isBottomSheetExpanded)
          MapCenterCursor(isMapMoving: isMapMoving),

        // Map overlay gradient
        MapOverlayGradient(fadeAnimation: mapFadeController),
      ],
    );
  }
}