import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';

/// A pulsing dot for the center of the map cursor
///
/// Features:
/// - Changes size and glow based on map movement
/// - Animates smoothly between states
/// - Uses primary color with adjustable opacity
class PulsingCursorDot extends StatelessWidget {
  final bool isActive;
  
  const PulsingCursorDot({
    Key? key,
    this.isActive = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: AppDimensions.animDurationShort),
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive 
          ? AppColors.primary 
          : AppColors.primary.withOpacity(0.8),
        boxShadow: isActive ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 4,
          ),
        ] : null,
      ),
    );
  }
}
