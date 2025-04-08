/// Application-wide dimension constants
///
/// This class provides centralized dimension values for consistent
/// spacing, sizing, and animations throughout the app.
class AppDimensions {
  // Prevent instantiation
  AppDimensions._();
  
  // Spacing
  static const double spacingExtraSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;
  
  // Border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 24.0;
  
  // Animation durations in milliseconds
  static const int animDurationShort = 150;
  static const int animDurationMedium = 300;
  static const int animDurationLong = 500;
  static const int animDurationLoading = 2000;
  
  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 60.0;
  
  // Map specific
  static const double mapInitialZoom = 14.0;
  static const double mapDetailedZoom = 16.0;
  
  // Bottom sheet
  static const double bottomSheetHeight = 0.45; // Reduced from 0.65 to take less screen space
  static const double pullHandleWidth = 40.0;
  static const double pullHandleHeight = 4.0;
  
  // Button sizes
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 52.0;
  
  // Elevations
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  
  // Stroke widths
  static const double strokeWidthThin = 1.0;
  static const double strokeWidthMedium = 2.5;
  static const double strokeWidthThick = 4.0;
  
  // Additional animation durations
  static const int animDurationExtraLong = 1500;
  
  // Map marker dimensions
  static const double markerSize = 24.0;
  static const double markerPulseSizeSmall = 28.0;
  static const double markerPulseSizeLarge = 40.0;
  static const double markerShadowBlur = 8.0;
  static const double markerShadowSpread = 2.0;
  static const double markerBorderWidth = 2.0;
  static const double markerIconSize = 14.0;
  
  // Bus-specific dimensions
  static const double busNumberCircleSize = 36.0;
  static const double busRouteLineWidth = 3.0;
  
  // Border radius circular (commonly used in the app)
  static const double borderRadiusCircular = 100.0; // Effectively a circle for most containers
  
  // Typography sizes
  static const double textSizeExtraSmall = 12.0;
  static const double textSizeSmall = 14.0;
  static const double textSizeMedium = 16.0;
  static const double textSizeLarge = 22.0;
  static const double textSizeExtraLarge = 28.0;
  static const double textSizeHeadline = 32.0;
}
