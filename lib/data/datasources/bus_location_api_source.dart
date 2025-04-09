import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:busnow/domain/models/bus_location_model.dart';
import 'dart:math' as math;

/// Data source for fetching real-time bus locations from the Israeli API
class BusLocationDataSource {
  final String apiUrl;
  final String apiKey;

  BusLocationDataSource({required this.apiUrl, required this.apiKey});

  /// Fetch all bus locations from the API
  Future<List<BusLocationData>> fetchBusLocations() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> busesJson = data['buses'] ?? [];

        return busesJson.map((json) => BusLocationData.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load bus locations: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch bus locations: $e');
    }
  }

  /// Fetch bus locations for a specific route
  Future<List<BusLocationData>> fetchBusLocationsForRoute(
    String routeNumber,
  ) async {
    final allBuses = await fetchBusLocations();
    return allBuses.where((bus) => bus.routeNumber == routeNumber).toList();
  }

  /// Fetch bus locations near a specific location
  Future<List<BusLocationData>> fetchBusLocationsNearby(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    // This would typically be a direct API call with query parameters,
    // but for now we'll filter the results client-side
    final allBuses = await fetchBusLocations();

    return allBuses.where((bus) {
      final distance = _calculateDistanceInKm(
        latitude,
        longitude,
        bus.latitude,
        bus.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  // Calculate distance between two coordinates using Haversine formula
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
