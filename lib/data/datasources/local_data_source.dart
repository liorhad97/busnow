import 'dart:math';

import 'package:busnow/domain/models/bus_schedule_model.dart';
import 'package:busnow/domain/models/bus_stop_model.dart';

/// Local data source providing mock data for the app
class BusScheduleLocalDataSource {
  // Mock data for bus stops
  final List<BusStop> _busStops = [
    const BusStop(
      id: 'stop1',
      name: 'Central Station',
      latitude: 37.7749,
      longitude: -122.4194,
    ),
    const BusStop(
      id: 'stop2',
      name: 'Market Street',
      latitude: 37.7899,
      longitude: -122.4014,
    ),
    const BusStop(
      id: 'stop3',
      name: 'Union Square',
      latitude: 37.7879,
      longitude: -122.4074,
    ),
    const BusStop(
      id: 'stop6',
      name: 'Square',
      latitude: 37.7879,
      longitude: -122.4075,
    ),
    const BusStop(
      id: 'stop4',
      name: 'Fisherman\'s Wharf',
      latitude: 37.8100,
      longitude: -122.4104,
    ),
    const BusStop(
      id: 'stop5',
      name: 'Chinatown',
      latitude: 37.7941,
      longitude: -122.4078,
    ),
  ];

  /// Generate random bus schedules for a given stop
  List<BusSchedule> _generateBusSchedules(String busStopId) {
    final random = Random();
    final busNumbers = ['2', '7', '14', '21', '30', '45', '38R'];
    final destinations = [
      'Downtown',
      'City Center',
      'Airport',
      'Mall',
      'University',
      'Beach',
      'Financial District',
    ];

    // Generate 3-8 bus schedules for the stop
    final schedulesCount = random.nextInt(6) + 3;

    return List.generate(schedulesCount, (index) {
      final busNumber = busNumbers[random.nextInt(busNumbers.length)];
      final destination = destinations[random.nextInt(destinations.length)];
      // Arrival time between 1 and 30 minutes
      final arrivalTime = random.nextInt(30) + 1;

      return BusSchedule(
        id: 'schedule_${busStopId}_$index',
        busNumber: busNumber,
        busStopId: busStopId,
        arrivalTimeInMinutes: arrivalTime,
        destination: destination,
      );
    });
  }

  /// Returns a list of all bus stops
  Future<List<BusStop>> getBusStops() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _busStops;
  }

  /// Returns a list of bus schedules for a specific bus stop
  Future<List<BusSchedule>> getBusSchedulesForStop(String busStopId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));
    return _generateBusSchedules(busStopId);
  }
}
