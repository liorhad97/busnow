import 'package:busnow/domain/models/bus_schedule_model.dart';

/// Model to group bus schedules by bus number
class BusScheduleGroup {
  final String busNumber;
  final String destination;
  final List<BusSchedule> schedules;

  const BusScheduleGroup({
    required this.busNumber,
    required this.destination,
    required this.schedules,
  });

  /// Get the earliest arrival time in minutes
  int get earliestArrivalTime {
    if (schedules.isEmpty) return 0;
    return schedules
        .map((s) => s.arrivalTimeInMinutes)
        .reduce((a, b) => a < b ? a : b);
  }

  /// Get all arrival times sorted
  List<int> get arrivalTimes {
    return schedules.map((s) => s.arrivalTimeInMinutes).toList()..sort();
  }
}
