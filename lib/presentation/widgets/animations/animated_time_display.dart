import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';

/// A beautifully animated clock display for bus schedules
///
/// Features:
/// - Elegant animated clock face with moving hands
/// - Digital time display with sliding animation
/// - Pulsing effect to indicate live updates
/// - Adaptive colors based on time status
class AnimatedTimeDisplay extends StatefulWidget {
  final DateTime? arrivalTime;
  final Color color;
  final bool isCompact;

  const AnimatedTimeDisplay({
    Key? key,
    required this.arrivalTime,
    required this.color,
    this.isCompact = false,
  }) : super(key: key);

  @override
  State<AnimatedTimeDisplay> createState() => _AnimatedTimeDisplayState();
}

class _AnimatedTimeDisplayState extends State<AnimatedTimeDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late DateTime _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Update the clock every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final arrivalTime =
        widget.arrivalTime ?? _currentTime.add(const Duration(minutes: 15));
    final timeUntilArrival = arrivalTime.difference(_currentTime);
    final minutesRemaining = timeUntilArrival.inMinutes;
    final secondsRemaining = timeUntilArrival.inSeconds % 60;

    // Calculate hand angles
    final hourAngle =
        (arrivalTime.hour % 12 + arrivalTime.minute / 60) * (2 * math.pi / 12);
    final minuteAngle = arrivalTime.minute * (2 * math.pi / 60);

    if (widget.isCompact) {
      return _buildCompactDisplay(theme, minutesRemaining);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulseValue = 0.05 * _controller.value;

        return Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.color.withOpacity(0.9), widget.color],
            ),
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadiusMedium,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.2 + pulseValue),
                blurRadius: 12,
                spreadRadius: 2 + (pulseValue * 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Clock face
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Clock markings
                    ...List.generate(12, (index) {
                      final angle = index * (2 * math.pi / 12);
                      final isHour = index % 3 == 0;
                      return Transform.rotate(
                        angle: angle,
                        child: Center(
                          child: Transform.translate(
                            offset: const Offset(0, -22),
                            child: Container(
                              width: isHour ? 2 : 1,
                              height: isHour ? 6 : 3,
                              color:
                                  isHour
                                      ? Colors.black.withOpacity(0.7)
                                      : Colors.black.withOpacity(0.3),
                            ),
                          ),
                        ),
                      );
                    }),

                    // Hour hand
                    Transform.rotate(
                      angle: hourAngle,
                      child: Center(
                        child: Transform.translate(
                          offset: const Offset(0, -8),
                          child: Container(
                            width: 2.5,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Minute hand
                    Transform.rotate(
                      angle: minuteAngle,
                      child: Center(
                        child: Transform.translate(
                          offset: const Offset(0, -14),
                          child: Container(
                            width: 1.5,
                            height: 18,
                            decoration: BoxDecoration(
                              color: widget.color,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Center dot
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),

              // Digital time
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingSmall,
                  vertical: AppDimensions.spacingExtraSmall,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusSmall,
                  ),
                ),
                child: Text(
                  _formatTime(arrivalTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              // Remaining minutes
              Text(
                '$minutesRemaining:${secondsRemaining.toString().padLeft(2, '0')} min',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactDisplay(ThemeData theme, int minutesRemaining) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.color.withOpacity(0.9), widget.color],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$minutesRemaining',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'min',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
