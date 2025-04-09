import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// A widget that displays map control buttons for zoom and location.
/// This follows single responsibility principle by encapsulating map controls.
class AnimatedMapControls extends StatelessWidget {
  final PlatformMapController? mapController;
  final LatLng userLocation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onLocate;

  const AnimatedMapControls({
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
          _buildControlButton(
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
          _buildControlButton(
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
          _buildControlButton(
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

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool useAccentColor = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              color: useAccentColor ? AppColors.primary : null,
              size: AppDimensions.iconSizeMedium,
            ),
          ),
        ),
      ),
    );
  }
}
