import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';

/// A circular widget displaying a bus number with gradient background
///
/// Features:
/// - Gradient background with shadow effects
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
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
            color: statusColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          busNumber,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.textSizeMedium,
          ),
        ),
      ),
    );
  }
}
