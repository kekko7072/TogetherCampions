import 'package:app/services/imports.dart';

class GPS {
  GPS({
    required this.timestamp,
    required this.available,
    required this.latLng,
    required this.altitude,
    required this.speed,
    required this.course,
    required this.satellites,
  });

  final int timestamp;
  final bool available;
  final MapLatLng latLng;
  final double altitude;
  final double speed;
  final double course;
  final int satellites;
}
