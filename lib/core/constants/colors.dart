import 'package:flutter/material.dart';

/// Application-wide color constants
///
/// This class provides centralized color values for consistent
/// theming throughout the app.
class AppColors {
  // Prevent instantiation
  AppColors._();
  
  // Primary colors
  static const Color primary = Color(0xFF26A69A);
  static const Color primaryLight = Color(0xFF64D8CB);
  static const Color primaryDark = Color(0xFF00766C);
  
  // Secondary colors
  static const Color secondary = Color(0xFFD4E157);
  static const Color secondaryLight = Color(0xFFF9FBE7);
  static const Color secondaryDark = Color(0xFFAFB42B);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  // Light theme
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightDivider = Color(0xFFE0E0E0);
  
  // Dark theme
  static const Color darkBackground = Color(0xFF212121);
  static const Color darkSurface = Color(0xFF303030);
  static const Color darkTextPrimary = Color(0xFFEEEEEE);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF424242);
  
  // Utility methods for opacity
  static Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
  static Color blackWithOpacity(double opacity) => Colors.black.withOpacity(opacity);
  static Color whiteWithOpacity(double opacity) => Colors.white.withOpacity(opacity);
  
  // Bus-related colors
  static const Color busEarlyColor = Color(0xFF8BC34A);  // Light green
  static const Color busOnTimeColor = Color(0xFF26A69A); // Teal
  static const Color busLateColor = Color(0xFFFF9800);   // Orange
  static const Color busVeryLateColor = Color(0xFFF44336);

  static var busScheduleHighlightDark;

  static var busScheduleHighlight;

  static Color? busScheduleHighlightLight;

  static var busScheduleHighlightTextLight;

  static var busScheduleHighlightTextDark; // Red
}
