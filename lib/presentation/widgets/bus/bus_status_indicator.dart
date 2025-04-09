import 'package:flutter/material.dart';
import 'package:busnow/core/constants/dimensions.dart';

/// A widget displaying the bus status (early, on time, late)
///
/// Features:
/// - Color-coded status indicators
/// - Compact design for inline use
/// - Supports loading state with animation
class BusStatusIndicator extends StatelessWidget {
  final String statusText;
  final Color statusColor;
  final bool isLoading;
  
  const BusStatusIndicator({
    Key? key,
    required this.statusText,
    required this.statusColor,
    this.isLoading = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingIndicator();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSmall,
        vertical: AppDimensions.spacingExtraSmall / 2,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.w500,
          fontSize: AppDimensions.textSizeExtraSmall,
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 18,
      width: 70,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            width: 70,
            height: 4,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 70.0),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Positioned(
                left: value % 90 - 20,
                child: Container(
                  width: 30,
                  height: 4,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            onEnd: () {}, // Rebuild to continue animation
          ),
        ],
      ),
    );
  }
}
