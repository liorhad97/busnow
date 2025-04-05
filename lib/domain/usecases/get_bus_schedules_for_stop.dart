import 'package:busnow/domain/models/bus_schedule_model.dart';
import 'package:busnow/domain/repositories/repository_interface.dart';

/// Use case for retrieving bus schedules for a specific stop
class GetBusSchedulesForStop {
  final BusScheduleRepository repository;

  GetBusSchedulesForStop(this.repository);

  /// Execute the use case with a bus stop ID
  Future<List<BusSchedule>> execute(String busStopId) async {
    return await repository.getBusSchedulesForStop(busStopId);
  }
}
