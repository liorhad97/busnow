import 'package:flutter/material.dart';

/// Utility class for creating consistent animated transitions
///
/// Provides factory methods for common animation patterns used throughout the app
class AnimationTransitions {
  /// Creates a fade and slide transition animation
  /// 
  /// [animation] - The animation controller or animation
  /// [child] - The widget to animate
  /// [slideOffset] - The distance to slide (default 20.0 upwards)
  /// [curve] - The animation curve to use (default easeOutCubic)
  static Widget fadeSlide({
    required Animation<double> animation,
    required Widget child,
    Offset slideOffset = const Offset(0, 20),
    Curve curve = Curves.easeOutCubic,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            slideOffset.dx * (1 - animation.value),
            slideOffset.dy * (1 - animation.value),
          ),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Creates a scale transition with optional fade effect
  ///
  /// [animation] - The animation controller or animation
  /// [child] - The widget to animate
  /// [fade] - Whether to include a fade effect (default true)
  /// [curve] - The animation curve to use (default easeOutBack)
  static Widget scale({
    required Animation<double> animation,
    required Widget child,
    bool fade = true,
    Curve curve = Curves.easeOutBack,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: animation, curve: curve).value,
          child: fade
              ? Opacity(opacity: animation.value, child: child)
              : child,
        );
      },
      child: child,
    );
  }
  
  /// Creates a staggered list item animation with fade and slide effects
  ///
  /// [index] - The index of the item in the list (affects delay)
  /// [animation] - The parent animation controller or animation
  /// [child] - The widget to animate
  /// [staggerDuration] - The duration to stagger each item (default 50ms)
  static Widget staggeredListItem({
    required int index,
    required Animation<double> animation,
    required Widget child,
    int staggerDuration = 50,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * staggerDuration)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        // Combine with parent animation if provided
        final adjustedValue = value * animation.value;

        return Transform.translate(
          offset: Offset(0, 20 * (1 - adjustedValue)),
          child: Opacity(opacity: adjustedValue, child: child),
        );
      },
      child: child,
    );
  }
  
  /// Creates a pulsing animation
  ///
  /// [child] - The widget to animate
  /// [duration] - The duration of one pulse cycle (default 1500ms)
  /// [minScale] - The minimum scale factor (default 0.95)
  /// [maxScale] - The maximum scale factor (default 1.05)
  static Widget pulsing({
    required Widget child,
    int duration = 1500,
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: minScale, end: maxScale),
      duration: Duration(milliseconds: duration),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
      onEnd: () {}, // Trigger rebuild to continue animation
    );
  }
}
