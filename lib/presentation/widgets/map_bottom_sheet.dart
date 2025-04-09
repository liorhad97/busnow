import 'dart:ui';
import 'dart:math' as math;

import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/domain/models/bus_schedule_model.dart';
import 'package:busnow/domain/models/bus_stop_model.dart';
import 'package:busnow/presentation/providers/bus_providers.dart';
import 'package:busnow/presentation/widgets/animated_loading_indicator.dart';
import 'package:busnow/presentation/widgets/bus_refresh_button.dart';
import 'package:busnow/presentation/widgets/bus_schedule_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnhancedBottomSheet extends StatefulWidget {
  final Animation<double> animation;
  final BusStop? selectedBusStop;
  final List<BusStop> nearbyBusStops; // Add this line
  final BusScheduleStateStatus status;
  final List<BusSchedule> busSchedules;
  final Map<String, int> earliestTimes;
  final VoidCallback onClose;
  final VoidCallback onRefresh;

  const EnhancedBottomSheet({
    Key? key,
    required this.animation,
    required this.selectedBusStop,
    this.nearbyBusStops = const [], // Add this line with default value
    required this.status,
    required this.busSchedules,
    required this.earliestTimes,
    required this.onClose,
    required this.onRefresh,
  }) : super(key: key);
  @override
  State<EnhancedBottomSheet> createState() => _EnhancedBottomSheetState();
}

