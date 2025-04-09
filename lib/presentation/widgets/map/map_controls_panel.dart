import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/presentation/widgets/map/map_control_button.dart';

/// A panel of controls for map interactions
///
/// Features:
/// - Zoom in/out buttons
/// - User location button with accent color
/// - Elegant container with shadow and rounded corners
/// - Haptic feedback for better user experience
class MapControlsPanel extends StatelessWidget {
  final PlatformMapController? mapController;
  final LatLng userLocation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onLocate;

  const MapControlsPanel({
    Key? key,
    required this.mapController,
    required this.userLocation,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onLocate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom in button
          MapControlButton(
            icon: Icons.add,
            onPressed: onZoomIn,
            tooltip: 'Zoom in',
          ),
          
          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
          
          // Zoom out button
          MapControlButton(
            icon: Icons.remove,
            onPressed: onZoomOut,
            tooltip: 'Zoom out',
          ),
          
          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
          
          // Locate user button
          MapControlButton(
            icon: Icons.my_location,
            onPressed: () {
              HapticFeedback.selectionClick();
              onLocate();
            },
            tooltip: 'My location',
            useAccentColor: true,
          ),
        ],
      ),
    );
  }
}
