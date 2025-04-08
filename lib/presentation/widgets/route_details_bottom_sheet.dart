import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/presentation/widgets/bus_schedule_card.dart';
import 'package:busnow/presentation/widgets/animated_time_display.dart';

/// A beautifully designed bottom sheet for showing route details
///
/// Features:
/// - Elegant, modern design with smooth animations
/// - Backdrop blur effect for depth
/// - Interactive route map preview with parallax scrolling
/// - Smooth physics and gesture interactions
/// - Decorative wave patterns in background
class RouteDetailsBottomSheet extends StatefulWidget {
  final String routeName;
  final String routeNumber;
  final List<Map<String, dynamic>> schedules;
  final VoidCallback? onClose;
  
  const RouteDetailsBottomSheet({
    Key? key,
    required this.routeName,
    required this.routeNumber,
    required this.schedules,
    this.onClose,
  }) : super(key: key);
  
  /// Shows the bottom sheet with a beautiful animation
  static Future<void> show(
    BuildContext context, {
    required String routeName,
    required String routeNumber,
    required List<Map<String, dynamic>> schedules,
    VoidCallback? onClose,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.blackWithOpacity(0.5),
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
        vsync: Navigator.of(context),
      ),
      builder: (context) => RouteDetailsBottomSheet(
        routeName: routeName,
        routeNumber: routeNumber,
        schedules: schedules,
        onClose: onClose,
      ),
    );
  }

  @override
  State<RouteDetailsBottomSheet> createState() => _RouteDetailsBottomSheetState();
}

