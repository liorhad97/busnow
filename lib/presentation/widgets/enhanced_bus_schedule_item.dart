import 'dart:math' as math;
import 'dart:ui';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/domain/models/bus_schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A beautifully designed card for displaying bus schedule information
class EnhancedBusScheduleItem extends StatefulWidget {
  final BusSchedule schedule;
  final bool isEarliest;
  final bool isExpanded;
  final VoidCallback? onTap;

  const EnhancedBusScheduleItem({
    Key? key,
    required this.schedule,
    this.isEarliest = false,
    this.isExpanded = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<EnhancedBusScheduleItem> createState() => _EnhancedBusScheduleItemState();
}

class _EnhancedBusScheduleItemState extends State<EnhancedBusScheduleItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _expandAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Start pulse animation if this is the earliest bus
    if (widget.isEarliest) {
      _animationController.repeat(reverse: true);
    }
    
    // If already expanded, set animation value
    if (widget.isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(EnhancedBusScheduleItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle earliest status changes
    if (widget.isEarliest != oldWidget.isEarliest) {
      if (widget.isEarliest) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
    
    // Handle expansion changes
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

  // Get appropriate colors based on timing status
  Color _getScheduleColor(BuildContext context) {
    final time = widget.schedule.arrivalTimeInMinutes;
    
    if (time <= 5) {
      return AppColors.busEarlyColor; // Arriving very soon
    } else if (time <= 10) {
      return AppColors.busOnTimeColor; // Arriving soon
    } else if (time <= 20) {
      return AppColors.busLateColor; // Arriving in moderate time
    } else {
      return AppColors.busVeryLateColor; // Arriving later
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final statusColor = _getScheduleColor(context);
    
    // Calculate gradient colors based on schedule status
    final gradientPrimary = Color.lerp(
      statusColor, 
      isDarkMode ? Colors.black : Colors.white, 
      0.85,
    )!;
    
    final gradientSecondary = Color.lerp(
      statusColor, 
      isDarkMode ? Colors.black : Colors.white, 
      0.9,
    )!;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final scale = widget.isEarliest 
                ? (_pulseAnimation.value * 0.02) + 0.98 // Subtle pulse if earliest
                : _isPressed 
                    ? 0.98 // Pressed scale
                    : _isHovered 
                        ? 1.01 // Hover scale
                        : 1.0; // Normal scale
                        
            final elevation = widget.isEarliest || _isHovered
                ? AppDimensions.elevationMedium
                : _isPressed 
                    ? AppDimensions.elevationSmall / 2
                    : AppDimensions.elevationSmall;
            
            return Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gradientPrimary,
                      gradientSecondary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isEarliest
                          ? statusColor.withOpacity(0.2)
                          : AppColors.shadowLight,
                      blurRadius: elevation * 2,
                      spreadRadius: elevation / 2,
                      offset: Offset(0, elevation / 2),
                    ),
                  ],
                  border: Border.all(
                    color: widget.isEarliest
                        ? statusColor.withOpacity(0.3)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Main content row
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.spacingMedium),
                        child: Row(
                          children: [
                            // Bus number circle with animated background
                            _buildBusNumberCircle(statusColor, theme),
                            
                            const SizedBox(width: AppDimensions.spacingMedium),
                            
                            // Destination and arrival info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.schedule.destination,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppDimensions.spacingExtraSmall),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppDimensions.spacingSmall,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getStatusIcon(widget.schedule.arrivalTimeInMinutes),
                                              color: statusColor,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _getStatusText(widget.schedule.arrivalTimeInMinutes),
                                              style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Arrival time with dynamic styling
                            _buildArrivalTime(statusColor, theme),
                          ],
                        ),
                      ),
                      
                      // Expanded details section
                      ClipRect(
                        child: Align(
                          heightFactor: _expandAnimation.value,
                          child: Opacity(
                            opacity: _expandAnimation.value,
                            child: _buildExpandedContent(statusColor, theme),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  // Bus number circle with animated gradient
  Widget _buildBusNumberCircle(Color statusColor, ThemeData theme) {
    return Container(
      width: AppDimensions.busNumberCircleSize,
      height: AppDimensions.busNumberCircleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            statusColor,
            Color.lerp(statusColor, AppColors.primary, 0.3)!,
            statusColor,
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: GradientRotation(_animationController.value * 2 * math.pi),
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
        child: Container(
          width: AppDimensions.busNumberCircleSize - 6,
          height: AppDimensions.busNumberCircleSize - 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.cardTheme.color,
          ),
          child: Center(
            child: Text(
              widget.schedule.busNumber,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: AppDimensions.textSizeMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Arrival time display with animated background
  Widget _buildArrivalTime(Color statusColor, ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMedium,
            vertical: AppDimensions.spacingSmall,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                statusColor.withOpacity(0.7 * value),
                statusColor.withOpacity(0.9 * value),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.2 * value),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.isEarliest ? 
                _buildPulsingDot(statusColor) :
                const SizedBox(width: 4),
              Text(
                '${widget.schedule.arrivalTimeInMinutes}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                'min',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Small pulsing dot to indicate real-time updates
  Widget _buildPulsingDot(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.5 + 0.5 * math.sin(value * math.pi)),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5 * math.sin(value * math.pi)),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
      onEnd: () => setState(() {}), // Trigger rebuild to continue animation
    );
  }
  
  // Status icon based on arrival time
  IconData _getStatusIcon(int minutes) {
    if (minutes <= 5) {
      return Icons.bolt_rounded; // Arriving very soon
    } else if (minutes <= 10) {
      return Icons.directions_bus_rounded; // Arriving soon
    } else if (minutes <= 20) {
      return Icons.schedule_rounded; // Arriving in moderate time
    } else {
      return Icons.hourglass_bottom_rounded; // Arriving later
    }
  }
  
  // Status text based on arrival time
  String _getStatusText(int minutes) {
    if (minutes <= 5) {
      return 'Arriving now';
    } else if (minutes <= 10) {
      return 'Arriving soon';
    } else if (minutes <= 20) {
      return 'On the way';
    } else {
      return 'Scheduled';
    }
  }
  
  // Expanded content with route details and actions
  Widget _buildExpandedContent(Color statusColor, ThemeData theme) {
    // Calculate an estimated arrival time
    final now = DateTime.now();
    final arrivalTime = now.add(Duration(minutes: widget.schedule.arrivalTimeInMinutes));
    final arrivalTimeString = '${arrivalTime.hour}:${arrivalTime.minute.toString().padLeft(2, '0')}';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMedium,
        0,
        AppDimensions.spacingMedium,
        AppDimensions.spacingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider with animated gradient
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  statusColor.withOpacity(0.3),
                  statusColor.withOpacity(0.5),
                  statusColor.withOpacity(0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
            ),
          ),
          
          // Route and time information
          Row(
            children: [
              // Route visualization
              _buildRouteVisualization(statusColor, theme),
              
              const SizedBox(width: AppDimensions.spacingMedium),
              
              // Time information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      theme,
                      icon: Icons.access_time_rounded,
                      label: 'Arrives at',
                      value: arrivalTimeString,
                      color: statusColor,
                    ),
                    
                    const SizedBox(height: AppDimensions.spacingSmall),
                    
                    _buildInfoRow(
                      theme,
                      icon: Icons.people_alt_rounded,
                      label: 'Occupancy',
                      value: 'Medium',
                      color: statusColor,
                    ),
                    
                    const SizedBox(height: AppDimensions.spacingSmall),
                    
                    _buildInfoRow(
                      theme,
                      icon: Icons.wheelchair_pickup_rounded,
                      label: 'Accessibility',
                      value: 'Available',
                      color: statusColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacingMedium),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Set Reminder button
              _buildActionButton(
                theme,
                icon: Icons.notifications_none_rounded,
                label: 'Set Reminder',
                onTap: () {
                  HapticFeedback.mediumImpact();
                  // TODO: Implement reminder functionality
                },
                isPrimary: false,
                color: statusColor,
              ),
              
              const SizedBox(width: AppDimensions.spacingMedium),
              
              // Track button
              _buildActionButton(
                theme,
                icon: Icons.near_me_rounded,
                label: 'Track',
                onTap: () {
                  HapticFeedback.mediumImpact();
                  // TODO: Implement tracking functionality
                },
                isPrimary: true,
                color: statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Information row with icon, label, and value
  Widget _buildInfoRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSmall),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSmall),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
  
  // Route visualization with animated line and stops
  Widget _buildRouteVisualization(Color statusColor, ThemeData theme) {
    return SizedBox(
      width: 24,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center line
          Positioned.fill(
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutQuart,
                builder: (context, value, child) {
                  return Container(
                    width: 2,
                    height: 120 * value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          statusColor,
                          Color.lerp(statusColor, theme.dividerColor, 0.5)!,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Current stop (top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.cardTheme.color ?? theme.colorScheme.surface,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Middle stop
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.lerp(statusColor, theme.dividerColor, 0.3)!,
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Destination stop (bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.lerp(statusColor, theme.dividerColor, 0.3)!,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.lerp(statusColor, theme.dividerColor, 0.5)!.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.flag_rounded,
                        size: 8,
                        color: Color.lerp(statusColor, theme.dividerColor, 0.3),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Action button with hover and press effects
  Widget _buildActionButton(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMedium,
            vertical: AppDimensions.spacingSmall,
          ),
          decoration: BoxDecoration(
            color: isPrimary ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            border: isPrimary 
                ? null 
                : Border.all(color: color, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isPrimary ? Colors.white : color,
              ),
              const SizedBox(width: AppDimensions.spacingExtraSmall),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isPrimary ? Colors.white : color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}