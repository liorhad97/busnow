import 'package:busnow/core/constants/dir/icons_dir.dart';
import 'package:busnow/domain/models/bus_stop_model.dart';
import 'package:flutter/material.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
class MapMarkersManager {
  // Helper method to create markers from bus stops
  static Future<Set<Marker>> createMarkers({
    required List<BusStop> busStops,
    required Function(BusStop) onMarkerTap,
    required AnimationController animationController,
  }) async {
    final Set<Marker> markers = {};

    for (var busStop in busStops) {
      final marker = Marker(
        markerId: MarkerId(busStop.id),
        position: LatLng(busStop.latitude, busStop.longitude),
        icon: await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(),
          IconsDir.busStop,
        ),
        infoWindow: InfoWindow(
          title: busStop.name,
          snippet: 'Tap to see bus schedules',
        ),
        onTap: () {
          animationController.forward();
          onMarkerTap(busStop);
        },
      );
      markers.add(marker);
    }

    return markers;
  }
}
