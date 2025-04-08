import 'dart:math' as math;

import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

import '../../domain/models/bus_stop_model.dart';
import '../providers/bus_providers.dart';
import '../utils/map_markers_manager.dart';
import '../widgets/map_bottom_sheet.dart';
import '../widgets/map_location_button.dart';
import '../widgets/map_overlay_gradient.dart';

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
  late AnimationController _bottomSheetController;
  late Animation<double> _bottomSheetAnimation;
  
  // Track if the map is being actively dragged
  bool _isMapMoving = false;
  bool _isCursorDetectionActive = true;
  
  // Track map position and state
  LatLng _currentMapCenter = _initialPosition;
  double _currentZoom = AppDimensions.mapInitialZoom;

  // Default map position and zoom
  static const LatLng _initialPosition = LatLng(37.7749, -122.4194);

  @override
  void initState() {
    super.initState();
    // Initialize controllers for animations
    _mapFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationShort),
    );

    _bottomSheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
    );

    _bottomSheetAnimation = CurvedAnimation(
      parent: _bottomSheetController,
      curve: Curves.easeOutExpo,
      reverseCurve: Curves.easeInExpo,
    );

    // Load bus stop data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(busScheduleProvider.notifier).loadBusStops();
    });
  }

  @override
  void dispose() {
    _mapFadeController.dispose();
    _bottomSheetController.dispose();
    super.dispose();
  }

  // Handle marker tap with bus stop selection
  void _onMarkerTap(BusStop busStop) {
    HapticFeedback.lightImpact();
    
    // Check if we're tapping the same bus stop with closed bottom sheet
    final currentSelectedStop = ref.read(busScheduleProvider).selectedBusStop;
    final isBottomSheetOpen = ref.read(busScheduleProvider).isBottomSheetOpen;
    
    if (currentSelectedStop?.id == busStop.id && !isBottomSheetOpen) {
      // If same bus stop with closed sheet, just open the sheet
      ref.read(busScheduleProvider.notifier).openBottomSheet();
    } else {
      // Otherwise select the new bus stop (or refresh same one)
      ref.read(busScheduleProvider.notifier).selectBusStop(busStop);
    }
    
    // First start opening the bottom sheet smoothly
    _bottomSheetController.forward();
    _mapFadeController.forward();
    
    // Then animate the map to keep the bus stop visible above the sheet
    _animateToStop(busStop);
  }

  // Animate map camera to the selected bus stop
  void _animateToStop(BusStop busStop) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          // Center the bus stop in the visible portion of the map
          target: LatLng(busStop.latitude, busStop.longitude),
          zoom: AppDimensions.mapDetailedZoom,
          // Apply a small tilt to improve visibility
          tilt: 10.0,
        ),
      ),
    );
  }

  // Check if center of map is over a bus stop
  void _checkForBusStopAtCenter() async {
    if (_mapController == null || !_isCursorDetectionActive) return;

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
          
          // If we're not showing a bottom sheet or showing a different stop
          if (!busScheduleState.isBottomSheetOpen || 
              busScheduleState.selectedBusStop?.id != busStop.id) {
            ref.read(busScheduleProvider.notifier).selectBusStop(busStop);
            _bottomSheetController.forward();
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

  @override
  Widget build(BuildContext context) {
    final busScheduleState = ref.watch(busScheduleProvider);
    final busStops = busScheduleState.busStops;
    final isBottomSheetOpen = busScheduleState.isBottomSheetOpen;
    final selectedBusStop = busScheduleState.selectedBusStop;
    final status = busScheduleState.status;
    final busSchedules = busScheduleState.busSchedules;

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Create markers when bus stops are loaded
    if (status == BusScheduleStateStatus.loaded &&
        _markers.isEmpty &&
        busStops.isNotEmpty) {
      Future.sync(() async {
        // Create markers for bus stops
        final markers = await MapMarkersManager.createMarkers(
          busStops: busStops,
          onMarkerTap: _onMarkerTap,
        );
        
        setState(() {
          _markers = markers;
        });
      });
    }

    // Update bottom sheet animation to match state changes
    if (isBottomSheetOpen && _bottomSheetController.status != AnimationStatus.completed) {
      _bottomSheetController.forward();
    } else if (!isBottomSheetOpen && _bottomSheetController.status != AnimationStatus.dismissed) {
      _bottomSheetController.reverse();
      _mapFadeController.reverse();
    }

    return Scaffold(
      body: Stack(
        children: [
          // Full-size map that stays rendered when the sheet appears
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: PlatformMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: AppDimensions.mapInitialZoom,
              ),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              markers: _markers,
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                });
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
          ),

          // Target cursor in center of screen - always centered
          const Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: AppDimensions.iconSizeMedium,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 2),
                  SizedBox(
                    width: 1.5,
                    height: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Map overlay gradient
          MapOverlayGradient(fadeAnimation: _mapFadeController),

          // Bottom sheet
          MapBottomSheet(
            animation: _bottomSheetAnimation,
            selectedBusStop: selectedBusStop,
            isBottomSheetOpen: isBottomSheetOpen,
            status: status,
            busSchedules: busSchedules,
            earliestTimes: busScheduleState.getEarliestArrivalTimes(),
            onClose: () {
              _mapFadeController.reverse();
            },
          ),

          // My location button
          MapLocationButton(
            mapController: _mapController,
            initialPosition: _initialPosition,
            initialZoom: AppDimensions.mapInitialZoom,
            isBottomSheetOpen: isBottomSheetOpen,
          ),
        ],
      ),
    );
  }
}