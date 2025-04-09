import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';

/// A control button for map interactions
///
/// Features:
/// - Consistent styling for all map controls
/// - Tooltip for accessibility
/// - Ripple effect feedback
/// - Support for accent color highlighting
class MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool useAccentColor;
  final double size;
  
  const MapControlButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.useAccentColor = false,
    this.size = 42.0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        child: SizedBox(
          width: size,
          height: size,
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              color: useAccentColor ? AppColors.primary : null,
              size: AppDimensions.iconSizeMedium,
            ),
          ),
        ),
      ),
    );
  }
}
