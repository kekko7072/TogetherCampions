enum TelemetryViewLive {
  speed,
  altitude,
  course,
}

class TelemetryAnalytics {
  TelemetryAnalytics({
    required this.speed,
    required this.altitude,
    required this.course,
    required this.distance,
    required this.satellites,
    //required this.battery,
  });

  final RangeAnalytics speed;
  final RangeAnalytics altitude;
  final RangeAnalytics course;
  final double distance;
  final int satellites;
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
