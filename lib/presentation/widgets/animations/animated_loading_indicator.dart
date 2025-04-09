import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/presentation/widgets/animations/animation_types.dart';
import 'package:busnow/presentation/widgets/animations/loading_indicator_painter.dart';

/// A beautifully designed animated loading indicator
///
/// Features:
/// - Elegant, pulsing animation with color gradients
/// - Multiple animation styles (pulse, rotate, bounce)
/// - Adaptive colors based on app theme
/// - Customizable size and appearance
class AnimatedLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final AnimationType type;
  final String? message;

  const AnimatedLoadingIndicator({
    Key? key,
    this.size = 48.0,
    this.color,
    this.type = AnimationType.pulse,
    this.message,
  }) : super(key: key);

  @override
  State<AnimatedLoadingIndicator> createState() => _AnimatedLoadingIndicatorState();
}

class _AnimatedLoadingIndicatorState extends State<AnimatedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: widget.type == AnimationType.pulse || widget.type == AnimationType.bounce);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 20.0,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color indicatorColor = widget.color ?? AppColors.primary;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                // Apply different animations based on type
                Widget indicator;
                switch (widget.type) {
                  case AnimationType.pulse:
                    indicator = Transform.scale(
                      scale: _pulseAnimation.value,
                      child: _buildIndicator(indicatorColor),
                    );
                    break;
                  case AnimationType.rotate:
                    indicator = Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: _buildIndicator(indicatorColor),
                    );
                    break;
                  case AnimationType.bounce:
                    indicator = Transform.translate(
                      offset: Offset(0, -10 * _bounceAnimation.value),
                      child: _buildIndicator(indicatorColor),
                    );
                    break;
                  default:
                    indicator = _buildIndicator(indicatorColor);
                }

                return indicator;
              },
            ),
            if (widget.message != null) ...[
              const SizedBox(height: AppDimensions.spacingMedium),
              Flexible(
                child: Text(
                  widget.message!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(Color color) {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: LoadingIndicatorPainter(color: color),
    );
  }
}
