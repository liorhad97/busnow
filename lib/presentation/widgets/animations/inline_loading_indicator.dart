import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';

/// A minimal, elegant progress indicator for inline use
///
/// Features:
/// - Slim, unobtrusive design that fits within text or small UI elements
/// - Smooth sliding animation
/// - Customizable size and color
/// - Efficient disposal handling
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
