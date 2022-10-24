enum TelemetryViewLive { speed, altitude, course, distance, variation }

class TelemetryAnalytics {
  TelemetryAnalytics({
    required this.speed,
    required this.altitude,
    required this.course,
    required this.distance,
    required this.variation,
    //required this.battery,
  });

  final RangeAnalytics speed;
  final RangeAnalytics altitude;
  final RangeAnalytics course;
  final double distance;
  final RangeAnalytics variation;
  //final Battery battery;
}

class TelemetryPosition {
  TelemetryPosition({
    required this.speed,
    required this.distance,
  });

  final RangeAnalytics speed;
  final double distance;
}

class TelemetryNavigation {
  TelemetryNavigation({
    required this.altitude,
    required this.course,
    required this.variation,
    //required this.battery,
  });

  final RangeAnalytics altitude;
  final RangeAnalytics course;
  final RangeAnalytics variation;
//final Battery battery;
}

class RangeAnalytics {
  RangeAnalytics({
    required this.medium,
    required this.max,
    required this.min,
  });

  late final double medium;
  final double max;
  final double min;
}

/*class Battery {
  Battery({
    required this.start,
    required this.end,
  });

  final int start;
  final int end;
}*/
