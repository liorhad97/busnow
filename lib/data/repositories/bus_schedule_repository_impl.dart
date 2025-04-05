import 'package:busnow/data/datasources/local_data_source.dart';
import 'package:busnow/domain/models/bus_schedule_model.dart';
import 'package:busnow/domain/models/bus_stop_model.dart';
import 'package:busnow/domain/repositories/repository_interface.dart';

/// Implementation of the BusScheduleRepository
class BusScheduleRepositoryImpl implements BusScheduleRepository {
  final BusScheduleLocalDataSource localDataSource;

  BusScheduleRepositoryImpl({required this.localDataSource});

  @override
  Future<List<BusStop>> getBusStops() async {
    return await localDataSource.getBusStops();
  }

  @override
  Future<List<BusSchedule>> getBusSchedulesForStop(String busStopId) async {
    return await localDataSource.getBusSchedulesForStop(busStopId);
  }
}
