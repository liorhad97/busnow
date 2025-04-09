import 'package:flutter/material.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/presentation/utils/animations/animation_transitions.dart';

/// Action buttons for bus schedule interactions
///
/// Features:
/// - Track and Alert buttons with appropriate icons
/// - Color adapts to the bus status
/// - Animated entrance with slide and fade effects
/// - Haptic feedback on press
class BusActionButtons extends StatelessWidget {
  final Color statusColor;
  final VoidCallback? onTrackPressed;
  final VoidCallback? onAlertPressed;
  
  const BusActionButtons({
    Key? key,
    required this.statusColor,
    this.onTrackPressed,
    this.onAlertPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Alert button
        AnimationTransitions.fadeSlide(
          animation: const AlwaysStoppedAnimation(1.0),
          slideOffset: const Offset(0, 20),
          child: OutlinedButton.icon(
            onPressed: onAlertPressed,
            icon: const Icon(Icons.notifications_outlined, size: 18),
            label: const Text('Set Alert'),
            style: OutlinedButton.styleFrom(
              foregroundColor: statusColor,
              side: BorderSide(color: statusColor),
              elevation: 0,
            ),
          ),
        ),
        
        const SizedBox(width: AppDimensions.spacingMedium),
        
        // Track button
        AnimationTransitions.fadeSlide(
          animation: const AlwaysStoppedAnimation(1.0),
          slideOffset: const Offset(0, 20),
          child: ElevatedButton.icon(
            onPressed: onTrackPressed,
            icon: const Icon(Icons.map_outlined, size: 18),
            label: const Text('Track'),
            style: ElevatedButton.styleFrom(
              backgroundColor: statusColor,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }
}
