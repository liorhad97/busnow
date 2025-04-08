import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local_data_source.dart';
import '../../data/repositories/bus_schedule_repository_impl.dart';
import '../../domain/models/bus_schedule_model.dart';
import '../../domain/models/bus_stop_model.dart';
import '../../domain/repositories/repository_interface.dart';

// Repository providers
final busScheduleRepositoryProvider = Provider<BusScheduleRepository>((ref) {
  final dataSource = BusScheduleLocalDataSource();
  return BusScheduleRepositoryImpl(localDataSource: dataSource);
});

// State enums
enum BusScheduleStateStatus { initial, loading, loaded, error }

// State class
class BusScheduleState {
  final BusScheduleStateStatus status;
  final List<BusStop> busStops;
  final List<BusSchedule> busSchedules;
  final BusStop? selectedBusStop;
  final bool isBottomSheetOpen;
  final String? errorMessage;

  const BusScheduleState({
    this.status = BusScheduleStateStatus.initial,
    this.busStops = const [],
    this.busSchedules = const [],
    this.selectedBusStop,
    this.isBottomSheetOpen = false,
    this.errorMessage,
  });

  BusScheduleState copyWith({
    BusScheduleStateStatus? status,
    List<BusStop>? busStops,
    List<BusSchedule>? busSchedules,
    BusStop? selectedBusStop,
    bool? isBottomSheetOpen,
    String? errorMessage,
    bool clearSelectedBusStop = false,
    bool clearErrorMessage = false,
  }) {
    return BusScheduleState(
      status: status ?? this.status,
      busStops: busStops ?? this.busStops,
      busSchedules: busSchedules ?? this.busSchedules,
      selectedBusStop:
          clearSelectedBusStop
              ? null
              : (selectedBusStop ?? this.selectedBusStop),
      isBottomSheetOpen: isBottomSheetOpen ?? this.isBottomSheetOpen,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  // Helper method to get earliest arrival times per bus number
  Map<String, int> getEarliestArrivalTimes() {
    final Map<String, int> earliestTimes = {};

    for (var schedule in busSchedules) {
      if (!earliestTimes.containsKey(schedule.busNumber) ||
          earliestTimes[schedule.busNumber]! > schedule.arrivalTimeInMinutes) {
        earliestTimes[schedule.busNumber] = schedule.arrivalTimeInMinutes;
      }
    }

    return earliestTimes;
  }
}

// Bus Schedule Notifier class
class BusScheduleNotifier extends StateNotifier<BusScheduleState> {
  final BusScheduleRepository _repository;

  BusScheduleNotifier(this._repository) : super(const BusScheduleState());

  Future<void> loadBusStops() async {
    state = state.copyWith(status: BusScheduleStateStatus.loading);

    try {
      final busStops = await _repository.getBusStops();

      state = state.copyWith(
        status: BusScheduleStateStatus.loaded,
        busStops: busStops,
        clearErrorMessage: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: BusScheduleStateStatus.error,
        errorMessage: 'Failed to load bus stops: ${e.toString()}',
      );
    }
  }

  Future<void> selectBusStop(BusStop busStop) async {
    state = state.copyWith(selectedBusStop: busStop, isBottomSheetOpen: true);
    await loadBusSchedulesForStop(busStop.id);
  }

  Future<void> loadBusSchedulesForStop(String busStopId) async {
    state = state.copyWith(status: BusScheduleStateStatus.loading);

    try {
      final busSchedules = await _repository.getBusSchedulesForStop(busStopId);

      // Sort by arrival time
      busSchedules.sort(
        (a, b) => a.arrivalTimeInMinutes.compareTo(b.arrivalTimeInMinutes),
      );

      state = state.copyWith(
        status: BusScheduleStateStatus.loaded,
        busSchedules: busSchedules,
        clearErrorMessage: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: BusScheduleStateStatus.error,
        errorMessage: 'Failed to load bus schedules: ${e.toString()}',
      );
    }
  }

  void openBottomSheet() {
    state = state.copyWith(isBottomSheetOpen: true);
  }

  void closeBottomSheet() {
    state = state.copyWith(isBottomSheetOpen: false);
  }

  Future<void> refreshBusSchedules() async {
    if (state.selectedBusStop != null) {
      await loadBusSchedulesForStop(state.selectedBusStop!.id);
    }
  }
}

// Create the provider that uses the StateNotifier
final busScheduleProvider =
    StateNotifierProvider<BusScheduleNotifier, BusScheduleState>((ref) {
      final repository = ref.watch(busScheduleRepositoryProvider);
      return BusScheduleNotifier(repository);
    });
