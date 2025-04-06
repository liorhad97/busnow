import 'package:busnow/core/constants/dimensions.dart';
import 'package:flutter/material.dart';

/// A button widget for refreshing bus schedules
class BusRefreshButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const BusRefreshButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  State<BusRefreshButton> createState() => _BusRefreshButtonState();
}

class _BusRefreshButtonState extends State<BusRefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationLong),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BusRefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        icon: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * 3.1415926535,
              child: Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
        splashRadius: AppDimensions.fabSplashRadius,
        tooltip: 'Refresh',
      ),
    );
  }
}
