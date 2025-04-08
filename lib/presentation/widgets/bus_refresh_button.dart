import 'dart:math';

import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A beautiful animated refresh button with interactive effects
/// 
/// This button provides visual feedback through:
/// - Rotation animation during loading
/// - Scale and highlight effects on press
/// - Optional haptic feedback
class BusRefreshButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final double size;
  final bool enableHaptics;
  final Color? color;

  const BusRefreshButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.size = 48.0,
    this.enableHaptics = true,
    this.color,
  }) : super(key: key);

  @override
  State<BusRefreshButton> createState() => _BusRefreshButtonState();
}

class _BusRefreshButtonState extends State<BusRefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );
    
    if (widget.isLoading) {
      _controller.repeat();
    }
  }
  
  @override
  void didUpdateWidget(BusRefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle loading state changes
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        // Complete one full rotation before stopping
        final normalized = _controller.value - _controller.value.floor();
        if (normalized < 0.9) {
          _controller.animateTo(
            _controller.value.floor() + 1.0,
            duration: Duration(
              milliseconds: ((1.0 - normalized) * AppDimensions.animDurationMedium).round(),
            ),
            curve: Curves.easeOutCirc,
          ).then((_) => _controller.stop());
        } else {
          _controller.stop();
        }
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final buttonColor = widget.color ?? theme.colorScheme.primary;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        if (widget.enableHaptics) {
          HapticFeedback.lightImpact();
        }
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : () {
        widget.onPressed();
        if (widget.enableHaptics) {
          HapticFeedback.selectionClick();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: AppDimensions.animDurationShort),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isLoading || _isPressed
              ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
              : Colors.transparent,
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Apply a bounce effect using a combination of rotation and subtle scaling
            final bounce = _isPressed 
                ? 0.9 
                : (widget.isLoading 
                    ? 1.0 + (0.05 * sin(_rotationAnimation.value * 6 * 3.1415))
                    : 1.0);
                    
            return Transform.scale(
              scale: bounce,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.1415,
                child: Icon(
                  Icons.refresh_rounded,
                  color: widget.isLoading
                      ? buttonColor
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  size: widget.size * 0.5,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
