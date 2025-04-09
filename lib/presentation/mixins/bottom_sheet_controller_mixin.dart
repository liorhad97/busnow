import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:busnow/core/constants/dimensions.dart';

/// A mixin for controlling bottom sheet animations and state
///
/// This mixin provides functionality for:
/// - Initializing and disposing bottom sheet controllers
/// - Expanding and collapsing bottom sheets with proper animations
/// - Handling state updates consistently across animations
mixin BottomSheetControllerMixin
    on State<StatefulWidget>, TickerProviderStateMixin {
  // Animation controller for the bottom sheet
  late AnimationController bottomSheetController;

  // State tracking
  bool isBottomSheetExpanded = false;

  // Standard heights for the bottom sheet
  final double collapsedSheetHeight = 120.0;
  final double expandedSheetHeight = 0.45; // 45% of screen height

  /// Initialize the bottom sheet controller
  void initializeBottomSheetController() {
    bottomSheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
      value: 0.0, // Start collapsed
    );
  }

  /// Dispose of the bottom sheet controller
  void disposeBottomSheetController() {
    bottomSheetController.dispose();
  }

  /// Expand the bottom sheet with animation
  void expandBottomSheet() {
    setState(() {
      isBottomSheetExpanded = true;
    });
    bottomSheetController.forward();

    // Optional haptic feedback
    HapticFeedback.lightImpact();
  }

  /// Collapse the bottom sheet with animation
  void collapseBottomSheet() {
    // Use a complete callback to ensure proper state update after animation completes
    bottomSheetController.reverse().then((_) {
      if (mounted) {
        setState(() {
          isBottomSheetExpanded = false;
        });
      }
    });

    // Update state immediately to prevent UI inconsistency during animation
    setState(() {
      isBottomSheetExpanded = false;
    });

    // Optional haptic feedback
    HapticFeedback.lightImpact();
  }

  /// Toggle bottom sheet expansion state
  void toggleBottomSheet() {
    if (isBottomSheetExpanded) {
      collapseBottomSheet();
    } else {
      expandBottomSheet();
    }
  }

  /// Calculate the actual height of the bottom sheet based on animation value
  double calculateSheetHeight(Size screenSize) {
    return bottomSheetController.value > 0
        ? collapsedSheetHeight +
            (bottomSheetController.value *
                (screenSize.height * expandedSheetHeight -
                    collapsedSheetHeight))
        : 0;
  }

  /// Handle a vertical drag to update the bottom sheet position
  void handleBottomSheetDrag(DragUpdateDetails details, Size screenSize) {
    // Convert drag to animation value
    final newValue =
        bottomSheetController.value -
        (details.primaryDelta! /
            ((screenSize.height * expandedSheetHeight) - collapsedSheetHeight));
    bottomSheetController.value = newValue.clamp(0.0, 1.0);
  }

  /// Handle the end of a vertical drag to animate to correct position
  void handleBottomSheetDragEnd(DragEndDetails details) {
    if (details.primaryVelocity! > 500 || bottomSheetController.value < 0.3) {
      collapseBottomSheet();
    } else if (details.primaryVelocity! < -500 ||
        bottomSheetController.value > 0.7) {
      expandBottomSheet();
    } else {
      if (bottomSheetController.value > 0.5) {
        expandBottomSheet();
      } else {
        collapseBottomSheet();
      }
    }
  }
}
