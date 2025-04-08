import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';

/// Provides beautiful page transitions and animations for the app
///
/// This class contains various transition builders that can be used
/// to create stunning, fluid animations between screens.
class AppAnimations {
  // Prevent instantiation
  AppAnimations._();
  
  /// Creates a beautiful fade-through transition
  ///
  /// Use this for transitions between screens that aren't hierarchically related
  static Widget fadeThroughTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
        )),
        child: child,
      ),
    );
  }
  
  /// Creates a beautiful shared axis horizontal transition
  ///
  /// Use this for transitions between related screens or tabs
  static Widget sharedAxisHorizontalTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
        )),
        child: child,
      ),
    );
  }
  
  /// Creates a beautiful scale transition
  ///
  /// Use this for opening detail screens
  static Widget scaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
    );
    
    return ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
      child: FadeTransition(
        opacity: curvedAnimation,
        child: child,
      ),
    );
  }
  
  /// Creates a beautiful bottom-up transition
  ///
  /// Use this for showing modal screens and bottom sheets
  static Widget bottomUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }
  
  /// Creates a beautiful fade-out transition for the old page
  static Widget fadeOutTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: secondaryAnimation,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInCubic),
      ).drive(Tween<double>(begin: 1.0, end: 0.3)),
      child: child,
    );
  }
  
  /// Creates a beautiful page route for navigation
  static PageRouteBuilder<T> createPageRoute<T>({
    required Widget page,
    RouteTransitionType transitionType = RouteTransitionType.fadeThrough,
    Duration duration = const Duration(milliseconds: AppDimensions.animDurationMedium),
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      fullscreenDialog: fullscreenDialog,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transitionType) {
          case RouteTransitionType.fadeThrough:
            return fadeThroughTransition(context, animation, secondaryAnimation, child);
          case RouteTransitionType.sharedAxisHorizontal:
            return sharedAxisHorizontalTransition(context, animation, secondaryAnimation, child);
          case RouteTransitionType.scale:
            return scaleTransition(context, animation, secondaryAnimation, child);
          case RouteTransitionType.bottomUp:
            return bottomUpTransition(context, animation, secondaryAnimation, child);
          case RouteTransitionType.fadeOut:
            return fadeOutTransition(context, animation, secondaryAnimation, child);
        }
      },
    );
  }
  
  /// Creates a beautiful staggered list animation for list items
  ///
  /// Use this when showing a list of items to create a cascading effect
  static Widget staggeredListItem({
    required Widget child,
    required int index,
    required Animation<double> animation,
    int staggerFactor = 30,
  }) {
    final staggeredAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(
        index == 0 ? 0.0 : (index * staggerFactor) / 1000,
        1.0,
        curve: Curves.easeOutQuint,
      ),
    );
    
    return AnimatedBuilder(
      animation: staggeredAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: staggeredAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - staggeredAnimation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Creates a beautiful hero transition with custom flare
  static Widget heroFlareTransition({
    required Widget child,
    required Animation<double> animation,
    required String tag,
    Color? flareColor,
  }) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final forwardAnimation = flightDirection == HeroFlightDirection.push;
            final progress = forwardAnimation
                ? Curves.easeOutQuad.transform(animation.value)
                : 1 - Curves.easeInQuad.transform(1 - animation.value);
                
            return Material(
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Optional flare effect
                  if (flareColor != null && progress > 0.2 && progress < 0.8)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: flareColor.withOpacity(0.4 * _flareIntensity(progress)),
                            blurRadius: 20,
                            spreadRadius: 10 * _flareIntensity(progress),
                          ),
                        ],
                      ),
                    ),
                  // Main hero content
                  child!,
                ],
              ),
            );
          },
          child: fromHeroContext.widget,
        );
      },
      child: child,
    );
  }
  
  // Helper function for flare intensity based on animation progress
  static double _flareIntensity(double progress) {
    // Create a bell curve that peaks in the middle of the animation
    if (progress < 0.2 || progress > 0.8) return 0.0;
    return -(progress - 0.5) * (progress - 0.5) * 4 + 1.0;
  }
}

/// Types of transitions that can be used for page navigation
enum RouteTransitionType {
  fadeThrough,
  sharedAxisHorizontal,
  scale,
  bottomUp,
  fadeOut,
}
