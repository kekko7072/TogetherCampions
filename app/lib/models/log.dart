import 'package:app/services/imports.dart';

class Log {
  Log({
    required this.id,
    required this.timestamp,
    required this.battery,
    required this.gps,
  });

  final String id;
  final DateTime timestamp;
  final double battery;
  final GPS gps;
}

class GPS {
  GPS({
    required this.latLng,
    required this.altitude,
    required this.satellites,
    required this.speed,
  });

  final LatLng latLng;
  final double altitude;
  final int satellites;
  final double speed;
}
