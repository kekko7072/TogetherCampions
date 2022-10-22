import 'package:app/services/imports.dart';

class Log {
  Log({
    required this.id,
    required this.timestamp,
    required this.battery,
    required this.gps,
  });

  final String id;
  @Deprecated('With BLE HAS CHANGED')
  final DateTime timestamp;
  @Deprecated('With BLE HAS CHANGED')
  final double battery;
  @Deprecated('With BLE HAS CHANGED')
  final GPS gps;

  ///TODO ADD SERVICE CLASS
  ///+timestamp
  ///+battery
  ///+temperature

  ///TODO ADD AND CREATE TELEMETRY CLASS
  ///+acceleration
  ///+gyroscope
  ///+gps

  ///TODO add DEVICE POSITION IN SPACE (x,y,z) to create an inertial system

}

class GPS {
  GPS({
    //TODO integrate available
    //required this.available;
    required this.latLng,
    required this.altitude,
    required this.speed,
    required this.course,
    required this.satellites,
  });

  // final bool available;
  final MapLatLng latLng;
  final double altitude;
  final double speed;
  final double course;
  final int satellites;
}
