import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local_data_source.dart';
import '../../data/repositories/bus_schedule_repository_impl.dart';
import '../../domain/models/bus_schedule_model.dart';
import '../../domain/models/bus_stop_model.dart';
import '../../domain/models/bus_schedule_group_model.dart';
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
  final List<BusStop> nearbyBusStops; // Added to track multiple nearby stops
  final bool isBottomSheetOpen;
  final String? errorMessage;

  const BusScheduleState({
    this.status = BusScheduleStateStatus.initial,
    this.busStops = const [],
    this.busSchedules = const [],
    this.selectedBusStop,
    this.nearbyBusStops = const [], // Initialize as empty list
    this.isBottomSheetOpen = false,
    this.errorMessage,
  });

  BusScheduleState copyWith({
    BusScheduleStateStatus? status,
    List<BusStop>? busStops,
    List<BusSchedule>? busSchedules,
    BusStop? selectedBusStop,
    List<BusStop>? nearbyBusStops,
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
      nearbyBusStops: nearbyBusStops ?? this.nearbyBusStops,
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

  // Helper method to group bus schedules by bus number
  List<BusScheduleGroup> getGroupedSchedules() {
    // Group schedules by bus number
    final Map<String, List<BusSchedule>> groupedMap = {};
    for (var schedule in busSchedules) {
      if (!groupedMap.containsKey(schedule.busNumber)) {
        groupedMap[schedule.busNumber] = [];
      }
      groupedMap[schedule.busNumber]!.add(schedule);
    }

    // Convert map to list of BusScheduleGroup objects
    final List<BusScheduleGroup> result = [];
    groupedMap.forEach((busNumber, schedules) {
      // Sort schedules by arrival time
      schedules.sort(
        (a, b) => a.arrivalTimeInMinutes.compareTo(b.arrivalTimeInMinutes),
      );

      // Use the destination and city of the earliest bus (they should be the same for the same route)
      final destination = schedules.first.destination;
      final city = schedules.first.city;

      result.add(
        BusScheduleGroup(
          busNumber: busNumber,
          destination: destination,
          schedules: schedules,
          city: city,
        ),
      );
    });

    // Sort groups by earliest arrival time
    result.sort(
      (a, b) => a.earliestArrivalTime.compareTo(b.earliestArrivalTime),
    );

    return result;
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

  // New method to select multiple nearby bus stops and load their combined schedules
  Future<void> selectNearbyBusStops(List<BusStop> nearbyStops) async {
    if (nearbyStops.isEmpty) return;

    // Set the primary selected stop (for UI display purposes)
    final primaryStop = nearbyStops.first;

    state = state.copyWith(
      selectedBusStop: primaryStop,
      nearbyBusStops: nearbyStops,
      isBottomSheetOpen: true,
      status: BusScheduleStateStatus.loading,
    );

    try {
      // Load and combine schedules for all nearby stops
      List<BusSchedule> allSchedules = [];

      for (final stop in nearbyStops) {
        final schedules = await _repository.getBusSchedulesForStop(stop.id);
        allSchedules.addAll(schedules);
      }

      // Sort all schedules by arrival time
      allSchedules.sort(
        (a, b) => a.arrivalTimeInMinutes.compareTo(b.arrivalTimeInMinutes),
      );

      state = state.copyWith(
        status: BusScheduleStateStatus.loaded,
        busSchedules: allSchedules,
        clearErrorMessage: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: BusScheduleStateStatus.error,
        errorMessage: 'Failed to load combined bus schedules: ${e.toString()}',
      );
    }
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
    if (state.nearbyBusStops.isNotEmpty) {
      // If we have multiple nearby stops, refresh their combined schedules
      await selectNearbyBusStops(state.nearbyBusStops);
    } else if (state.selectedBusStop != null) {
      // Otherwise just refresh the single selected stop
      await loadBusSchedulesForStop(state.selectedBusStop!.id);
    }
  }

  // Reset the state to initial values
  void reset() {
    state = const BusScheduleState(
      status: BusScheduleStateStatus.initial,
      busStops: [],
      busSchedules: [],
      selectedBusStop: null,
      nearbyBusStops: [],
      isBottomSheetOpen: false,
      errorMessage: null,
    );
  }

  // Helper method to generate a title for the sheet based on nearby bus stops
  String getSheetTitle() {
    if (state.nearbyBusStops.isEmpty) {
      return state.selectedBusStop?.name ?? "No Bus Stop Selected";
    }

    // Combine names of nearby bus stops
    final stopNames = state.nearbyBusStops.map((stop) => stop.name).toList();
    if (stopNames.length > 2) {
      return "${stopNames[0]} + ${stopNames[1]} + ...";
    } else {
      return stopNames.join(" + ");
    }
  }
}

// Create the provider that uses the StateNotifier
final busScheduleProvider =
    StateNotifierProvider<BusScheduleNotifier, BusScheduleState>((ref) {
      final repository = ref.watch(busScheduleRepositoryProvider);
      return BusScheduleNotifier(repository);
    });
