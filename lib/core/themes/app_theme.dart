import 'package:busnow/core/constants/colors-file.dart';
import 'package:busnow/core/constants/dimensions-file.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized theme configuration for the entire application
class AppTheme {
  /// Light theme configuration
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _getTextTheme(context, Brightness.light),
      cardTheme: _getCardTheme(Brightness.light),
    );
  }

  /// Dark theme configuration
  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextSecondary,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _getTextTheme(context, Brightness.dark),
      cardTheme: _getCardTheme(Brightness.dark),
    );
  }

  /// Text theme based on brightness
  static TextTheme _getTextTheme(BuildContext context, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    return GoogleFonts.poppinsTextTheme(
      Theme.of(context).textTheme.copyWith(
        headlineMedium: TextStyle(
          fontSize: AppDimensions.textSizeLarge,
          fontWeight: FontWeight.w600,
          color:
              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: AppDimensions.textSizeMedium,
          fontWeight: FontWeight.normal,
          color:
              isDark ? AppColors.darkTextSecondary : AppColors.lightTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: AppDimensions.textSizeSmall,
          fontWeight: FontWeight.normal,
          color:
              isDark ? AppColors.darkTextSecondary : AppColors.lightTextPrimary,
        ),
      ),
    );
  }

  /// Card theme based on brightness
  static CardTheme _getCardTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    return CardTheme(
      elevation:
          isDark ? AppDimensions.elevationMedium : AppDimensions.elevationSmall,
      color: isDark ? AppColors.darkSurface : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      ),
    );
  }

  /// Map styles for light and dark mode
  static const String lightMapStyle = '''
  [
    {
      "featureType": "poi",
      "elementType": "labels.icon",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    }
  ]
  ''';

  static const String darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "administrative.country",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#9e9e9e"
        }
      ]
    }
  ]
  ''';
}
