import 'package:flutter/material.dart';

/// Application-wide color constants
///
/// This class provides centralized color values for consistent
/// theming throughout the app with a modern, vibrant palette.
class AppColors {
  // Prevent instantiation
  AppColors._();
  
  // Primary colors - Modern vibrant blue
  static const Color primary = Color(0xFF3F51B5);      // Indigo
  static const Color primaryLight = Color(0xFF757DE8); // Light Indigo
  static const Color primaryDark = Color(0xFF303F9F);  // Dark Indigo
  
  // Secondary colors - Complementary coral accent
  static const Color secondary = Color(0xFFFF5252);       // Coral Red
  static const Color secondaryLight = Color(0xFFFF867F);  // Light Coral
  static const Color secondaryDark = Color(0xFFC50E29);   // Dark Coral
  
  // Status colors - More vibrant and modern
  static const Color success = Color(0xFF43A047);      // Rich Green
  static const Color warning = Color(0xFFFFB300);      // Amber
  static const Color error = Color(0xFFE53935);        // Bright Red
  static const Color info = Color(0xFF2196F3);         // Bright Blue
  
  // Light theme - Cleaner and more modern
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF5F7FA);   // Slightly blue tinted
  static const Color lightTextPrimary = Color(0xFF1F2937); // Darker for contrast
  static const Color lightTextSecondary = Color(0xFF6B7280); // Modern gray
  static const Color lightDivider = Color(0xFFE4E7EB);      // Subtle divider
  
  // Dark theme - Richer and less harsh
  static const Color darkBackground = Color(0xFF111827);   // Deep blue-gray
  static const Color darkSurface = Color(0xFF1F2937);      // Rich dark surface
  static const Color darkTextPrimary = Color(0xFFF9FAFB);  // Crisp white text
  static const Color darkTextSecondary = Color(0xFFD1D5DB); // Soft gray
  static const Color darkDivider = Color(0xFF374151);        // Subtle dark divider
  
  // Utility methods for opacity
  static Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
  static Color blackWithOpacity(double opacity) => Colors.black.withOpacity(opacity);
  static Color whiteWithOpacity(double opacity) => Colors.white.withOpacity(opacity);
  
  // Bus-related colors - More vibrant and distinguishable
  static const Color busEarlyColor = Color(0xFF66BB6A);      // Vibrant green
  static const Color busOnTimeColor = Color(0xFF3949AB);     // Indigo blue
  static const Color busLateColor = Color(0xFFFF9800);       // Bright orange
  static const Color busVeryLateColor = Color(0xFFE53935);   // Bright red
  
  // Bus schedule highlight colors - More vibrant and user-friendly
  static const Color busScheduleHighlightDark = Color(0xFF1A237E);   // Deep indigo
  static const Color busScheduleHighlight = Color(0xFF3F51B5);       // Indigo
  static const Color busScheduleHighlightLight = Color(0xFFE8EAF6);  // Light indigo
  static const Color busScheduleHighlightTextLight = Color(0xFF3F51B5); // Indigo text
  static const Color busScheduleHighlightTextDark = Color(0xFF9FA8DA);  // Light indigo text
  
  // New accent colors for various UI elements
  static const Color accentPurple = Color(0xFF9C27B0);       // Purple for special features
  static const Color accentTeal = Color(0xFF009688);         // Teal for secondary actions
  static const Color accentAmber = Color(0xFFFFC107);        // Amber for notifications
  
  // Gradient colors for beautiful backgrounds and buttons
  static const Color gradientStart = Color(0xFF3949AB);      // Start with indigo
  static const Color gradientEnd = Color(0xFF5C6BC0);        // End with lighter indigo
  static const Color gradientAccent = Color(0xFF7986CB);     // Accent for gradients
  
  // Shadow colors for elevated UI elements
  static const Color shadowLight = Color(0x1A000000);        // Light shadow
  static const Color shadowMedium = Color(0x26000000);       // Medium shadow
  static const Color shadowDark = Color(0x33000000);         // Dark shadow
}