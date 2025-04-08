import 'dart:math' as math;

import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/domain/models/bus_schedule_model.dart';
import 'package:busnow/presentation/widgets/animated_loading_indicator.dart';
import 'package:busnow/presentation/widgets/bus_refresh_button.dart';
import 'package:busnow/presentation/widgets/bus_schedule_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

import '../../domain/models/bus_stop_model.dart';
import '../providers/bus_providers.dart';
import '../utils/map_markers_manager.dart';
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
  
  // Track if the map is being actively dragged
  bool _isMapMoving = false;
  bool _isCursorDetectionActive = true;
  
  // Track map position and state
  LatLng _currentMapCenter = _initialPosition;
  double _currentZoom = AppDimensions.mapInitialZoom;

  // Default map position and zoom
  static const LatLng _initialPosition = LatLng(37.7749, -122.4194);

  // Fixed size for bottom sheet (percentage of screen height)
  final double _bottomSheetHeightRatio = 0.4; // 40% of screen height

  @override
  void initState() {
    super.initState();
    // Initialize controllers for animations
    _mapFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationShort),
    );

    // Load bus stop data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(busScheduleProvider.notifier).loadBusStops();
    });
  }

  @override
  void dispose() {
    _mapFadeController.dispose();
    super.dispose();
  }

  // Handle marker tap with bus stop selection
  void _onMarkerTap(BusStop busStop) {
    HapticFeedback.lightImpact();
    
    // Select the bus stop
    ref.read(busScheduleProvider.notifier).selectBusStop(busStop);
    
    // Highlight the map with gradient
    _mapFadeController.forward();
    
    // Animate the map to keep the bus stop visible above the sheet
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
      const double detectionRadiusInDegrees = 0.005;
      
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
    final selectedBusStop = busScheduleState.selectedBusStop;
    final status = busScheduleState.status;
    final busSchedules = busScheduleState.busSchedules;

    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate fixed heights
    final double bottomSheetHeight = screenSize.height * _bottomSheetHeightRatio;
    final double mapHeight = screenSize.height - bottomSheetHeight;

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

    return Scaffold(
      body: Column(
        children: [
          // Map area with fixed height
          SizedBox(
            width: screenSize.width,
            height: mapHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // The map view
                PlatformMap(
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

                // My location button
                Positioned(
                  right: AppDimensions.spacingMedium,
                  bottom: AppDimensions.spacingExtraLarge,
                  child: MapLocationButton(
                    mapController: _mapController,
                    initialPosition: _initialPosition,
                    initialZoom: AppDimensions.mapInitialZoom,
                    isBottomSheetOpen: false,
                  ),
                ),
              ],
            ),
          ),

          // Fixed bottom sheet
          Container(
            height: bottomSheetHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.borderRadiusLarge),
                topRight: Radius.circular(AppDimensions.borderRadiusLarge),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackWithOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Pull handle indicator (purely decorative now)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: AppDimensions.spacingMedium - 4,
                      bottom: AppDimensions.spacingMedium,
                    ),
                    width: AppDimensions.pullHandleWidth,
                    height: AppDimensions.pullHandleHeight,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusSmall / 2,
                      ),
                    ),
                  ),
                ),
                
                // Content area - either shows instructions or selected bus stop info
                Expanded(
                  child: selectedBusStop == null
                      ? _buildNoSelectionState(theme)
                      : _buildSelectedBusStopContent(
                          selectedBusStop, 
                          status, 
                          busSchedules, 
                          theme,
                          busScheduleState.getEarliestArrivalTimes(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for when no bus stop is selected
  Widget _buildNoSelectionState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.touch_app_rounded,
              size: AppDimensions.iconSizeLarge,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text(
              "Tap on a bus stop to see schedules",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget for selected bus stop content
  Widget _buildSelectedBusStopContent(
    BusStop selectedBusStop,
    BusScheduleStateStatus status,
    List<BusSchedule> busSchedules,
    ThemeData theme,
    Map<String, int> earliestTimes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bus stop name and info
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingLarge,
            0, // Reduced top padding as we already have the handle above
            AppDimensions.spacingLarge,
            AppDimensions.spacingMedium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedBusStop.name,
                  style: theme.textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Refresh button
              BusRefreshButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(busScheduleProvider.notifier).refreshBusSchedules();
                },
                isLoading: status == BusScheduleStateStatus.loading,
              ),
            ],
          ),
        ),

        // Bus schedule list or loading indicator
        Expanded(
          child: status == BusScheduleStateStatus.loading
              ? const Center(
                  child: AnimatedLoadingIndicator(),
                )
              : busSchedules.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildBusScheduleList(busSchedules, earliestTimes),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_bus_outlined,
            size: AppDimensions.iconSizeExtraLarge,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            "No buses yet—check back soon!",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBusScheduleList(
    List<BusSchedule> busSchedules, 
    Map<String, int> earliestTimes
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMedium,
        0, // No top padding needed
        AppDimensions.spacingMedium,
        AppDimensions.spacingMedium,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: busSchedules.length,
      itemBuilder: (context, index) {
        final schedule = busSchedules[index];
        final isEarliest =
            earliestTimes[schedule.busNumber] == schedule.arrivalTimeInMinutes;

        // Add staggered animation for items
        return AnimatedBuilder(
          animation: AlwaysStoppedAnimation(
            1.0 - (index * 0.1).clamp(0.0, 1.0),
          ),
          builder: (context, child) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(
                milliseconds: AppDimensions.animDurationMedium + (index * 50),
              ),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.spacingSmall,
                ),
                child: BusScheduleItem(
                  schedule: schedule,
                  isEarliest: isEarliest,
                ),
              ),
            );
          },
        );
      },
    );
  }
}