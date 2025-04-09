import 'package:flutter/material.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/presentation/utils/bus/bus_status_calculator.dart';
import 'package:busnow/presentation/widgets/bus/bus_number_circle.dart';
import 'package:busnow/presentation/widgets/bus/bus_status_indicator.dart';
import 'package:busnow/presentation/widgets/bus/bus_expanded_content.dart';

/// A beautifully designed card to display bus schedules
///
/// Features:
/// - Elegant, modern design with smooth gradients
/// - Expandable content with route visualization
/// - Status indicators for bus timeliness
/// - Animated transitions and micro-animations
class BusScheduleCard extends StatefulWidget {
  final String busNumber;
  final String destination;
  final DateTime? arrivalTime;
  final Duration? delay;
  final bool isExpanded;
  final VoidCallback? onTap;
  final bool isLoading;
  final String origin;

  const BusScheduleCard({
    Key? key,
    required this.busNumber,
    required this.destination,
    this.arrivalTime,
    this.delay,
    this.isExpanded = false,
    this.onTap,
    this.isLoading = false,
    this.origin = 'Central Station',
  }) : super(key: key);

  @override
  State<BusScheduleCard> createState() => _BusScheduleCardState();
}

class _BusScheduleCardState extends State<BusScheduleCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expansionAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
    );
    
    _expansionAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    if (widget.isExpanded) {
      _animationController.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(BusScheduleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = BusStatusCalculator.getStatusColor(widget.delay);
    final statusText = BusStatusCalculator.getStatusText(widget.delay);
    final arrivalText = BusStatusCalculator.getArrivalText(widget.arrivalTime);
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium,
              vertical: AppDimensions.spacingSmall / 2,
            ),
            elevation: AppDimensions.elevationSmall + (_expansionAnimation.value * AppDimensions.elevationMedium / 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
              side: widget.isExpanded 
                ? BorderSide(color: statusColor.withOpacity(0.2), width: 1.5) 
                : BorderSide.none,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              splashColor: statusColor.withOpacity(0.1),
              highlightColor: statusColor.withOpacity(0.05),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.cardTheme.color ?? theme.colorScheme.surface,
                      Color.lerp(
                        theme.cardTheme.color ?? theme.colorScheme.surface,
                        statusColor,
                        0.03,
                      )!,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Main content row (always visible)
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
                      child: Row(
                        children: [
                          // Bus number circle
                          BusNumberCircle(
                            busNumber: widget.busNumber,
                            statusColor: statusColor,
                          ),
                          
                          const SizedBox(width: AppDimensions.spacingMedium),
                          
                          // Destination and arrival info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.destination,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppDimensions.spacingExtraSmall),
                                Row(
                                  children: [
                                    BusStatusIndicator(
                                      statusText: statusText,
                                      statusColor: statusColor,
                                      isLoading: widget.isLoading,
                                    ),
                                    const SizedBox(width: AppDimensions.spacingSmall),
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: theme.textTheme.bodySmall?.color,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      arrivalText,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Expansion icon
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: widget.isExpanded ? 0.5 : 0.0,
                            ),
                            duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
                            builder: (context, value, child) {
                              return Transform.rotate(
                                angle: value * 3.14159,
                                child: Container(
                                  padding: const EdgeInsets.all(AppDimensions.spacingExtraSmall),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Expanded details section (conditionally visible)
                    ClipRect(
                      child: Align(
                        heightFactor: _expansionAnimation.value,
                        child: Opacity(
                          opacity: _opacityAnimation.value,
                          child: BusExpandedContent(
                            arrivalTime: widget.arrivalTime,
                            delay: widget.delay,
                            statusColor: statusColor,
                            destination: widget.destination,
                            origin: widget.origin,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
