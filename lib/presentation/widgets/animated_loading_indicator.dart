import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:flutter/material.dart';

/// A beautiful custom animated loading indicator with pulsing effect
class AnimatedLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  
  const AnimatedLoadingIndicator({
    Key? key,
    this.size = 48.0,
    this.color,
  }) : super(key: key);

  @override
  State<AnimatedLoadingIndicator> createState() => _AnimatedLoadingIndicatorState();
}

class _AnimatedLoadingIndicatorState extends State<AnimatedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: AppDimensions.animDurationLoading),
      vsync: this,
    )..repeat(reverse: false);

    _sizeAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 0.7),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 0.3),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing outer circle
            Transform.scale(
              scale: _sizeAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(_opacityAnimation.value * 0.2),
                ),
              ),
            ),
            
            // Inner rotating loader
            SizedBox(
              width: widget.size * 0.8,
              height: widget.size * 0.8,
              child: CircularProgressIndicator(
                strokeWidth: AppDimensions.strokeWidthMedium,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            
            // Bus icon in the center
            Icon(
              Icons.directions_bus_outlined,
              size: widget.size * 0.4,
              color: color,
            ),
          ],
        );
      },
    );
  }
}
