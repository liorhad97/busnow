import 'package:busnow/core/services/arrival_time_calculator.dart';
import 'package:busnow/data/datasources/bus_location_api_source.dart';
import 'package:busnow/domain/models/bus_location_model.dart';
import 'package:busnow/domain/models/bus_schedule_model.dart';
import 'package:busnow/domain/models/bus_stop_model.dart';
import 'package:busnow/domain/repositories/repository_interface.dart';

/// Repository implementation that combines real-time bus location data with static bus stop data
class RealTimeBusScheduleRepository implements BusScheduleRepository {
  final BusLocationDataSource _apiDataSource;
  final BusScheduleRepository
  _localDataSource; // Fallback for stops and offline data
  final ArrivalTimeCalculator _arrivalCalculator;

  RealTimeBusScheduleRepository({
    required BusLocationDataSource apiDataSource,
    required BusScheduleRepository localDataSource,
    required ArrivalTimeCalculator arrivalCalculator,
  }) : _apiDataSource = apiDataSource,
       _localDataSource = localDataSource,
       _arrivalCalculator = arrivalCalculator;

  /// Get all bus stops - uses the local data source
  @override
  Future<List<BusStop>> getBusStops() async {
    return _localDataSource.getBusStops();
  }

  /// Get bus schedules for a specific stop using real-time data
  @override
  Future<List<BusSchedule>> getBusSchedulesForStop(String busStopId) async {
    try {
      // Get the bus stop info first to know its coordinates
      final allStops = await _localDataSource.getBusStops();
      final busStop = allStops.firstWhere(
        (stop) => stop.id == busStopId,
        orElse: () => throw Exception('Bus stop not found: $busStopId'),
      );

      // Fetch buses that are near this stop's location
      final nearbyBuses = await _apiDataSource.fetchBusLocationsNearby(
        busStop.latitude,
        busStop.longitude,
        5.0, // 5 km radius - adjust as needed
      );

      // Convert bus locations to bus schedules
      List<BusSchedule> schedules =
          nearbyBuses.map((bus) {
            // Calculate arrival time in minutes
            final arrivalMinutes = _arrivalCalculator
                .calculateArrivalTimeInMinutes(bus, busStop);

            return BusSchedule(
              id: 'realtime_${bus.busId}_${busStop.id}',
              busNumber: bus.routeNumber,
              busStopId: busStop.id,
              arrivalTimeInMinutes: arrivalMinutes,
              destination: bus.destination,
            );
          }).toList();

      // Sort by arrival time
      schedules.sort(
        (a, b) => a.arrivalTimeInMinutes.compareTo(b.arrivalTimeInMinutes),
      );

      // If no real-time data is available, fall back to local data
      if (schedules.isEmpty) {
        return _localDataSource.getBusSchedulesForStop(busStopId);
      }

      return schedules;
    } catch (e) {
      print(
        'Error fetching real-time schedules: $e - falling back to local data',
      );
      // Fall back to local data if API fails
      return _localDataSource.getBusSchedulesForStop(busStopId);
    }
  }
}
