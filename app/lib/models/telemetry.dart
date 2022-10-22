enum TelemetryViewLive {
  speed,
  altitude,
  course,
}

class TelemetryData {
  TelemetryData({
    required this.speed,
    required this.altitude,
    required this.course,
    required this.distance,
    required this.satellites,
    required this.battery,
  });

  final Range speed;
  final Range altitude;
  final Range course;
  final double distance;
  final int satellites;
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

class MonoDimensionalValueInt {
  MonoDimensionalValueInt({
    required this.value,
    required this.timestamp,
  });

  final int value;
  final int timestamp;
}

class MonoDimensionalValueDouble {
  MonoDimensionalValueDouble({
    required this.value,
    required this.timestamp,
  });

  final double value;
  final int timestamp;
}

class ThreeDimensionalValueInt {
  ThreeDimensionalValueInt({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  final int x;
  final int y;
  final int z;
  final int timestamp;
}

class ThreeDimensionalValueDouble {
  ThreeDimensionalValueDouble({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  final double x;
  final double y;
  final double z;
  final int timestamp;
}
