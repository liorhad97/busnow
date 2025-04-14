import 'package:busnow/core/constants/dir/lottie_dir.dart';
import 'package:busnow/presentation/widgets/animations/animated_loading_indicator.dart';
import 'package:busnow/presentation/widgets/animations/animation_types.dart';
import 'package:flutter/material.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:lottie/lottie.dart';

/// A centered loading state component with animated indicator
///
/// Displays a loading animation with an optional message, centered in its container.
/// Uses the AnimatedLoadingIndicator to show a variety of animation types.
/// Can also display Lottie animations when specified.
class LoadingStateView extends StatelessWidget {
  final String message;
  final AnimationType animationType;
  final double size;
  final bool useBusAnimation;

  const LoadingStateView({
    Key? key,
    required this.message,
    this.animationType = AnimationType.pulse,
    this.size = AppDimensions.iconSizeLarge,
    this.useBusAnimation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (useBusAnimation)
                // Use the Lottie bus animation
                SizedBox(
                  height: size * 1.5, // Reduced from 2x to 1.5x
                  width: size * 1.5, // Reduced from 2x to 1.5x
                  child: Lottie.asset(LottieDir.bus, frameRate: FrameRate.max),
                )
              else
                // Use the default animated indicator
                AnimatedLoadingIndicator(type: animationType, size: size),

              const SizedBox(height: AppDimensions.spacingMedium),

              // Message text
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
