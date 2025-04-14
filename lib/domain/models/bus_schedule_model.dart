/// Model class representing a bus schedule
class BusSchedule {
  final String id;
  final String busNumber;
  final String busStopId;
  final int arrivalTimeInMinutes;
  final String destination;
  final String city;

  const BusSchedule({
    required this.id,
    required this.busNumber,
    required this.busStopId,
    required this.arrivalTimeInMinutes,
    required this.destination,
    this.city = '',
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