class _EnhancedBottomSheetState extends State<EnhancedBottomSheet>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _contentAnimationController;

  // Track scroll position for parallax effects
  double _scrollOffset = 0;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
    );

    widget.animation.addListener(_onSheetAnimationChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _contentAnimationController.dispose();
    widget.animation.removeListener(_onSheetAnimationChanged);
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      _isScrolling = true;
    });

    // Reset isScrolling flag after a delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isScrolling = false;
        });
      }
    });
  }

  // Add this method to _EnhancedBottomSheetState class
  String _getSheetTitle() {
    if (widget.nearbyBusStops.isEmpty) {
      return widget.selectedBusStop?.name ?? "No Bus Stop Selected";
    }

    // Combine names of nearby bus stops
    final stopNames = widget.nearbyBusStops.map((stop) => stop.name).toList();
    if (stopNames.length > 2) {
      return "${stopNames[0]} + ${stopNames[1]} + ...";
    } else {
      return stopNames.join(" + ");
    }
  }

  void _onSheetAnimationChanged() {
    // Animate content when sheet expands
    if (widget.animation.value > 0.5 &&
        !_contentAnimationController.isCompleted) {
      _contentAnimationController.forward();
    } else if (widget.animation.value < 0.3 &&
        _contentAnimationController.value > 0) {
      _contentAnimationController.reverse();
    }
  }

  // Handle closing the sheet
  void _handleClose() {
    HapticFeedback.lightImpact();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    // Calculate dynamic blur and shadow based on animation value
    final blurAmount = lerpDouble(0, 15, widget.animation.value) ?? 0.0;

    return GestureDetector(
      // Add a swipe down gesture to close the sheet
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          _handleClose();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            lerpDouble(
                  AppDimensions.borderRadiusLarge,
                  AppDimensions.borderRadiusMedium,
                  widget.animation.value,
                ) ??
                AppDimensions.borderRadiusLarge,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.97),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                  lerpDouble(
                        AppDimensions.borderRadiusLarge,
                        AppDimensions.borderRadiusMedium,
                        widget.animation.value,
                      ) ??
                      AppDimensions.borderRadiusLarge,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowMedium,
                  blurRadius:
                      lerpDouble(10, 20, widget.animation.value) ?? 10.0,
                  spreadRadius: lerpDouble(1, 5, widget.animation.value) ?? 1.0,
                  offset: Offset(
                    0,
                    lerpDouble(-2, -5, widget.animation.value) ?? -2.0,
                  ),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative background patterns
                Positioned.fill(
                  child: Opacity(
                    opacity: widget.animation.value * 0.15,
                    child: CustomPaint(
                      painter: _DecorativeBackgroundPainter(
                        primaryColor: AppColors.primary,
                        secondaryColor:
                            isDarkMode
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                        animationValue: widget.animation.value,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  ),
                ),

                // Animated gradient background for extra flavor
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: widget.animation.value * 0.2,
                    duration: const Duration(
                      milliseconds: AppDimensions.animDurationShort,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(
                            0.5 +
                                0.5 *
                                    math.sin(
                                      DateTime.now().millisecondsSinceEpoch /
                                          10000,
                                    ),
                            -0.2 +
                                0.2 *
                                    math.cos(
                                      DateTime.now().millisecondsSinceEpoch /
                                          8000,
                                    ),
                          ),
                          colors: [
                            AppColors.primary.withOpacity(0.15),
                            AppColors.primaryLight.withOpacity(0.05),
                            Colors.transparent,
                          ],
                          radius: mediaQuery.size.width * 0.8,
                        ),
                      ),
                    ),
                  ),
                ),

                // Main content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Pull handle with animated indicator and close functionality
                    _buildPullHandle(theme),

                    // Expanded content area with animations
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(
                          milliseconds: AppDimensions.animDurationMedium,
                        ),
                        child:
                            widget.selectedBusStop == null
                                ? _buildEmptyState(theme)
                                : _buildContentArea(theme),
                      ),
                    ),
                  ],
                ),

                // Shine effect that moves with scrolling and animations
                if (widget.animation.value > 0.5)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: true,
                      child: AnimatedOpacity(
                        opacity: _isScrolling ? 0.3 : 0,
                        duration: const Duration(
                          milliseconds: AppDimensions.animDurationShort,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.0),
                              ],
                              stops: [
                                0.0,
                                0.5 + (_scrollOffset / 1000).clamp(0.0, 0.5),
                                1.0,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Close button in the top right when fully expanded
                if (widget.animation.value > 0.8)
                  Positioned(
                    top: AppDimensions.spacingMedium,
                    right: AppDimensions.spacingMedium,
                    child: AnimatedOpacity(
                      opacity:
                          (widget.animation.value - 0.8) *
                          5, // Fade in as animation progresses past 0.8
                      duration: const Duration(
                        milliseconds: AppDimensions.animDurationShort,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleClose,
                          customBorder: const CircleBorder(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant
                                  .withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: AppDimensions.iconSizeSmall,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
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
  }

  // Beautifully animated pull handle
  Widget _buildPullHandle(ThemeData theme) {
    return GestureDetector(
      onTap:
          widget.animation.value >= 0.9
              ? _handleClose
              : null, // Tap on handle to close when expanded
      child: SizedBox(
        height: 40,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shadow layer
              Container(
                width: AppDimensions.pullHandleWidth + 2,
                height: AppDimensions.pullHandleHeight + 2,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusCircular,
                  ),
                ),
              ),

              // Main handle
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 1.0,
                  end: widget.animation.value < 0.5 ? 1.0 : 1.2,
                ),
                duration: const Duration(
                  milliseconds: AppDimensions.animDurationMedium,
                ),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: AppDimensions.pullHandleWidth,
                      height: AppDimensions.pullHandleHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            theme.colorScheme.onSurface.withOpacity(0.2),
                            theme.colorScheme.onSurface.withOpacity(0.3),
                            theme.colorScheme.onSurface.withOpacity(0.2),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusCircular,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Animated dot indicators for drag up when collapsed
              if (widget.animation.value < 0.5)
                Positioned(
                  top: -14,
                  child: Column(
                    children: [
                      _buildPulsingDot(0),
                      SizedBox(height: 3),
                      _buildPulsingDot(100),
                      SizedBox(height: 3),
                      _buildPulsingDot(200),
                    ],
                  ),
                ),

              // Animated dot indicators for drag down when expanded
              if (widget.animation.value > 0.9)
                Positioned(
                  bottom: -14,
                  child: Column(
                    children: [
                      _buildPulsingDot(200),
                      SizedBox(height: 3),
                      _buildPulsingDot(100),
                      SizedBox(height: 3),
                      _buildPulsingDot(0),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulsingDot(int delayMillis) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: math.sin(math.pi * value + (delayMillis / 1000)).abs(),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  // Main content area with bus stop and schedule information
  Widget _buildContentArea(ThemeData theme) {
    // Early return if no bus stop is selected
    if (widget.selectedBusStop == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bus stop header with animations
        AnimatedBuilder(
          animation: _contentAnimationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - _contentAnimationController.value)),
              child: Opacity(
                opacity: _contentAnimationController.value,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingLarge,
              0,
              AppDimensions.spacingLarge,
              AppDimensions.spacingExtraSmall,
            ),
            child: Row(
              children: [
                // Glow effect on bus icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.directions_bus_rounded,
                    color: AppColors.primary,
                    size: AppDimensions.iconSizeMedium,
                  ),
                ),

                const SizedBox(width: AppDimensions.spacingMedium),

                // Bus stop name and info with layout animation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getSheetTitle(), // Replace widget.selectedBusStop!.name with this
                        style: theme.textTheme.headlineSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingSmall,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusCircular,
                              ),
                            ),
                            child: Text(
                              "${widget.busSchedules.length} Buses",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(width: AppDimensions.spacingSmall),

                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),

                          const SizedBox(width: 2),

                          Text(
                            "Live Updates",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Refresh button with haptic feedback
                BusRefreshButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onRefresh();
                  },
                  isLoading: widget.status == BusScheduleStateStatus.loading,
                  enableHaptics: true,
                ),
              ],
            ),
          ),
        ),

        // Bus schedule list with loading state and empty state handling
        Expanded(
          child:
              widget.status == BusScheduleStateStatus.loading
                  ? Center(
                    child: AnimatedLoadingIndicator(
                      type: AnimationType.pulse,
                      message: "Finding buses...",
                    ),
                  )
                  : widget.busSchedules.isEmpty
                  ? _buildNoSchedulesState(theme)
                  : _buildScheduleList(theme),
        ),
      ],
    );
  }

  // Beautifully animated schedule list with staggered entrance
  Widget _buildScheduleList(ThemeData theme) {
    return AnimatedBuilder(
      animation: _contentAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _contentAnimationController.value,
          child: child,
        );
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacingMedium,
          AppDimensions.spacingSmall,
          AppDimensions.spacingMedium,
          AppDimensions.spacingLarge,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: widget.busSchedules.length,
        itemBuilder: (context, index) {
          final schedule = widget.busSchedules[index];
          final isEarliest =
              widget.earliestTimes[schedule.busNumber] ==
              schedule.arrivalTimeInMinutes;

          // Create a staggered animation for each item
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(
              milliseconds: AppDimensions.animDurationMedium + (index * 50),
            ),
            curve: Curves.easeOutQuart,
            builder: (context, value, child) {
              // Only animate once content animation is active
              final adjustedValue = value * _contentAnimationController.value;

              return Transform.translate(
                offset: Offset(0, 20 * (1 - adjustedValue)),
                child: Opacity(opacity: adjustedValue, child: child),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.spacingSmall,
              ),
              child: BusScheduleItem(
                schedule: schedule,
                isEarliest: isEarliest,
              ),
            ),
          );
        },
      ),
    );
  }

  // Empty state when bottom sheet is first shown (no bus stop selected)
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.touch_app_rounded,
                    size: AppDimensions.iconSizeLarge,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppDimensions.spacingMedium),

          // Animated text
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingLarge,
              ),
              child: Text(
                "Tap on a bus stop to see schedules",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingMedium),
        ],
      ),
    );
  }

  // Empty state when bus stop is selected but no schedules are available
  Widget _buildNoSchedulesState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated bus icon
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.9, end: 1.1),
            duration: const Duration(milliseconds: 2000),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale * _contentAnimationController.value,
                child: Opacity(
                  opacity: _contentAnimationController.value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_bus_outlined,
                      size: AppDimensions.iconSizeExtraLarge,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppDimensions.spacingMedium),

          // Animated text with slightly delayed entrance
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              final adjustedValue = (value * _contentAnimationController.value)
                  .clamp(0.0, 1.0);

              return Opacity(
                opacity: adjustedValue,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - adjustedValue)),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Text(
                  "No buses yet—check back soon!",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingMedium),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMedium,
                    vertical: AppDimensions.spacingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withOpacity(
                      0.7,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusMedium,
                    ),
                  ),
                  child: Text(
                    "Tap refresh to check again",
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative background painter for enhanced visual appeal
class _DecorativeBackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double animationValue;
  final bool isDarkMode;

  _DecorativeBackgroundPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.animationValue,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a grid pattern with circles and lines
    final double spacing = 40.0;
    final int horizontalCount = (size.width / spacing).ceil() + 1;
    final int verticalCount = (size.height / spacing).ceil() + 1;

    // Draw connecting lines first
    final linePaint =
        Paint()
          ..color = (isDarkMode ? Colors.white : Colors.black).withOpacity(
            0.03 * animationValue,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

    // Create a path for the lines
    final path = Path();

    // Draw dynamic curved paths for extra visual interest
    for (int i = 0; i < 5; i++) {
      final offset = i * 0.2;
      final control1x = size.width * (0.2 + offset);
      final control1y = size.height * (0.1 + offset * 0.5);
      final control2x = size.width * (0.8 - offset);
      final control2y = size.height * (0.5 + offset * 0.3);

      path.moveTo(0, size.height * (0.3 + offset * 0.2));
      path.cubicTo(
        control1x,
        control1y,
        control2x,
        control2y,
        size.width,
        size.height * (0.7 - offset * 0.1),
      );
    }

    canvas.drawPath(path, linePaint);

    // Create another path for diagonal flowing lines
    final flowPath = Path();

    for (int i = 0; i < 3; i++) {
      final offset = i * 0.3;
      flowPath.moveTo(size.width * offset, 0);
      flowPath.quadraticBezierTo(
        size.width * (0.5 + offset * 0.2),
        size.height * (0.5 + offset * 0.1),
        size.width * (1 - offset),
        size.height,
      );
    }

    canvas.drawPath(
      flowPath,
      Paint()
        ..color = primaryColor.withOpacity(0.03 * animationValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Draw small dots in a grid pattern
    final dotRadius = 1.5;
    final dotPaint =
        Paint()
          ..color = secondaryColor.withOpacity(0.1 * animationValue)
          ..style = PaintingStyle.fill;

    for (int x = 0; x < horizontalCount; x++) {
      for (int y = 0; y < verticalCount; y++) {
        // Skip some dots randomly for more organic look
        if ((x + y) % 3 == 0) continue;

        final xPos = x * spacing;
        final yPos = y * spacing;

        canvas.drawCircle(Offset(xPos, yPos), dotRadius, dotPaint);
      }
    }

    // Draw a few larger circles for accent
    final accentPaint =
        Paint()
          ..color = primaryColor.withOpacity(0.05 * animationValue)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      30 * animationValue,
      accentPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      40 * animationValue,
      accentPaint,
    );

    // Add a subtle wave
    // Add a subtle wave at the bottom
    final wavePaint =
        Paint()
          ..color = primaryColor.withOpacity(0.07 * animationValue)
          ..style = PaintingStyle.fill;

    final wavePath = Path();
    wavePath.moveTo(0, size.height);

    // Create a gentle wave pattern
    final waveHeight = 40.0 * animationValue;
    final segments = 4;
    final segmentWidth = size.width / segments;

    for (int i = 0; i <= segments; i++) {
      final x = i * segmentWidth;
      final y = size.height - (i.isEven ? 0 : waveHeight);

      if (i == 0) {
        wavePath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * segmentWidth;
        final prevY = size.height - ((i - 1).isEven ? 0 : waveHeight);

        // Use quadratic bezier curve for smooth wave
        final controlX = (prevX + x) / 2;
        final controlY = prevY > y ? size.height : size.height - waveHeight;

        wavePath.quadraticBezierTo(controlX, controlY, x, y);
      }
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
