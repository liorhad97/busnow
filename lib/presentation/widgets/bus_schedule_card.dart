import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/presentation/widgets/animated_time_display.dart';

/// A beautifully designed card to display bus schedules
///
/// Features:
/// - Elegant, modern design with smooth gradients
/// - Animated loading indicators
/// - Micro-interactions for better UX
/// - Adaptive colors based on bus status (early, on time, late)
class BusScheduleCard extends StatefulWidget {
  final String busNumber;
  final String destination;
  final DateTime? arrivalTime;
  final Duration? delay;
  final bool isExpanded;
  final VoidCallback? onTap;
  final bool isLoading;

  const BusScheduleCard({
    Key? key,
    required this.busNumber,
    required this.destination,
    this.arrivalTime,
    this.delay,
    this.isExpanded = false,
    this.onTap,
    this.isLoading = false,
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
  
  Color _getStatusColor() {
    if (widget.delay == null || widget.arrivalTime == null) {
      return AppColors.info;
    }
    
    if (widget.delay!.inMinutes <= -2) {
      return AppColors.busEarlyColor; // Early
    } else if (widget.delay!.inMinutes <= 2) {
      return AppColors.busOnTimeColor; // On time
    } else if (widget.delay!.inMinutes <= 10) {
      return AppColors.busLateColor; // Late
    } else {
      return AppColors.busVeryLateColor; // Very late
    }
  }
  
  String _getStatusText() {
    if (widget.delay == null || widget.arrivalTime == null) {
      return 'Unknown';
    }
    
    final minutes = widget.delay!.inMinutes;
    if (minutes <= -2) {
      return '$minutes min early';
    } else if (minutes <= 2) {
      return 'On time';
    } else {
      return '$minutes min late';
    }
  }
  
  String _getArrivalText() {
    if (widget.arrivalTime == null) {
      return '--:--';
    }
    
    return '${widget.arrivalTime!.hour.toString().padLeft(2, '0')}:${widget.arrivalTime!.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();
    final arrivalText = _getArrivalText();
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
                    // Main content row
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
                      child: Row(
                        children: [
                          // Bus number circle
                          Container(
                            width: AppDimensions.busNumberCircleSize,
                            height: AppDimensions.busNumberCircleSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  statusColor,
                                  Color.lerp(statusColor, AppColors.gradientEnd, 0.3)!,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                widget.busNumber,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppDimensions.textSizeMedium,
                                ),
                              ),
                            ),
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
                                    if (widget.isLoading)
                                      _buildLoadingIndicator(statusColor)
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppDimensions.spacingSmall,
                                          vertical: AppDimensions.spacingExtraSmall / 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                                        ),
                                        child: Text(
                                          statusText,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: AppDimensions.textSizeExtraSmall,
                                          ),
                                        ),
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
                    
                    // Expanded details
                    ClipRect(
                      child: Align(
                        heightFactor: _expansionAnimation.value,
                        child: Opacity(
                          opacity: _opacityAnimation.value,
                          child: _buildExpandedContent(context, statusColor),
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
  
  Widget _buildLoadingIndicator(Color color) {
    return SizedBox(
      height: 18,
      width: 70,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            width: 70,
            height: 4,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 70.0),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Positioned(
                left: value % 90 - 20,
                child: Container(
                  width: 30,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            onEnd: () => setState(() {}),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpandedContent(BuildContext context, Color statusColor) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final minutes = widget.arrivalTime != null 
        ? widget.arrivalTime!.difference(now).inMinutes 
        : null;
    final minutesText = minutes != null ? '$minutes min' : '--';
    
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.spacingMedium,
        right: AppDimensions.spacingMedium,
        bottom: AppDimensions.spacingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Interactive timeline with animated scrolling effect
          const Divider(),
          const SizedBox(height: AppDimensions.spacingMedium),
          
          // Time display with animated clock
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMedium),
            child: Row(
              children: [
                _buildTimeDisplay(context, statusColor),
                const SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, 
                            size: 16, 
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Arrives in',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(20 * (1 - value), 0),
                            child: Opacity(
                              opacity: value,
                              child: Text(
                                minutesText,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Interactive route visualization with animated progress
          Container(
            margin: const EdgeInsets.only(
              top: AppDimensions.spacingMedium, 
              bottom: AppDimensions.spacingLarge
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
              color: theme.cardTheme.color?.withOpacity(0.7) ?? theme.colorScheme.surface.withOpacity(0.7),
              border: Border.all(color: statusColor.withOpacity(0.1), width: 1),
            ),
            padding: const EdgeInsets.all(AppDimensions.spacingMedium),
            child: Column(
              children: [
                Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.elasticOut,
                      builder: (context, value, _) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: statusColor,
                              size: 14,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(width: AppDimensions.spacingMedium),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Location',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Central Station',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Animated route progress line
                Container(
                  margin: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1200),
                        builder: (context, value, _) {
                          return Container(
                            width: 2,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  statusColor,
                                  Color.lerp(statusColor, Colors.grey.withOpacity(0.5), 1 - value)!,
                                ],
                                stops: [value, value],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSmall),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) {
                              return Opacity(
                                opacity: value,
                                child: Container(
                                  margin: const EdgeInsets.only(left: AppDimensions.spacingExtraLarge),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.spacingSmall,
                                    vertical: AppDimensions.spacingExtraSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: statusColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'En Route',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.elasticOut,
                      builder: (context, value, _) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  statusColor.withOpacity(0.9),
                                  statusColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.flag_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(width: AppDimensions.spacingMedium),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Destination',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.destination,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Action buttons with animated hover effect
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined, size: 18),
                        label: const Text('Set Alert'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: statusColor,
                          side: BorderSide(color: statusColor),
                          elevation: 0,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: AppDimensions.spacingMedium),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text('Track'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build the animated time display
  Widget _buildTimeDisplay(BuildContext context, Color statusColor) {
    return AnimatedTimeDisplay(
      arrivalTime: widget.arrivalTime,
      color: statusColor,
      isCompact: false,
    );
  }
}
