import 'package:flutter/material.dart';

/// Centralized color constants for the entire application
class AppColors {
  // Primary color palette
  static const primary = Color(0xFF26A69A);
  static const secondary = Color(0xFFD4E157);
  
  // Background colors
  static const lightBackground = Colors.white;
  static const darkBackground = Color(0xFF212121);
  
  // Surface colors
  static const lightSurface = Colors.white;
  static const darkSurface = Color(0xFF303030);
  
  // Text colors
  static const lightTextPrimary = Colors.black87;
  static const darkTextPrimary = Colors.white;
  static const lightTextSecondary = Colors.black54;
  static const darkTextSecondary = Colors.white70;
  
  // Indicator and status colors
  static const busScheduleHighlight = Color(0xFF2E7D32);
  static const busScheduleHighlightLight = Color(0xFFC8E6C9);
  static const busScheduleHighlightDark = Color(0xFF1B5E20);
  static const busScheduleHighlightTextLight = Color(0xFF2E7D32);
  static const busScheduleHighlightTextDark = Color(0xFFA5D6A7);
  
  // Overlay colors
  static const overlayLight = Colors.black26;
  static const overlayMedium = Colors.black38;
  static const overlayShadow = Color(0x33000000); // 20% black
  
  // Other utilities
  static Color blackWithOpacity(double opacity) => Colors.black.withOpacity(opacity);
  static Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
}
