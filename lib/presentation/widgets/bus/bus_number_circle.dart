import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';

/// A widget displaying a bus number with a rounded rectangle design and bus icon
///
/// Features:
/// - Rounded rectangle with gradient background
/// - Bus icon for better visual identification
/// - Adaptive colors based on status (early, on time, late)
/// - Bold, clear typography for maximum readability
class BusNumberCircle extends StatelessWidget {
  final String busNumber;
  final Color statusColor;
  final double size;

  const BusNumberCircle({
    Key? key,
    required this.busNumber,
    required this.statusColor,
    this.size = AppDimensions.busNumberCircleSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      width: size * 2, // Wider to accommodate the rounded rectangle shape
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor,
            Color.lerp(statusColor, AppColors.gradientEnd, 0.3)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(isDark ? 0.5 : 0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          busNumber,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.textSizeLarge + 2,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
