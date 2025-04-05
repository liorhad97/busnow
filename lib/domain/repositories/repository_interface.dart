import 'package:busnow/domain/models/bus_schedule_model.dart';
import 'package:busnow/domain/models/bus_stop_model.dart';

/// Interface for the bus schedule repository
abstract class BusScheduleRepository {
  /// Returns a list of all bus stops
  Future<List<BusStop>> getBusStops();

  /// Returns a list of bus schedules for a specific bus stop
  Future<List<BusSchedule>> getBusSchedulesForStop(String busStopId);
}
