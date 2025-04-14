import 'dart:ui';
import 'dart:math' as math;

import 'package:busnow/core/rtl/translator_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/domain/models/bus_schedule_model.dart';
import 'package:busnow/domain/models/bus_stop_model.dart';
import 'package:busnow/presentation/providers/bus_providers.dart';
import 'package:busnow/presentation/widgets/bottom_sheets/bottom_sheet_handle.dart';
import 'package:busnow/presentation/widgets/bus/bus_stop_header.dart';
import 'package:busnow/presentation/widgets/bus/bus_schedule_list_view.dart';
import 'package:busnow/presentation/widgets/common/loading_state_view.dart';
import 'package:busnow/presentation/widgets/common/empty_state_view.dart';
import 'package:busnow/presentation/widgets/decorations/decorative_background_painter.dart';

/// An enhanced bottom sheet with beautiful animations and transitions
///
/// Features:
/// - Blur effect that intensifies as sheet expands
/// - Decorative background patterns and gradients
/// - Animated pull handle with dragging indicators
/// - Content animations synchronized with sheet movement
/// - States for empty, loading, and populated data
class EnhancedBottomSheet extends StatefulWidget {
  final Animation<double> animation;
  final BusStop? selectedBusStop;
  final List<BusStop> nearbyBusStops;
  final BusScheduleStateStatus status;
  final List<BusSchedule> busSchedules;
  final Map<String, int> earliestTimes;
  final VoidCallback onClose;
  final VoidCallback onRefresh;

  const EnhancedBottomSheet({
    Key? key,
    required this.animation,
    required this.selectedBusStop,
    this.nearbyBusStops = const [],
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
                      painter: DecorativeBackgroundPainter(
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
                    // Pull handle with animated indicator
                    BottomSheetHandle(
                      animation: widget.animation,
                      onTap:
                          widget.animation.value >= 0.9 ? _handleClose : null,
                    ),

                    // Expanded content area with animations
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(
                          milliseconds: AppDimensions.animDurationMedium,
                        ),
                        child:
                            widget.selectedBusStop == null
                                ? EmptyStateView(
                                  icon: Icons.touch_app_rounded,
                                  message: "Tap on a bus stop to see schedules",
                                )
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
                      opacity: (widget.animation.value - 0.8) * 5,
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
        BusStopHeader(
          animation: _contentAnimationController,
          title: _getSheetTitle(),
          busCount: widget.busSchedules.length,
          onRefresh: widget.onRefresh,
          isLoading: widget.status == BusScheduleStateStatus.loading,
        ),

        // Bus schedule list with loading state and empty state handling
        Expanded(
          child:
              widget.status == BusScheduleStateStatus.loading
                  ? LoadingStateView(
                    message: L10n.of(context).findingBuses,
                    size: AppDimensions.iconSizeExtraLarge,
                    useBusAnimation: true,
                  )
                  : widget.busSchedules.isEmpty
                  ? EmptyStateView(
                    icon: Icons.directions_bus_outlined,
                    message: L10n.of(context).noBusesYet,
                    actionLabel: L10n.of(context).tapToRefresh,
                  )
                  : BusScheduleListView(
                    scrollController: _scrollController,
                    contentAnimation: _contentAnimationController,
                    scheduleGroups:
                        widget.selectedBusStop != null
                            ? BusScheduleState(
                              busSchedules: widget.busSchedules,
                            ).getGroupedSchedules()
                            : [],
                  ),
        ),
      ],
    );
  }
}
