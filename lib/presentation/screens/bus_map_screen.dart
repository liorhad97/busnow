import 'dart:ui';

import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/core/constants/dir/icons_dir.dart';
import 'package:busnow/presentation/widgets/animated_loading_indicator.dart';
import 'package:busnow/presentation/widgets/bus_refresh_button.dart';
import 'package:busnow/presentation/widgets/bus_schedule_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

import '../../domain/models/bus_stop_model.dart';
import '../providers/bus_providers.dart';

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
  late AnimationController _markerAnimController;

  static const LatLng _initialPosition = LatLng(37.7749, -122.4194);

  @override
  void initState() {
    super.initState();
    _mapFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationShort),
    );

    _markerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationLoading),
      reverseDuration: const Duration(
        milliseconds: AppDimensions.animDurationLong,
      ),
    )..repeat(reverse: true);

    // Initialize the bus schedule data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(busScheduleProvider.notifier).loadBusStops();
    });
  }

  @override
  void dispose() {
    _mapFadeController.dispose();
    _markerAnimController.dispose();
    super.dispose();
  }

  Future<void> _createMarkers(List<BusStop> busStops) async {
    final Set<Marker> markers = {};

    for (var busStop in busStops) {
      markers.add(
        Marker(
          markerId: MarkerId(busStop.id),
          position: LatLng(busStop.latitude, busStop.longitude),
          icon:
          // BitmapDescriptor.defaultMarker,
          await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(),
            IconsDir.busStop,
          ),
          infoWindow: InfoWindow(
            title: busStop.name,
            snippet: 'Tap to see bus schedules',
          ),
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(busScheduleProvider.notifier).selectBusStop(busStop);
            _animateToStop(busStop);
            _mapFadeController.forward();
          },
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _animateToStop(BusStop busStop) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(busStop.latitude, busStop.longitude),
          zoom: AppDimensions.mapDetailedZoom,
        ),
      ),
    );
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
        await _createMarkers(busStops);
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Map as hero area
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: PlatformMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: AppDimensions.mapInitialZoom,
              ),
              mapType: isDarkMode ? MapType.normal : MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              markers: _markers,
              // Apply custom map styles based on theme
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),

          // Bottom sheet overlay gradient
          AnimatedBuilder(
            animation: _mapFadeController,
            builder: (context, child) {
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.blackWithOpacity(
                            0.1 * _mapFadeController.value,
                          ),
                          AppColors.blackWithOpacity(
                            0.3 * _mapFadeController.value,
                          ),
                        ],
                        stops: const [0.6, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Bottom Sheet
          AnimatedPositioned(
            duration: const Duration(
              milliseconds: AppDimensions.animDurationMedium,
            ),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom:
                isBottomSheetOpen
                    ? 0
                    : -MediaQuery.of(context).size.height *
                        AppDimensions.bottomSheetHeight,
            height:
                MediaQuery.of(context).size.height *
                AppDimensions.bottomSheetHeight,
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! > 500) {
                  ref.read(busScheduleProvider.notifier).closeBottomSheet();
                  _mapFadeController.reverse();
                  HapticFeedback.mediumImpact();
                }
              },
              child: Container(
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
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.borderRadiusLarge),
                    topRight: Radius.circular(AppDimensions.borderRadiusLarge),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Pull handle indicator
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(
                              top: AppDimensions.spacingMedium - 4,
                              bottom: AppDimensions.spacingSmall,
                            ),
                            width: AppDimensions.pullHandleWidth,
                            height: AppDimensions.pullHandleHeight,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusSmall / 2,
                              ),
                            ),
                          ),
                        ),

                        // Bus stop name and info
                        if (selectedBusStop != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppDimensions.spacingLarge,
                              AppDimensions.spacingMedium - 4,
                              AppDimensions.spacingLarge,
                              AppDimensions.spacingExtraSmall,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedBusStop.name,
                                    style: theme.textTheme.headlineMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Refresh button
                                BusRefreshButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    ref
                                        .read(busScheduleProvider.notifier)
                                        .refreshBusSchedules();
                                  },
                                  isLoading:
                                      status == BusScheduleStateStatus.loading,
                                ),
                              ],
                            ),
                          ),

                        // Bus schedule list
                        Expanded(
                          child:
                              status == BusScheduleStateStatus.loading
                                  ? const Center(
                                    child: AnimatedLoadingIndicator(),
                                  )
                                  : busSchedules.isEmpty
                                  ? _buildEmptyState(theme)
                                  : BusScheduleList(
                                    busSchedules: busSchedules,
                                    earliestTimes:
                                        busScheduleState
                                            .getEarliestArrivalTimes(),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // My Location Button
          Positioned(
            right: AppDimensions.spacingMedium,
            bottom:
                isBottomSheetOpen
                    ? MediaQuery.of(context).size.height *
                            AppDimensions.bottomSheetHeight +
                        AppDimensions.spacingMedium
                    : AppDimensions.spacingExtraLarge,
            child: FloatingActionButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                _mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _initialPosition,
                      zoom: AppDimensions.mapInitialZoom,
                    ),
                  ),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
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
}
