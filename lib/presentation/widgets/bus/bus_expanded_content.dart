// import 'package:flutter/material.dart';
// import 'package:busnow/core/constants/dimensions.dart';
// import 'package:busnow/presentation/widgets/bus/bus_time_info.dart';
// import 'package:busnow/presentation/widgets/bus/route_visualization.dart';
// import 'package:busnow/presentation/widgets/bus/bus_action_buttons.dart';

// /// The expanded content shown when a bus schedule card is tapped
// ///
// /// Features:
// /// - Time until arrival display
// /// - Interactive route visualization
// /// - Action buttons for tracking and alerts
// /// - Animated entrance and transitions
// class BusExpandedContent extends StatelessWidget {
//   final DateTime? arrivalTime;
//   final Duration? delay;
//   final Color statusColor;
//   final String destination;
//   final String origin;
//   final VoidCallback? onTrackPressed;
//   final VoidCallback? onAlertPressed;
  
//   const BusExpandedContent({
//     Key? key,
//     required this.arrivalTime,
//     required this.delay,
//     required this.statusColor,
//     required this.destination,
//     this.origin = 'Current Location',
//     this.onTrackPressed,
//     this.onAlertPressed,
//   }) : super(key: key);
  
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(
//         left: AppDimensions.spacingMedium,
//         right: AppDimensions.spacingMedium,
//         bottom: AppDimensions.spacingMedium,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Divider between header and details
//           const Divider(),
//           const SizedBox(height: AppDimensions.spacingMedium),
          
//           // Time information
//           BusTimeInfo(
//             arrivalTime: arrivalTime,
//             statusColor: statusColor,
//           ),
          
//           // Route visualization
//           RouteVisualization(
//             statusColor: statusColor,
//             originName: origin,
//             destinationName: destination,
//           ),
          
//           // Action buttons
//           BusActionButtons(
//             statusColor: statusColor,
//             onTrackPressed: onTrackPressed,
//             onAlertPressed: onAlertPressed,
//           ),
//         ],
//       ),
//     );
//   }
// }
