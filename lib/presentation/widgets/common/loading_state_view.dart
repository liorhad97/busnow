import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/presentation/widgets/animations/animated_loading_indicator.dart';

/// A centered loading state component with animated indicator
///
/// Displays a loading animation with an optional message, centered in its container.
/// Uses the AnimatedLoadingIndicator to show a variety of animation types.
class LoadingStateView extends StatelessWidget {
  final String message;
  final AnimationType animationType;
  final double size;
  
  const LoadingStateView({
    Key? key,
    required this.message,
    this.animationType = AnimationType.pulse,
    this.size = AppDimensions.iconSizeLarge,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedLoadingIndicator(
        type: animationType,
        message: message,
        size: size,
      ),
    );
  }
}
