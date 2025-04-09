import 'package:flutter/src/widgets/framework.dart';

/// Model class representing a bus schedule
class BusSchedule {
  final String id;
  final String busNumber;
  final String busStopId;
  final int arrivalTimeInMinutes;
  final String destination;

  const BusSchedule({
    required this.id,
    required this.busNumber,
    required this.busStopId,
    required this.arrivalTimeInMinutes,
    required this.destination,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'busNumber': busNumber,
      'busStopId': busStopId,
      'arrivalTimeInMinutes': arrivalTimeInMinutes,
      'destination': destination,
    };
  }
}
