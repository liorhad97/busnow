import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/core/direction/direction_aware_builder.dart';
import 'package:busnow/core/localization/app_localizations.dart';

/// A component that provides map control buttons
///
/// Responsible for:
/// - Zoom in/out buttons
/// - Location button to center the map on the user
/// - Proper positioning based on bottom sheet state
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
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return DirectionAwareBuilder(
      builder: (context, isLtr) {
        return AnimatedBuilder(
          animation: bottomSheetController,
          builder: (context, child) {
            // Calculate position based on bottom sheet state
            final bottomPadding = lerpDouble(
              AppDimensions.spacingLarge,
              expandedSheetHeight + AppDimensions.spacingMedium,
              bottomSheetController.value,
            )!;

            return Positioned(
              right: isLtr ? AppDimensions.spacingMedium : null,
              left: isLtr ? null : AppDimensions.spacingMedium,
              bottom: bottomPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Zoom in button
                  _buildControlButton(
                    context: context,
                    icon: Icons.add,
                    onPressed: () => _handleZoom(context, true),
                    tooltip: localizations.translate('zoom_in'),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  
                  // Zoom out button
                  _buildControlButton(
                    context: context,
                    icon: Icons.remove,
                    onPressed: () => _handleZoom(context, false),
                    tooltip: localizations.translate('zoom_out'),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  
                  // Locate me button with special styling
                  _buildControlButton(
                    context: context,
                    icon: Icons.my_location,
                    onPressed: onLocate,
                    tooltip: localizations.translate('my_location'),
                    useAccentColor: true,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool useAccentColor = false,
  }) {
    final theme = Theme.of(context);
    
    return Material(
      elevation: AppDimensions.elevationSmall,
      shadowColor: theme.shadowColor.withOpacity(0.3),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: useAccentColor ? theme.colorScheme.primary : theme.colorScheme.surface,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        child: Container(
          width: AppDimensions.mapControlButtonSize,
          height: AppDimensions.mapControlButtonSize,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: useAccentColor 
                ? theme.colorScheme.onPrimary 
                : theme.colorScheme.onSurface,
            size: AppDimensions.iconSizeSmall,
          ),
        ),
      ),
    );
  }

  // Handle zoom in/out with proper bounds checking
  void _handleZoom(BuildContext context, bool zoomIn) {
    if (mapController == null) return;
    
    final min = AppDimensions.mapMinZoom;
    final max = AppDimensions.mapMaxZoom;
    
    // Calculate new zoom level with bounds checking
    double newZoom = zoomIn 
        ? (currentZoom + 1).clamp(min, max)
        : (currentZoom - 1).clamp(min, max);
    
    // If already at min/max, show feedback but don't zoom
    if ((zoomIn && currentZoom >= max) || (!zoomIn && currentZoom <= min)) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.selectionClick();
    
    // Animate to new zoom level
    mapController!.animateCamera(
      CameraUpdate.zoomTo(newZoom),
    );
  }
}

// Helper method for double lerp with null safety
double lerpDouble(double a, double b, double t) {
  return a + (b - a) * t;
}
