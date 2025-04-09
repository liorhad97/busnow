import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/domain/models/bus_stop_model.dart';

/// A mixin for handling map control functionality
///
/// This mixin handles the complex logic for map manipulation including:
/// - Location permissions and current location detection
/// - Map controller initialization and camera movements
/// - Distance calculations and bus stop detection
/// - Map region and visible location utilities
mixin MapControllerMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin {
  // The map controller reference
  PlatformMapController? mapController;
  
  // Animation controllers that need to be initialized
  late AnimationController mapFadeController;
  late AnimationController markerPulseController;
  
  // Map state tracking
  bool isMapMoving = false;
  bool isCursorDetectionActive = true;
  LatLng currentMapCenter = const LatLng(0, 0);
  double currentZoom = AppDimensions.mapInitialZoom;
  
  // Default map position as fallback
  static const LatLng defaultPosition = LatLng(37.7749, -122.4194);
  
  // For tracking user location permissions status
  bool locationPermissionChecked = false;
  LocationPermission? locationPermission;
  LatLng? userLocation;
  
  /// Initialize map-related controllers
  void initializeMapControllers() {
    mapFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
    );
    
    markerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationLoading),
    )..repeat(reverse: true);
  }
  
  /// Dispose map-related controllers
  void disposeMapControllers() {
    mapFadeController.dispose();
    markerPulseController.dispose();
  }
  
  /// Initialize location services and check for permissions
  Future<void> initializeLocationServices() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          locationPermissionChecked = true;
          locationPermission = LocationPermission.denied;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission with beautiful UI prompt
        showLocationPermissionDialog(context);
        permission = await Geolocator.requestPermission();
      }

      setState(() {
        locationPermissionChecked = true;
        locationPermission = permission;
      });

      // If we have permission, get the user's location
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        getUserLocation();
      }
    } catch (e) {
      print('Error checking location permission: $e');
      setState(() {
        locationPermissionChecked = true;
        locationPermission = LocationPermission.denied;
      });
    }
  }
  
  /// Show an elegant location permission dialog
  void showLocationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Location'),
        content: const Text(
          'BusNow needs your location to show nearby bus stops and provide accurate arrival times.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.borderRadiusMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not Now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Permission request will happen after this dialog closes
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
  
  /// Get user's current location
  Future<void> getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        currentMapCenter = userLocation!;
      });

      // If map controller is already initialized, move to user location
      if (mapController != null && userLocation != null) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: userLocation!,
              zoom: AppDimensions.mapInitialZoom,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error getting user location: $e');
    }
  }
  
  /// Animate map camera to a specific bus stop
  void animateToStop(BusStop busStop, double bottomSheetValue) {
    // Calculate offset to account for bottom sheet
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Use the provided bottom sheet value to calculate offset
    final targetPosition = LatLng(
      busStop.latitude - (0.0015 * bottomSheetValue), // Slight offset upward
      busStop.longitude,
    );

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: targetPosition,
          zoom: AppDimensions.mapDetailedZoom,
          // Apply a gentle tilt for visual interest
          tilt: 10 + (20 * bottomSheetValue),
          bearing: 0 + (15 * bottomSheetValue), // Slight rotation
        ),
      ),
    );
  }
  
  /// Calculate distance between two coordinates using the Haversine formula
  /// Returns distance in meters
  double calculateDistanceInMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Earth's radius in meters

    // Convert degrees to radians
    final double lat1Rad = lat1 * (math.pi / 180);
    final double lon1Rad = lon1 * (math.pi / 180);
    final double lat2Rad = lat2 * (math.pi / 180);
    final double lon2Rad = lon2 * (math.pi / 180);

    // Haversine formula
    final double dLat = lat2Rad - lat1Rad;
    final double dLon = lon2Rad - lon1Rad;
    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }
  
  /// Find the closest bus stop to a given location within the visible map region
  Future<BusStop?> findClosestBusStop(LatLng location, List<BusStop> busStops) async {
    if (mapController == null || busStops.isEmpty) return null;

    // Get the visible region bounds from the map controller
    final visibleRegion = await mapController!.getVisibleRegion();

    // Filter bus stops to only those visible on screen
    final visibleBusStops = busStops.where((busStop) {
      return isLocationVisible(
        LatLng(busStop.latitude, busStop.longitude),
        visibleRegion,
      );
    }).toList();

    // If no visible bus stops, return null
    if (visibleBusStops.isEmpty) return null;

    BusStop? closest;
    double minDistance = double.infinity;

    // Only calculate distances for visible bus stops
    for (final busStop in visibleBusStops) {
      final distance = calculateDistanceInMeters(
        location.latitude,
        location.longitude,
        busStop.latitude,
        busStop.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closest = busStop;
      }
    }

    return closest;
  }
  
  /// Check if a location is within the visible map region
  bool isLocationVisible(LatLng location, LatLngBounds visibleRegion) {
    final ne = visibleRegion.northeast;
    final sw = visibleRegion.southwest;

    return location.latitude <= ne.latitude &&
        location.latitude >= sw.latitude &&
        location.longitude <= ne.longitude &&
        location.longitude >= sw.longitude;
  }
}
