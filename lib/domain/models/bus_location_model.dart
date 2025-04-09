import 'package:flutter/material.dart';

/// Model class for real-time bus location data from the Israeli API
class BusLocationData {
  final String busId;
  final String routeNumber;
  final String routeName;
  final double latitude;
  final double longitude;
  final double speed;
  final String direction;
  final DateTime timestamp;
  final String operatorName;
  final String destination;

  const BusLocationData({
    required this.busId,
    required this.routeNumber,
    required this.routeName,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.direction,
    required this.timestamp,
    required this.operatorName,
    required this.destination,
  });

  /// Create a BusLocationData object from JSON
  factory BusLocationData.fromJson(Map<String, dynamic> json) {
    return BusLocationData(
      busId: json['bus_id'] ?? '',
      routeNumber: json['route_number'] ?? '',
      routeName: json['route_name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      direction: json['direction'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      operatorName: json['operator_name'] ?? '',
      destination: json['destination'] ?? '',
    );
  }

  /// Convert to LatLng for use with the map
  LatLng get position => LatLng(latitude, longitude);
}

/// Simple LatLng class to avoid depending on specific map implementations
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}
