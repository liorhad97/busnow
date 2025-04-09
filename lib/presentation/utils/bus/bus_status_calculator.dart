import 'package:flutter/material.dart';
import 'package:busnow/core/constants/colors.dart';

/// Helper class for calculating bus status based on arrival times and delays
///
/// Provides utility methods to determine:
/// - Status color based on delay
/// - Status text describing the delay
/// - Formatted arrival time text
class BusStatusCalculator {
  /// Gets the appropriate status color based on the delay
  static Color getStatusColor(Duration? delay) {
    if (delay == null) {
      return AppColors.info;
    }
    
    if (delay.inMinutes <= -2) {
      return AppColors.busEarlyColor; // Early
    } else if (delay.inMinutes <= 2) {
      return AppColors.busOnTimeColor; // On time
    } else if (delay.inMinutes <= 10) {
      return AppColors.busLateColor; // Late
    } else {
      return AppColors.busVeryLateColor; // Very late
    }
  }
  
  /// Gets a human-readable status text based on the delay
  static String getStatusText(Duration? delay) {
    if (delay == null) {
      return 'Unknown';
    }
    
    final minutes = delay.inMinutes;
    if (minutes <= -2) {
      return '$minutes min early';
    } else if (minutes <= 2) {
      return 'On time';
    } else {
      return '$minutes min late';
    }
  }
  
  /// Formats the arrival time as a string
  static String getArrivalText(DateTime? arrivalTime) {
    if (arrivalTime == null) {
      return '--:--';
    }
    
    return '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}';
  }
  
  /// Calculates remaining minutes until arrival
  static String getRemainingMinutesText(DateTime? arrivalTime) {
    if (arrivalTime == null) {
      return '--';
    }
    
    final now = DateTime.now();
    final minutes = arrivalTime.difference(now).inMinutes;
    return '$minutes min';
  }
}
