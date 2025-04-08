import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// A customizable marker for bus stops on the map
///
/// Features:
/// - Pulsing animation effect for visibility
/// - Shadow effects for depth
/// - Platform-independent marker implementation
/// - Configurable appearance
class BusStopMarker extends StatelessWidget {
  final String busStopName;
  final Animation<double> pulseAnimation;
  final bool isSelected;
  final Color? color;

  const BusStopMarker({
    Key? key,
    required this.busStopName,
    required this.pulseAnimation,
    this.isSelected = false,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final markerColor = color ?? AppColors.primary;
    final double pulseValue = pulseAnimation.value;
    
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing background
          if (isSelected)
            AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, _) {
                return Container(
                  width: 32 + (pulseValue * 16),
                  height: 32 + (pulseValue * 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: markerColor.withOpacity(0.2 - (pulseValue * 0.15)),
                  ),
                );
              },
            ),
          
          // Main marker
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: isSelected ? 0.8 : 1.0,
              end: isSelected ? 1.0 : 1.0,
            ),
            duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
            curve: Curves.elasticOut,
            builder: (context, scale, _) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: markerColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: markerColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Convert the widget to a bitmap descriptor for use with map markers
  Future<BitmapDescriptor> toBitmapDescriptor() async {
    // Render widget to image
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    
    // Need to use a fixed size widget for rendering
    const Size size = Size(60, 60);
    
    // Create a simple version of the marker for the bitmap
    RepaintBoundary(
      child: Container(
        width: size.width,
        height: size.height,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Shadow
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: (color ?? AppColors.primary).withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            
            // Marker dot
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color ?? AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.directions_bus,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
    
    // Convert to image
    final ui.Image image = await recorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    
    // Convert to byte data
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    
    if (byteData == null) {
      throw Exception('Failed to render marker');
    }
    
    // Create bitmap descriptor
    return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
  }
}

/// Widget that creates custom animated markers for bus stops
///
/// This utility class handles creating map markers with custom appearance
/// and animations
class BusStopMarkerFactory {
  final AnimationController animationController;
  
  BusStopMarkerFactory({required this.animationController});
  
  /// Create a map marker for a bus stop
  Future<Marker> createMarker({
    required String id,
    required String title,
    required LatLng position,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? color,
  }) async {
    final marker = BusStopMarker(
      busStopName: title,
      pulseAnimation: animationController,
      isSelected: isSelected,
      color: color,
    );
    
    final icon = await marker.toBitmapDescriptor();
    
    return Marker(
      markerId: MarkerId(id),
      position: position,
      icon: icon,
      infoWindow: InfoWindow(
        title: title,
        snippet: 'Tap to see bus schedules',
      ),
      onTap: onTap,
    );
  }
}
