import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';

/// A single control button for map interactions
///
/// Features:
/// - Consistent size and tap area
/// - Tooltip for accessibility
/// - Accent color option for important actions
/// - Ink effects for interactive feedback
class MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool useAccentColor;
  
  const MapControlButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.useAccentColor = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        child: SizedBox(
          width: 42,
          height: 42,
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
