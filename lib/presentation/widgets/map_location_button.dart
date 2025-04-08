import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapLocationButton extends StatefulWidget {
  final PlatformMapController? mapController;
  final LatLng initialPosition;
  final double initialZoom;
  final bool isBottomSheetOpen;

  const MapLocationButton({
    super.key,
    required this.mapController,
    required this.initialPosition,
    required this.initialZoom,
    required this.isBottomSheetOpen,
  });

  @override
  State<MapLocationButton> createState() => _MapLocationButtonState();
}

class _MapLocationButtonState extends State<MapLocationButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FloatingActionButton(
      onPressed: _isLoading ? null : _navigateToUserLocation,
      backgroundColor: theme.colorScheme.primary,
      child: _isLoading 
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : const Icon(Icons.my_location, color: Colors.white),
    );
  }

  /// Navigate to the user's current location
  Future<void> _navigateToUserLocation() async {
    if (widget.mapController == null) return;
    
    setState(() => _isLoading = true);
    HapticFeedback.selectionClick();
    
    try {
      // First, check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        _showLocationError('Location services are disabled. Please enable location services in your device settings.');
        return;
      }
      
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions denied
          _showLocationError('Location permissions are denied');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Permissions permanently denied
        _showLocationError(
          'Location permissions are permanently denied. Please enable location permissions in app settings.'
        );
        return;
      }
      
      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Animate the camera to the user's location
      widget.mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: widget.initialZoom,
          ),
        ),
      );
    } catch (e) {
      _showLocationError('Error accessing location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  /// Show a location error message
  void _showLocationError(String message) {
    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}