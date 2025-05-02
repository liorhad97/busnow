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
  final double size;

  const BusNumberCircle({
    Key? key,
    required this.busNumber,
    this.size = AppDimensions.busNumberCircleSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: AppDimensions.spacingSmall),
        Text(
          busNumber,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.textSizeLarge + 2,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMedium),
        Container(width: 2, height: 50, color: AppColors.primary),
      ],
    );
  }
}
