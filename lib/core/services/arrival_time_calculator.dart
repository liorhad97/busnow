import 'dart:math' as math;
import 'package:busnow/domain/models/bus_location_model.dart';
import 'package:busnow/domain/models/bus_stop_model.dart';

/// Service for calculating estimated bus arrival times based on real-time GPS data
class ArrivalTimeCalculator {
  /// Calculate the estimated arrival time in minutes for a bus to reach a specific stop
  int calculateArrivalTimeInMinutes(BusLocationData bus, BusStop busStop) {
    // Calculate the distance between the bus and the stop
    final double distanceInKm = _calculateDistanceInKm(
      bus.latitude,
      bus.longitude,
      busStop.latitude,
      busStop.longitude,
    );

    // Get the bus speed in km/h (if speed is 0, assume a default speed of 20 km/h)
    final double speedKmh = bus.speed > 0 ? bus.speed : 20.0;

    // Convert speed from km/h to km/minute
    final double speedKmPerMinute = speedKmh / 60;

    // Calculate estimated time in minutes
    int estimatedMinutes = (distanceInKm / speedKmPerMinute).round();

    // Add traffic factor (this could be improved with real traffic data)
    final int trafficFactor = _calculateTrafficFactor();
    estimatedMinutes += trafficFactor;

    // Make sure we always show at least 1 minute
    return math.max(1, estimatedMinutes);
  }

  /// Calculate traffic factor based on time of day
  /// This is a simple placeholder - you could enhance this with real traffic data
  int _calculateTrafficFactor() {
    final now = DateTime.now();
    final int hour = now.hour;

    // Rush hours: 7-9 AM and 4-7 PM
    if ((hour >= 7 && hour <= 9) || (hour >= 16 && hour <= 19)) {
      return 5; // Add 5 minutes during rush hour
    } else if (hour >= 22 || hour <= 5) {
      return -1; // Subtract 1 minute during night (less traffic)
    }

    return 0; // No adjustment during regular hours
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Radius of the Earth in km
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
