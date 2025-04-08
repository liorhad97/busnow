import 'dart:math' as math;
import 'dart:ui';

import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/presentation/widgets/map_bottom_sheet.dart';
import 'package:busnow/presentation/widgets/map_center_cursor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/models/bus_stop_model.dart';
import '../providers/bus_providers.dart';
import '../utils/map_markers_manager.dart';
import '../widgets/map_overlay_gradient.dart';
import '../widgets/animated_map_controls.dart';

class BusMapScreen extends ConsumerStatefulWidget {
  const BusMapScreen({super.key});

  @override
  ConsumerState<BusMapScreen> createState() => _BusMapScreenState();
}

class _BusMapScreenState extends ConsumerState<BusMapScreen>
    with TickerProviderStateMixin {
  PlatformMapController? _mapController;
  Set<Marker> _markers = {};
  late AnimationController _mapFadeController;
  late AnimationController _markerPulseController;
  late AnimationController _bottomSheetController;
  
  // Track if the map is being actively dragged
  bool _isMapMoving = false;
  bool _isCursorDetectionActive = true;
  
  // Track map position and state
  LatLng _currentMapCenter = const LatLng(0, 0);
  double _currentZoom = AppDimensions.mapInitialZoom;

  // Default map position as fallback
  static const LatLng _defaultPosition = LatLng(37.7749, -122.4194);

  // For tracking user location permissions status
  bool _locationPermissionChecked = false;
  LocationPermission? _locationPermission;
  LatLng? _userLocation;
  
  // For bottom sheet interactions
  final double _collapsedSheetHeight = 120.0;
  final double _expandedSheetHeight = 0.45; // 45% of screen (reduced from 50%)
  bool _isBottomSheetExpanded = false;

  // Flag to track if we've already navigated to closest stop on startup
  bool _initialNavigationPerformed = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers for various animations
    _mapFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
    );
    
    _markerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationLoading),
    )..repeat(reverse: true);
    
    _bottomSheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
      value: 0.0,
    );

    // Check location permissions when the app starts
    _checkLocationPermission();

    // Load bus stop data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(busScheduleProvider.notifier).loadBusStops();
      
      // Set up a listener to monitor when bus stops are loaded
      ref.listenManual(busScheduleProvider, (previous, next) {
        if (previous?.status != BusScheduleStateStatus.loaded && 
            next.status == BusScheduleStateStatus.loaded &&
            next.busStops.isNotEmpty) {
          // Bus stops have been loaded, so we can try to navigate
          _initializeMapAndNavigate();
        }
      });
    });
  }

  @override
  void dispose() {
    _mapFadeController.dispose();
    _markerPulseController.dispose();
    _bottomSheetController.dispose();
    super.dispose();
  }

  /// Check location permission and get initial position
  Future<void> _checkLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationPermissionChecked = true;
          _locationPermission = LocationPermission.denied;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Request permission with beautiful UI prompt
        _showLocationPermissionDialog();
        permission = await Geolocator.requestPermission();
      }
      
      setState(() {
        _locationPermissionChecked = true;
        _locationPermission = permission;
      });
      
      // If we have permission, get the user's location
      if (permission == LocationPermission.always || 
          permission == LocationPermission.whileInUse) {
        _getUserLocation();
      }
    } catch (e) {
      print('Error checking location permission: $e');
      setState(() {
        _locationPermissionChecked = true;
        _locationPermission = LocationPermission.denied;
      });
    }
  }

  /// Show an elegant location permission dialog
  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Location'),
        content: const Text(
          'BusNow needs your location to show nearby bus stops and provide accurate arrival times.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
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
  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _currentMapCenter = _userLocation!;
      });
      
      // If map controller is already initialized, move to user location
      if (_mapController != null && _userLocation != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _userLocation!,
              zoom: AppDimensions.mapInitialZoom,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  // Coordinate the initial navigation to closest bus stop
  Future<void> _initializeMapAndNavigate() async {
    // If we've already performed the initial navigation, don't do it again
    if (_initialNavigationPerformed) return;
    
    // Make sure we have bus stops, map controller, and user location
    final busScheduleState = ref.read(busScheduleProvider);
    final busStops = busScheduleState.busStops;
    
    if (_mapController == null || _userLocation == null || busStops.isEmpty) return;
    
    // Set flag to prevent duplicate navigations
    _initialNavigationPerformed = true;
    
    try {
      // Move to user location first
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _userLocation!,
            zoom: AppDimensions.mapDetailedZoom,
          ),
        ),
      );
      
      // Wait for the map to settle
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Find and navigate to closest bus stop
      await _navigateToClosestBusStop();
    } catch (e) {
      print('Error during initial navigation: $e');
    }
  }

  // Navigate to the closest bus stop automatically
  Future<void> _navigateToClosestBusStop() async {
    if (_mapController == null || _userLocation == null) return;
    
    try {
      // Find closest bus stop to current location
      final closestBusStop = await _findClosestBusStop(_userLocation!);
      
      // If found, select it and show its schedule
      if (closestBusStop != null) {
        // Add a short delay for better UX
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Select the bus stop
        ref.read(busScheduleProvider.notifier).selectBusStop(closestBusStop);
        
        // Show the bottom sheet with the bus schedule
        _expandBottomSheet();
        
        // Highlight the map with gradient
        _mapFadeController.forward();
        
        // Animate the map to keep both user location and bus stop visible
        _animateToStop(closestBusStop);
        
        // Provide haptic feedback to indicate success
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      print('Error navigating to closest bus stop: $e');
    }
  }

  // Handle marker tap with bus stop selection
  void _onMarkerTap(BusStop busStop) {
    HapticFeedback.mediumImpact();
    
    // Select the bus stop
    ref.read(busScheduleProvider.notifier).selectBusStop(busStop);
    
    // Animate sheet and map adjustments
    _expandBottomSheet();
    
    // Highlight the map with gradient
    _mapFadeController.forward();
    
    // Animate the map to keep the bus stop visible above the sheet
    _animateToStop(busStop);
  }

  // Show or hide the bottom sheet with animation
  void _expandBottomSheet() {
    setState(() {
      _isBottomSheetExpanded = true;
    });
    _bottomSheetController.forward();
  }

  void _collapseBottomSheet() {
    setState(() {
      _isBottomSheetExpanded = false;
    });
    _bottomSheetController.reverse();
  }

  // Animate map camera to the selected bus stop
  void _animateToStop(BusStop busStop) {
    // Calculate offset to account for bottom sheet
    final screenHeight = MediaQuery.of(context).size.height;
    final visibleAreaRatio = 1.0 - (_expandedSheetHeight * _bottomSheetController.value);
    final visibleMapHeight = screenHeight * visibleAreaRatio;
    
    // Calculate target point that accounts for bottom sheet coverage
    final targetPosition = LatLng(
      busStop.latitude - (0.0015 * _bottomSheetController.value), // Slight offset upward
      busStop.longitude,
    );
    
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: targetPosition,
          zoom: AppDimensions.mapDetailedZoom,
          // Apply a gentle tilt for visual interest
          tilt: 10 + (20 * _bottomSheetController.value),
          bearing: 0 + (15 * _bottomSheetController.value), // Slight rotation
        ),
      ),
    );
  }

  // Check if center of map is over a bus stop
  void _checkForBusStopAtCenter() async {
    if (_mapController == null || !_isCursorDetectionActive || _isBottomSheetExpanded) return;

    final busScheduleState = ref.read(busScheduleProvider);
    final busStops = busScheduleState.busStops;
    if (busStops.isEmpty) return;

    try {
      // Use the tracked center position
      final center = _currentMapCenter;
      
      // Define search radius (approximately 50 meters)
      const double detectionRadiusInDegrees = 0.0005;
      
      // Check if center is near any bus stop
      for (final busStop in busStops) {
        final double distance = _calculateDistance(
          center.latitude, 
          center.longitude,
          busStop.latitude,
          busStop.longitude,
        );
        
        if (distance < detectionRadiusInDegrees) {
          HapticFeedback.selectionClick();
          
          // Only select if it's a different bus stop
          if (busScheduleState.selectedBusStop?.id != busStop.id) {
            ref.read(busScheduleProvider.notifier).selectBusStop(busStop);
            _expandBottomSheet();
            _mapFadeController.forward();
          }
          
          return; // Found a match, exit
        }
      }
    } catch (e) {
      // Ignore errors from map controller
    }
  }
  
  // Calculate distance between two coordinates (simplified)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return math.sqrt(math.pow(lat2 - lat1, 2) + math.pow(lon2 - lon1, 2));
  }
  
  // Find the closest bus stop to a given location, but only considering visible bus stops
  Future<BusStop?> _findClosestBusStop(LatLng location) async {
    if (_mapController == null) return null;
    
    final busScheduleState = ref.read(busScheduleProvider);
    final busStops = busScheduleState.busStops;
    
    if (busStops.isEmpty) return null;
    
    // Get the visible region bounds from the map controller
    final visibleRegion = await _mapController!.getVisibleRegion();
    
    // Filter bus stops to only those visible on screen
    final visibleBusStops = busStops.where((busStop) {
      // Check if bus stop is within the visible region
      final isVisible = _isLocationVisible(
        LatLng(busStop.latitude, busStop.longitude),
        visibleRegion
      );
      return isVisible;
    }).toList();
    
    // If no visible bus stops, return null
    if (visibleBusStops.isEmpty) return null;
    
    BusStop? closest;
    double minDistance = double.infinity;
    
    // Only calculate distances for visible bus stops
    for (final busStop in visibleBusStops) {
      final distance = _calculateDistance(
        location.latitude,
        location.longitude,
        busStop.latitude,
        busStop.longitude
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        closest = busStop;
      }
    }
    
    return closest;
  }
  
  // Check if a location is within the visible region
  bool _isLocationVisible(LatLng location, LatLngBounds visibleRegion) {
    final ne = visibleRegion.northeast;
    final sw = visibleRegion.southwest;
    
    return location.latitude <= ne.latitude &&
           location.latitude >= sw.latitude &&
           location.longitude <= ne.longitude &&
           location.longitude >= sw.longitude;
  }

  @override
  Widget build(BuildContext context) {
    final busScheduleState = ref.watch(busScheduleProvider);
    final busStops = busScheduleState.busStops;
    final selectedBusStop = busScheduleState.selectedBusStop;
    final status = busScheduleState.status;
    final busSchedules = busScheduleState.busSchedules;

    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Determine the initial camera position based on user location or default
    final initialCameraPosition = CameraPosition(
      target: _userLocation ?? _defaultPosition,
      zoom: AppDimensions.mapInitialZoom,
    );

    // Create markers when bus stops are loaded
    if (status == BusScheduleStateStatus.loaded &&
        _markers.isEmpty &&
        busStops.isNotEmpty) {
      Future.sync(() async {
        // Create markers for bus stops
        final markers = await MapMarkersManager.createMarkers(
          busStops: busStops,
          animationController: _markerPulseController,
          onMarkerTap: _onMarkerTap,
        );
        
        setState(() {
          _markers = markers;
        });
      });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: theme.colorScheme.surface,
      ),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // The map view
            PlatformMap(
              initialCameraPosition: initialCameraPosition,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              markers: _markers,
              onMapCreated: (controller) async {
                setState(() {
                  _mapController = controller;
                });
                
                // If we already have user location, move the camera there
                if (_userLocation != null) {
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: _userLocation!,
                        zoom: AppDimensions.mapInitialZoom,
                      ),
                    ),
                  );
                  
                  // Added auto-navigation to closest bus stop on app start
                  // Wait for the map to settle
                  await Future.delayed(const Duration(milliseconds: 800));
                  
                  // Coordinate the initial navigation
                  await _initializeMapAndNavigate();
                }
              },
              onCameraMove: (CameraPosition position) {
                _isMapMoving = true;
                _currentMapCenter = position.target;
                _currentZoom = position.zoom;
              },
              onCameraIdle: () {
                _isMapMoving = false;
                _checkForBusStopAtCenter();
              },
            ),

            // Target cursor in center of screen - only shown when bottom sheet is not expanded
            if (!_isBottomSheetExpanded) 
              MapCenterCursor(isMapMoving: _isMapMoving),

            // Map overlay gradient
            MapOverlayGradient(fadeAnimation: _mapFadeController),

            // Floating map controls (right side)
            Positioned(
              right: AppDimensions.spacingMedium,
              bottom: _isBottomSheetExpanded 
                ? screenSize.height * _expandedSheetHeight + AppDimensions.spacingMedium
                : AppDimensions.spacingExtraLarge,
              child: AnimatedMapControls(
                mapController: _mapController,
                userLocation: _userLocation ?? _defaultPosition,
                onZoomIn: () {
                  if (_mapController != null && _currentZoom < 20) {
                    _mapController!.animateCamera(
                      CameraUpdate.zoomIn(),
                    );
                  }
                },
                onZoomOut: () {
                  if (_mapController != null && _currentZoom > 5) {
                    _mapController!.animateCamera(
                      CameraUpdate.zoomOut(),
                    );
                  }
                },
                onLocate: () async {
                  if (_userLocation == null) {
                    await _getUserLocation();
                  }
                  
                  if (_mapController != null && _userLocation != null) {
                    // First zoom to user location
                    _mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _userLocation!,
                          zoom: AppDimensions.mapDetailedZoom,
                        ),
                      ),
                    );
                    
                    // Reset bottom sheet state initially
                    if (_isBottomSheetExpanded) {
                      _collapseBottomSheet();
                      _mapFadeController.reverse();
                    }
                    // make a delay to allow the map to settle
                    await Future.delayed(const Duration(milliseconds: 500));
                    // Find closest bus stop to current location
                    final closestBusStop = await _findClosestBusStop(_userLocation!);
                    
                    // If found, select it and show its schedule
                    if (closestBusStop != null) {
                      // Add a slight delay for better UX (let the user see their location first)
                      await Future.delayed(const Duration(milliseconds: 300));
                      
                      // Select the bus stop
                      ref.read(busScheduleProvider.notifier).selectBusStop(closestBusStop);
                      
                      // Show the bottom sheet with the bus schedule
                      _expandBottomSheet();
                      
                      // Highlight the map with gradient
                      _mapFadeController.forward();
                      
                      // Animate the map to keep both user location and bus stop visible
                      _animateToStop(closestBusStop);
                      
                      // Provide haptic feedback to indicate success
                      HapticFeedback.mediumImpact();
                    }
                  }
                },
              ),
            ),

            // Bottom sheet with custom implementation
            AnimatedBuilder(
              animation: _bottomSheetController,
              builder: (context, child) {
                final height = _collapsedSheetHeight + 
                  (_bottomSheetController.value * (screenSize.height * _expandedSheetHeight - _collapsedSheetHeight));
                  
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: _bottomSheetController.value > 0 ? height : 0,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      // Convert drag to animation value
                      final newValue = _bottomSheetController.value - 
                        (details.primaryDelta! / ((screenSize.height * _expandedSheetHeight) - _collapsedSheetHeight));
                      _bottomSheetController.value = newValue.clamp(0.0, 1.0);
                    },
                    onVerticalDragEnd: (details) {
                      if (details.primaryVelocity! > 500 || _bottomSheetController.value < 0.3) {
                        _collapseBottomSheet();
                      } else if (details.primaryVelocity! < -500 || _bottomSheetController.value > 0.7) {
                        _expandBottomSheet();
                      } else {
                        if (_bottomSheetController.value > 0.5) {
                          _expandBottomSheet();
                        } else {
                          _collapseBottomSheet();
                        }
                      }
                    },
                    child: EnhancedBottomSheet(
                      animation: _bottomSheetController,
                      selectedBusStop: selectedBusStop,
                      status: status,
                      busSchedules: busSchedules,
                      earliestTimes: busScheduleState.getEarliestArrivalTimes(),
                      onClose: () {
                        _collapseBottomSheet();
                        _mapFadeController.reverse();
                      },
                      onRefresh: () {
                        ref.read(busScheduleProvider.notifier).refreshBusSchedules();
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
    }

