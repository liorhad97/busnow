import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// A modern, visually attractive marker for bus stops on the map
///
/// Features:
/// - Smooth pulsing animation with gradient effects
/// - Elegant shadow effects for depth and emphasis
/// - Platform-independent marker implementation
/// - Highly configurable appearance with modern design
/// - Tactile visual feedback for selected state
class BusStopMarker extends StatelessWidget {
  final String busStopName;
  final Animation<double> pulseAnimation;
  final bool isSelected;
  final Color? color;
  final bool showLabel;

  const BusStopMarker({
    Key? key,
    required this.busStopName,
    required this.pulseAnimation,
    this.isSelected = false,
    this.color,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final markerColor = color ?? AppColors.primary;
    final double pulseValue = pulseAnimation.value;
    
    return Container(
      width: 70,
      height: 70,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing ring effect
          if (isSelected)
            AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, _) {
                return Container(
                  width: 38 + (pulseValue * 20),
                  height: 38 + (pulseValue * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        markerColor.withOpacity(0.4 - (pulseValue * 0.3)),
                        markerColor.withOpacity(0.0),
                      ],
                      stops: const [0.7, 1.0],
                    ),
                  ),
                );
              },
            ),
          
          // Inner pulse for extra dimension
          if (isSelected)
            AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, _) {
                return Container(
                  width: 34 + (pulseValue * 10),
                  height: 34 + (pulseValue * 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: markerColor.withOpacity(0.2 - (pulseValue * 0.15)),
                  ),
                );
              },
            ),
          
          // Main marker with enhanced design
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: isSelected ? 0.8 : 1.0,
              end: isSelected ? 1.1 : 1.0,
            ),
            duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
            curve: Curves.elasticOut,
            builder: (context, scale, _) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        markerColor,
                        markerColor.withBlue((markerColor.blue + 20).clamp(0, 255)),
                      ],
                      center: const Alignment(0.2, 0.2),
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowMedium,
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
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
                    size: 15,
                  ),
                ),
              );
            },
          ),
          
          // Optional label (when showLabel is true)
          if (showLabel && isSelected)
            Positioned(
              bottom: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 12 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingSmall,
                          vertical: AppDimensions.spacingExtraSmall / 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 4,
                              spreadRadius: 0,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          busStopName,
                          style: TextStyle(
                            color: markerColor.withBlue((markerColor.blue - 20).clamp(0, 255)),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
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
