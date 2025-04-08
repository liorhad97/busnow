import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../domain/models/bus_stop_model.dart';

class MapTargetCursor extends StatelessWidget {
  final List<BusStop> busStops;
  final PlatformMapController? mapController;
  final Function(BusStop) onBusStopFound;

  const MapTargetCursor({
    super.key,
    required this.busStops,
    required this.mapController,
    required this.onBusStopFound,
  });

  /// Check if the center of the map is within range of any bus stop
  // Simple distance calculation (in degrees)
  double _calculateDistance(
    double lat1, double lon1, 
    double lat2, double lon2
  ) {
    return math.sqrt(
      math.pow(lat2 - lat1, 2) + math.pow(lon2 - lon1, 2)
    );
  }

  void checkForBusStopsAtCenter() async {
    if (mapController == null || busStops.isEmpty) return;
    
    try {
      // Get the visible region from the map
      final LatLngBounds visibleRegion = await mapController!.getVisibleRegion();
      
      // Calculate the center of the visible region
      final centerPosition = LatLng(
        (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
        (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
      );
      
      // Define a small radius for detection (approximately 50 meters)
      const double detectionRadiusInDegrees = 0.0005; // ~50m at the equator
      
      // Check if center is near any bus stop
      for (final busStop in busStops) {
        final double distance = _calculateDistance(
          centerPosition.latitude, 
          centerPosition.longitude,
          busStop.latitude,
          busStop.longitude,
        );
        
        if (distance < detectionRadiusInDegrees) {
          HapticFeedback.lightImpact();
          onBusStopFound(busStop);
          break;
        }
      }
    } catch (e) {
      // Handle any errors that might occur during map operations
      debugPrint('Error checking for bus stops: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: AppDimensions.iconSizeLarge,
            color: AppColors.primary.withOpacity(0.8),
          ),
          Container(
            width: 1.5,
            height: 10,
            color: AppColors.primary.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
