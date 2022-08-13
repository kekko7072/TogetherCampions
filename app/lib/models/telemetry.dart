import 'package:app/services/imports.dart';

class Telemetry {
  Telemetry({
    required this.speed,
    required this.altitude,
    required this.distance,
    required this.battery,
  });

  final Range speed;
  final Range altitude;
  final double distance;
  final Battery battery;
}

class Range {
  Range({
    required this.medium,
    required this.max,
    required this.min,
  });

  late final double medium;
  final double max;
  final double min;
}

class Battery {
  Battery({
    required this.consumption,
    required this.maxVoltage,
    required this.minVoltage,
  });

  final double consumption;
  final double maxVoltage;
  final double minVoltage;
}
