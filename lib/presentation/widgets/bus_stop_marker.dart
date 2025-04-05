import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:busnow/core/constants/colors-file.dart';
import 'package:busnow/core/constants/dimensions-file.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Widget for rendering bus stop markers on the map
class BusStopMarkerWidget extends StatelessWidget {
  final String busStopName;
  final AnimationController animationController;

  const BusStopMarkerWidget({
    super.key,
    required this.busStopName,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final double pulseValue = animationController.value;

        return SizedBox(
          width: AppDimensions.markerSize,
          height: AppDimensions.markerSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppDimensions.markerCircleSize + (pulseValue * 4),
                height: AppDimensions.markerCircleSize + (pulseValue * 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: AppDimensions.strokeWidthMedium,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryWithOpacity(
                        0.3 + (pulseValue * 0.2),
                      ),
                      blurRadius: 8 + (pulseValue * 8),
                      spreadRadius: 2 + (pulseValue * 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_bus,
                  color: Colors.white,
                  size: AppDimensions.iconSizeSmall,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Convert the widget to a BitmapDescriptor for use with Google Maps
  Future<BitmapDescriptor> toBitmapDescriptor() async {
    // Create a custom painting function to directly draw the marker
    // This is a more reliable approach than rendering a widget
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final size = Size(AppDimensions.markerSize, AppDimensions.markerSize);

    // Draw marker circle
    final Paint circlePaint =
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.fill;

    // Draw shadow
    final Paint shadowPaint =
        Paint()
          ..color = AppColors.primaryWithOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw shadow
    canvas.drawCircle(
      center,
      AppDimensions.markerCircleSize / 2 + 4, // Slightly larger for shadow
      shadowPaint,
    );

    // Draw circle
    canvas.drawCircle(center, AppDimensions.markerCircleSize / 2, circlePaint);

    // Draw border
    final Paint borderPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppDimensions.strokeWidthMedium;

    canvas.drawCircle(center, AppDimensions.markerCircleSize / 2, borderPaint);

    // Draw bus icon - using a simplified icon representation
    final Paint iconPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    // Simple bus shape (rectangle with rounded corners)
    final busRect = Rect.fromCenter(
      center: center,
      width: AppDimensions.iconSizeSmall,
      height: AppDimensions.iconSizeSmall / 2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(busRect, Radius.circular(2)),
      iconPaint,
    );

    // Draw wheels
    final wheelPaint =
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        center.dx - AppDimensions.iconSizeSmall / 3,
        center.dy + AppDimensions.iconSizeSmall / 4,
      ),
      2,
      wheelPaint,
    );

    canvas.drawCircle(
      Offset(
        center.dx + AppDimensions.iconSizeSmall / 3,
        center.dy + AppDimensions.iconSizeSmall / 4,
      ),
      2,
      wheelPaint,
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