class _RouteDetailsBottomSheetState extends State<RouteDetailsBottomSheet> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sheetAnimation;
  late Animation<double> _fadeAnimation;
  
  int _expandedCardIndex = -1;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
    );
    
    _sheetAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    // Start the animation when the widget is inserted into the tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// Builds the pull handle at the top of the bottom sheet
  Widget _buildPullHandle() {
    return Container(
      width: AppDimensions.pullHandleWidth,
      height: AppDimensions.pullHandleHeight,
      margin: const EdgeInsets.only(
        top: AppDimensions.spacingMedium,
        bottom: AppDimensions.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.darkDivider
            : AppColors.lightDivider,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
      ),
    );
  }
  
  /// Builds the header section of the bottom sheet
  Widget _buildHeader() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLarge,
        vertical: AppDimensions.spacingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Route number circle with pulsing animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, _) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: AppDimensions.busNumberCircleSize + 4,
                      height: AppDimensions.busNumberCircleSize + 4,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.gradientEnd,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.routeNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: AppDimensions.textSizeMedium,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(width: AppDimensions.spacingMedium),
              
              // Route name and details with animated entrance
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(20 * (1 - value), 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.routeName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppDimensions.spacingExtraSmall),
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_bus_rounded, 
                                  size: 14, 
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.schedules.length} upcoming buses',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Close button with scale animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (context, value, _) {
                  return Transform.scale(
                    scale: value,
                    child: IconButton(
                      onPressed: () {
                        _animationController.reverse().then((_) {
                          Navigator.of(context).pop();
                          if (widget.onClose != null) {
                            widget.onClose!();
                          }
                        });
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.light
                            ? AppColors.lightSurface
                            : AppColors.darkSurface.withOpacity(0.7),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacingMedium),
          
          // Animated route map preview with parallax effect
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.12),
                          AppColors.primary.withOpacity(0.04),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 4,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                      child: Stack(
                        children: [
                          // Background map pattern
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _MapPatternPainter(
                                color: AppColors.primary.withOpacity(0.15),
                                animationValue: value,
                              ),
                            ),
                          ),
                          
                          // Route line
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: 40,
                            child: _buildRoutePathVisualization(value),
                          ),
                          
                          // Map interactions overlay
                          Positioned.fill(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.map_outlined,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                  const SizedBox(height: AppDimensions.spacingSmall),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.spacingMedium,
                                      vertical: AppDimensions.spacingExtraSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.brightness == Brightness.light 
                                          ? Colors.white.withOpacity(0.8)
                                          : AppColors.darkSurface.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                                    ),
                                    child: Text(
                                      'View Full Route Map',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Interactive button overlay (invisible but clickable)
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // Show a snackbar message when tapped
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Opening route map...'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                                      ),
                                      action: SnackBarAction(
                                        label: 'DISMISS',
                                        onPressed: () {},
                                      ),
                                    ),
                                  );
                                },
                                splashColor: AppColors.primary.withOpacity(0.1),
                                highlightColor: Colors.transparent,
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
          ),
          
          const SizedBox(height: AppDimensions.spacingLarge),
          
          // Animated section title with sliding entrance
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(30 * (1 - value), 0),
                  child: Row(
                    children: [
                      Text(
                        'Upcoming Buses',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingSmall,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${widget.schedules.length}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
        ],
      ),
    );
  }
  
  /// Builds the list of bus schedules with staggered animations
  Widget _buildScheduleList() {
    // Controller for staggered animations
    return ListView.builder(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spacingExtraLarge,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.schedules.length,
      itemBuilder: (context, index) {
        final schedule = widget.schedules[index];
        
        // Create a DateTime for arrival time
        final now = DateTime.now();
        final delayMinutes = schedule['delay'] as int? ?? 0;
        final arrivalTime = DateTime(
          now.year, 
          now.month, 
          now.day, 
          now.hour, 
          now.minute + 5 + index * 10 + delayMinutes,
        );
        
        // Calculate staggered animation delay
        final animationDelay = index * 0.1;
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            // Apply staggered delay to each card
            final adjustedValue = ((value * 1.3) - animationDelay).clamp(0.0, 1.0);
            
            return Opacity(
              opacity: adjustedValue,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - adjustedValue)),
                child: child!,
              ),
            );
          },
          child: BusScheduleCard(
            busNumber: widget.routeNumber,
            destination: schedule['destination'] as String,
            arrivalTime: arrivalTime,
            delay: Duration(minutes: delayMinutes),
            isExpanded: _expandedCardIndex == index,
            onTap: () {
              setState(() {
                if (_expandedCardIndex == index) {
                  _expandedCardIndex = -1;
                } else {
                  _expandedCardIndex = index;
                }
              });
            },
            isLoading: schedule['loading'] as bool? ?? false,
          ),
        );
      },
    );
  }

  /// Creates a beautiful route visualization with animated stops
  Widget _buildRoutePathVisualization(double animationValue) {
    return Container(
      width: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Starting point
          AnimatedStopMarker(
            color: AppColors.primary,
            filled: true, 
            animationDelay: 0.0,
            initialAnimationValue: animationValue,
          ),
          
          // Route line with animated drawing effect
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Container(
                height: 70 * value * animationValue,
                width: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.gradientEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
                ),
              );
            },
          ),
          
          // Middle stop
          AnimatedStopMarker(
            color: AppColors.primary,
            filled: false,
            animationDelay: 0.3,
            initialAnimationValue: animationValue,
          ),
          
          // Route line with animated drawing effect (2nd segment)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              final adjustedValue = (animationValue - 0.3).clamp(0.0, 1.0) / 0.7;
              return Container(
                height: 60 * value * adjustedValue,
                width: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.gradientEnd,
                      AppColors.secondary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
                ),
              );
            },
          ),
          
          // Destination point
          AnimatedStopMarker(
            color: AppColors.secondary,
            filled: true,
            animationDelay: 0.6,
            initialAnimationValue: animationValue,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final sheetHeight = mediaQuery.size.height * AppDimensions.bottomSheetHeight * _sheetAnimation.value + bottomPadding;
        
        return Positioned(
          height: sheetHeight,
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              // Calculate new animation value based on drag
              final newValue = _animationController.value - (details.primaryDelta! / (mediaQuery.size.height * AppDimensions.bottomSheetHeight));
              _animationController.value = newValue.clamp(0.0, 1.0);
            },
            onVerticalDragEnd: (details) {
              // Complete the animation based on velocity
              if (details.primaryVelocity! > 500 || _animationController.value < 0.3) {
                _animationController.reverse().then((_) {
                  Navigator.of(context).pop();
                  if (widget.onClose != null) {
                    widget.onClose!();
                  }
                });
              } else if (details.primaryVelocity! < -500 || _animationController.value > 0.7) {
                _animationController.forward();
              } else if (_animationController.value < 0.5) {
                _animationController.reverse().then((_) {
                  Navigator.of(context).pop();
                  if (widget.onClose != null) {
                    widget.onClose!();
                  }
                });
              } else {
                _animationController.forward();
              }
            },
            child: Stack(
              children: [
                // Backdrop blur effect
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: 10 * _fadeAnimation.value,
                      sigmaY: 10 * _fadeAnimation.value,
                    ),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                
                // Main sheet content with gradient background
                Positioned.fill(
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.brightness == Brightness.light
                                ? AppColors.lightSurface
                                : AppColors.darkSurface,
                            theme.brightness == Brightness.light
                                ? Color.lerp(AppColors.lightSurface, AppColors.primary.withOpacity(0.05), 0.15)!
                                : Color.lerp(AppColors.darkSurface, AppColors.primary.withOpacity(0.15), 0.2)!,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppDimensions.borderRadiusLarge),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowMedium,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppDimensions.borderRadiusLarge),
                        ),
                        child: CustomPaint(
                          painter: _SheetBackgroundPainter(
                            color: AppColors.primary.withOpacity(0.03),
                            animationValue: _fadeAnimation.value,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Pull handle with pulsing animation
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.95, end: 1.05),
                                duration: const Duration(milliseconds: 1500),
                                curve: Curves.easeInOut,
                                builder: (context, scaleValue, child) {
                                  return Transform.scale(
                                    scale: _fadeAnimation.value * (1.0 + (scaleValue - 1.0) * 0.3),
                                    child: Container(
                                      width: AppDimensions.pullHandleWidth,
                                      height: AppDimensions.pullHandleHeight,
                                      margin: const EdgeInsets.only(
                                        top: AppDimensions.spacingMedium,
                                        bottom: AppDimensions.spacingMedium,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.brightness == Brightness.light
                                            ? AppColors.darkDivider
                                            : AppColors.lightDivider,
                                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
                                      ),
                                    ),
                                  );
                                },
                                onEnd: () => setState(() {}),
                              ),
                              
                              // Content
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildHeader(),
                                      _buildScheduleList(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Animated marker for bus stops in the route visualization
class AnimatedStopMarker extends StatelessWidget {
  final Color color;
  final bool filled;
  final double animationDelay;
  final double initialAnimationValue;
  
  const AnimatedStopMarker({
    Key? key,
    required this.color,
    required this.filled,
    required this.animationDelay,
    required this.initialAnimationValue,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Calculate adjusted animation value based on delay
    final adjustedValue = (initialAnimationValue - animationDelay).clamp(0.0, 1.0) / (1.0 - animationDelay);
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, _) {
        return Transform.scale(
          scale: value * adjustedValue,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: filled ? color : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Decorative painter that creates a subtle map pattern background
class _MapPatternPainter extends CustomPainter {
  final Color color;
  final double animationValue;
  
  _MapPatternPainter({
    required this.color,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Create a grid pattern for the map background
    final gridSize = 20.0;
    final horizontalLines = (size.height / gridSize).ceil();
    final verticalLines = (size.width / gridSize).ceil();
    
    // Draw horizontal grid lines
    for (int i = 0; i < horizontalLines; i++) {
      final y = i * gridSize;
      final path = Path();
      
      // Create wavy horizontal lines
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += gridSize) {
        final waveHeight = 2.0 * (i % 2 == 0 ? 1 : -1);
        final controlPoint1 = Offset(x + gridSize / 3, y + waveHeight);
        final controlPoint2 = Offset(x + 2 * gridSize / 3, y - waveHeight);
        final endPoint = Offset(x + gridSize, y);
        
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          endPoint.dx, endPoint.dy,
        );
      }
      
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.3 * animationValue)
          ..style = paint.style
          ..strokeWidth = paint.strokeWidth,
      );
    }
    
    // Draw vertical grid lines
    for (int i = 0; i < verticalLines; i++) {
      final x = i * gridSize;
      final path = Path();
      
      // Create wavy vertical lines
      path.moveTo(x, 0);
      for (double y = 0; y < size.height; y += gridSize) {
        final waveWidth = 2.0 * (i % 2 == 0 ? 1 : -1);
        final controlPoint1 = Offset(x + waveWidth, y + gridSize / 3);
        final controlPoint2 = Offset(x - waveWidth, y + 2 * gridSize / 3);
        final endPoint = Offset(x, y + gridSize);
        
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          endPoint.dx, endPoint.dy,
        );
      }
      
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.3 * animationValue)
          ..style = paint.style
          ..strokeWidth = paint.strokeWidth,
      );
    }
    
    // Draw random decorative "streets"
    final random = math.Random(42); // Fixed seed for consistent randomness
    final numStreets = 5;
    
    for (int i = 0; i < numStreets; i++) {
      final streetPath = Path();
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      
      streetPath.moveTo(startX, startY);
      
      // Create a random street path with 3-5 segments
      var currentX = startX;
      var currentY = startY;
      final segments = 3 + random.nextInt(3);
      
      for (int j = 0; j < segments; j++) {
        // Decide if this segment is horizontal or vertical
        final isHorizontal = random.nextBool();
        
        if (isHorizontal) {
          final endX = currentX + (random.nextDouble() * 60 - 30) * gridSize / 10;
          streetPath.lineTo(endX, currentY);
          currentX = endX;
        } else {
          final endY = currentY + (random.nextDouble() * 60 - 30) * gridSize / 10;
          streetPath.lineTo(currentX, endY);
          currentY = endY;
        }
      }
      
      canvas.drawPath(
        streetPath, 
        Paint()
          ..color = color.withOpacity(0.5 * animationValue)
          ..style = paint.style
          ..strokeWidth = 2.0
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Decorative background painter that creates beautiful wave patterns
class _SheetBackgroundPainter extends CustomPainter {
  final Color color;
  final double animationValue;
  
  _SheetBackgroundPainter({
    required this.color,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Draw decorative curved patterns
    final path1 = Path();
    final path2 = Path();
    
    // First wave pattern
    path1.moveTo(0, size.height * 0.15);
    path1.quadraticBezierTo(
      size.width * 0.25,
      size.height * (0.15 + 0.05 * animationValue),
      size.width * 0.5,
      size.height * 0.15,
    );
    path1.quadraticBezierTo(
      size.width * 0.75,
      size.height * (0.15 - 0.05 * animationValue),
      size.width,
      size.height * 0.15,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    
    // Second wave pattern
    path2.moveTo(0, size.height * 0.3);
    path2.quadraticBezierTo(
      size.width * 0.25,
      size.height * (0.3 - 0.08 * animationValue),
      size.width * 0.5,
      size.height * 0.3,
    );
    path2.quadraticBezierTo(
      size.width * 0.75,
      size.height * (0.3 + 0.08 * animationValue),
      size.width,
      size.height * 0.3,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    
    canvas.drawPath(
      path1,
      Paint()
        ..color = color.withOpacity(0.7 * animationValue)
        ..style = paint.style
        ..strokeWidth = paint.strokeWidth,
    );
    canvas.drawPath(
      path2,
      Paint()
        ..color = color.withOpacity(0.5 * animationValue)
        ..style = paint.style
        ..strokeWidth = paint.strokeWidth,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
