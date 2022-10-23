import 'package:app/services/imports.dart';

class Session {
  Session({
    required this.id,
    required this.info,
    required this.devicePosition,
  });
  final String id;
  final SessionInfo info;
  final ThreeDimensionalValueInt devicePosition;
}

class SessionInfo {
  SessionInfo({
    required this.name,
    required this.start,
    required this.end,
  });
  final String name;
  final DateTime start;
  final DateTime end;
}

class Service {
  Service({
    required this.timestamp,
    required this.battery,
    required this.temperature,
  });
  final int timestamp;
  final MonoDimensionalValueInt battery;
  final MonoDimensionalValueDouble temperature;
}

class Telemetry {
  Telemetry({
    required this.timestamp,
    required this.acceleration,
    required this.gyroscope,
  });

  final int timestamp;
  final ThreeDimensionalValueInt acceleration;
  final ThreeDimensionalValueInt gyroscope;
}
