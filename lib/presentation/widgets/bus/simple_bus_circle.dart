import 'package:flutter/material.dart';
import 'package:busnow/core/constants/dimensions.dart';

/// A simple circular widget displaying a bus number
///
/// Unlike BusNumberCircle, this is a simpler version without the gradient and shadow effects,
/// used for less prominent displays in lists.
class SimpleBusCircle extends StatelessWidget {
  final String busNumber;
  final Color color;
  final double size;
  
  const SimpleBusCircle({
    Key? key,
    required this.busNumber,
    required this.color,
    this.size = AppDimensions.busNumberCircleSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
      ),
      child: Center(
        child: Text(
          busNumber,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
