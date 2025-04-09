import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/domain/models/bus_stop_model.dart';
import 'package:busnow/presentation/mixins/bottom_sheet_controller_mixin.dart';
import 'package:busnow/presentation/mixins/map_controller_mixin.dart';
import 'package:busnow/presentation/providers/bus_providers.dart';
import 'package:busnow/presentation/utils/map/bus_stop_detector.dart';
import 'package:busnow/presentation/utils/map_markers_manager.dart';
import 'package:busnow/presentation/screens/bus_map/map_view.dart';
import 'package:busnow/presentation/screens/bus_map/bottom_sheet_view.dart';
import 'package:busnow/presentation/screens/bus_map/map_controls_view.dart';

/// The main map screen where users can see bus stops and their schedules
/// 
/// This screen shows a map with bus stop markers, and allows users to:
/// - View their current location
/// - See nearby bus stops
/// - View bus schedules in a bottom sheet
/// - Zoom and pan the map
class BusMapScreen extends ConsumerStatefulWidget {
  const BusMapScreen({super.key});

  @override
  ConsumerState<BusMapScreen> createState() => _BusMapScreenState();
}

class _BusMapScreenState extends ConsumerState<BusMapScreen>
    with TickerProviderStateMixin, MapControllerMixin, BottomSheetControllerMixin {
  
  // Bus stop markers
  Set<Marker> _markers = {};
  
  // Flag to track if we've already navigated to closest stop on startup
  bool _initialNavigationPerformed = false;
  
  // For bus stop detection
  late BusStopDetector _busStopDetector;

  @override
  void initState() {
    super.initState();
    
    // Initialize map controllers
    initializeMapControllers();
    
    // Initialize bottom sheet controller
    initializeBottomSheetController();
    
    // Initialize bus stop detector
    _busStopDetector = BusStopDetector(
      calculateDistance: calculateDistanceInMeters,
    );
    
    // Check location permissions when the app starts
    initializeLocationServices();

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
    disposeMapControllers();
    disposeBottomSheetController();
    super.dispose();
  }

  // Coordinate the initial navigation to closest bus stop
  Future<void> _initializeMapAndNavigate() async {
    // If we've already performed the initial navigation, don't do it again
    if (_initialNavigationPerformed) return;

    // Make sure we have bus stops, map controller, and user location
    final busScheduleState = ref.read(busScheduleProvider);
    final busStops = busScheduleState.busStops;

    if (mapController == null || userLocation == null || busStops.isEmpty) {
      return;
    }

    // Set flag to prevent duplicate navigations
    _initialNavigationPerformed = true;

    try {
      // Move to user location first
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: userLocation!,
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
    if (mapController == null || userLocation == null) return;

    try {
      // Find closest bus stop to current location
      final busStops = ref.read(busScheduleProvider).busStops;
      final closestBusStop = await findClosestBusStop(userLocation!, busStops);

      // If found, select it and show its schedule
      if (closestBusStop != null) {
        // Add a short delay for better UX
        await Future.delayed(const Duration(milliseconds: 300));

        // Select the bus stop
        ref.read(busScheduleProvider.notifier).selectBusStop(closestBusStop);

        // Show the bottom sheet with the bus schedule
        expandBottomSheet();

        // Highlight the map with gradient
        mapFadeController.forward();

        // Animate the map to keep both user location and bus stop visible
        animateToStop(closestBusStop, bottomSheetController.value);

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

    // Expand the bottom sheet
    expandBottomSheet();

    // Highlight the map with gradient
    mapFadeController.forward();

    // Animate the map to keep the bus stop visible above the sheet
    animateToStop(busStop, bottomSheetController.value);
  }

  // Check if center of map is over a bus stop
  void _checkForBusStopAtCenter() async {
    if (mapController == null || !isCursorDetectionActive || isBottomSheetExpanded) {
      return;
    }

    final busScheduleState = ref.read(busScheduleProvider);
    final busStops = busScheduleState.busStops;
    if (busStops.isEmpty) return;

    try {
      // Find all bus stops within the detection radius
      final nearbyStops = _busStopDetector.findNearbyStops(currentMapCenter, busStops);
      
      // If we found nearby stops, select them
      if (nearbyStops.isNotEmpty) {
        HapticFeedback.selectionClick();

        // Check if these are different from the current selection
        final current = busScheduleState.nearbyBusStops;
        final areDifferent = _busStopDetector.areStopsDifferent(current, nearbyStops);

        if (areDifferent) {
          // Load schedules for all nearby stops
          ref.read(busScheduleProvider.notifier).selectNearbyBusStops(nearbyStops);

          // Show bottom sheet and gradient
          expandBottomSheet();
          mapFadeController.forward();

          // Animate to the closest one
          animateToStop(nearbyStops.first, bottomSheetController.value);
        }
      }
    } catch (e) {
      print('Error in bus stop detection: $e');
    }
  }

  // Reset the UI and reload the map state - performs a complete app reset
  void _refreshScreen() async {
    HapticFeedback.mediumImpact();

    // Completely dispose and restart all animation controllers
    mapFadeController.dispose();
    markerPulseController.dispose();
    bottomSheetController.dispose();

    // Re-create controllers from scratch
    initializeMapControllers();
    initializeBottomSheetController();

    // Clear cached data in the provider before UI updates
    ref.read(busScheduleProvider.notifier).reset();

    // Reset all state variables in one go
    setState(() {
      _markers = {};
      isBottomSheetExpanded = false;
      isMapMoving = false;
      isCursorDetectionActive = true;
      _initialNavigationPerformed = false;
    });

    // Force reload location data
    try {
      await getUserLocation();
    } catch (e) {
      print('Error refreshing user location: $e');
    }

    // Reload bus stops data completely
    ref.read(busScheduleProvider.notifier).loadBusStops();

    // Show a confirmation to the user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('App refreshed - Drag map to activate cursor'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
  
  // Handle the locate button press with proper behavior
  Future<void> _handleLocateButtonPress() async {
    if (userLocation == null) {
      await getUserLocation();
    }

    if (mapController != null && userLocation != null) {
      // First zoom to user location
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: userLocation!,
            zoom: AppDimensions.mapDetailedZoom,
          ),
        ),
      );

      // Reset bottom sheet state initially
      if (isBottomSheetExpanded) {
        collapseBottomSheet();
        mapFadeController.reverse();
      }
      
      // Make a delay to allow the map to settle
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Find closest bus stop to current location
      final busStops = ref.read(busScheduleProvider).busStops;
      final closestBusStop = await findClosestBusStop(userLocation!, busStops);

      // If found, select it and show its schedule
      if (closestBusStop != null) {
        // Add a slight delay for better UX (let the user see their location first)
        await Future.delayed(const Duration(milliseconds: 300));

        // Select the bus stop
        ref.read(busScheduleProvider.notifier).selectBusStop(closestBusStop);

        // Show the bottom sheet with the bus schedule
        expandBottomSheet();

        // Highlight the map with gradient
        mapFadeController.forward();

        // Animate the map to keep both user location and bus stop visible
        animateToStop(closestBusStop, bottomSheetController.value);

        // Provide haptic feedback to indicate success
        HapticFeedback.mediumImpact();
      }
    }
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

    // Create markers when bus stops are loaded
    if (status == BusScheduleStateStatus.loaded &&
        _markers.isEmpty &&
        busStops.isNotEmpty) {
      Future.sync(() async {
        // Create markers for bus stops
        final markers = await MapMarkersManager.createMarkers(
          busStops: busStops,
          animationController: markerPulseController,
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
            MapView(
              isBottomSheetExpanded: isBottomSheetExpanded,
              isMapMoving: isMapMoving,
              mapController: mapController,
              markers: _markers,
              userLocation: userLocation,
              defaultPosition: defaultPosition,
              mapFadeController: mapFadeController,
              onMapCreated: (controller) async {
                setState(() {
                  mapController = controller;
                });

                // If we already have user location, move the camera there
                if (userLocation != null) {
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: userLocation!,
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
                setState(() {
                  isMapMoving = true;
                  isCursorDetectionActive = false; // Hide cursor during movement
                });
                currentMapCenter = position.target;
                currentZoom = position.zoom;
              },
              onCameraIdle: () {
                // Only activate cursor detection when the map was being moved by user
                // and is now stopping (finger lifted)
                if (isMapMoving) {
                  setState(() {
                    isMapMoving = false;
                    isCursorDetectionActive = true; // Show cursor after finger lift
                  });
                  // Check for bus stops at the center point
                  _checkForBusStopAtCenter();
                } else {
                  setState(() {
                    isMapMoving = false;
                  });
                }
              },
            ),

            // Map controls panel
            MapControlsView(
              bottomSheetController: bottomSheetController,
              expandedSheetHeight: expandedSheetHeight,
              mapController: mapController,
              currentZoom: currentZoom,
              userLocation: userLocation ?? defaultPosition,
              onLocate: _handleLocateButtonPress,
            ),

            // Bottom sheet
            BottomSheetView(
              bottomSheetController: bottomSheetController,
              calculateSheetHeight: calculateSheetHeight,
              busScheduleState: busScheduleState,
              mapFadeController: mapFadeController,
              onCollapseBottomSheet: collapseBottomSheet,
              onDragEnd: handleBottomSheetDragEnd,
              onDragUpdate: handleBottomSheetDrag,
            ),
          ],
        ),
      ),
    );
  }
}