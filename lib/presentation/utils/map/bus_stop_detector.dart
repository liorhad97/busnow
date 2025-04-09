import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:busnow/domain/models/bus_stop_model.dart';

/// A utility class for detecting bus stops near a given location
///
/// Provides functionality to:
/// - Find bus stops within a specified radius
/// - Sort stops by distance from a point
/// - Compare stop lists for changes
typedef DistanceCalculator = double Function(double lat1, double lon1, double lat2, double lon2);

class BusStopDetector {
  final DistanceCalculator calculateDistance;
  final double detectionRadiusInMeters;
  
  /// Create a new bus stop detector
  /// 
  /// [calculateDistance] is a function that calculates the distance between two points
  /// [detectionRadiusInMeters] is the radius in which to detect bus stops (default 200m)
  const BusStopDetector({
    required this.calculateDistance,
    this.detectionRadiusInMeters = 200.0,
  });
  
  /// Finds all bus stops within the detection radius of a given location
  /// 
  /// Returns a list of bus stops sorted by distance (closest first)
  List<BusStop> findNearbyStops(LatLng center, List<BusStop> allStops) {
    if (allStops.isEmpty) return [];
    
    // Find all bus stops within the detection radius
    List<BusStop> nearbyStops = [];
    
    for (final busStop in allStops) {
      final double distanceInMeters = calculateDistance(
        center.latitude,
        center.longitude,
        busStop.latitude,
        busStop.longitude,
      );
      
      if (distanceInMeters < detectionRadiusInMeters) {
        nearbyStops.add(busStop);
      }
    }
    
    // Sort stops by distance (closest first)
    if (nearbyStops.length > 1) {
      nearbyStops.sort((a, b) {
        final distA = calculateDistance(
          center.latitude,
          center.longitude,
          a.latitude,
          a.longitude,
        );
        final distB = calculateDistance(
          center.latitude,
          center.longitude,
          b.latitude,
          b.longitude,
        );
        return distA.compareTo(distB);
      });
    }
    
    return nearbyStops;
  }
  
  /// Determines if a list of newly detected stops is different from currently selected stops
  /// 
  /// Returns true if the lists are different (different lengths or different stops)
  bool areStopsDifferent(List<BusStop> currentStops, List<BusStop> newStops) {
    if (currentStops.isEmpty && newStops.isEmpty) return false;
    if (currentStops.length != newStops.length) return true;
    
    // Check if the primary stop (first in the list) has changed
    if (newStops.isNotEmpty && currentStops.isNotEmpty) {
      return !currentStops.map((s) => s.id).contains(newStops.first.id);
    }
    
    return true;
  }
}
