import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';

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

enum AnimationType {
  pulse,
  rotate,
  bounce
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
      ],),),
    );
  }

  Widget _buildIndicator(Color color) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withBlue((color.blue + 20).clamp(0, 255)),
          ],
          center: const Alignment(0.2, 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: widget.size * 0.7,
          height: widget.size * 0.7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 3,
            ),
          ),
          child: Center(
            child: Container(
              width: widget.size * 0.4,
              height: widget.size * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A minimal, elegant progress indicator for inline use
class InlineLoadingIndicator extends StatefulWidget {
  final double height;
  final Color? color;
  final double width;

  const InlineLoadingIndicator({
    Key? key,
    this.height = 2.0,
    this.width = 60.0,
    this.color,
  }) : super(key: key);

  @override
  State<InlineLoadingIndicator> createState() => _InlineLoadingIndicatorState();
}

class _InlineLoadingIndicatorState extends State<InlineLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _isActive = false;
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color indicatorColor = widget.color ?? AppColors.primary;

    // Only build animation if widget is active
    if (!_isActive) {
      return SizedBox(width: widget.width, height: widget.height);
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(widget.height),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Check again inside the AnimatedBuilder to ensure it's still active
          if (!_isActive) return const SizedBox();
          
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: widget.width * 0.4,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    indicatorColor.withOpacity(0.0),
                    indicatorColor,
                    indicatorColor.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(widget.height),
              ),
              margin: EdgeInsets.only(
                left: (_controller.value * widget.width * 1.2) - (widget.width * 0.4),
              ),
            ),
          );
        },
      ),
    );
  }
}
