import 'package:app/services/imports.dart';

class Gps {
  Gps({
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

  factory Gps.fromJson(Map<String, dynamic> json) => Gps(
        timestamp: json["timestamp"],
        available: json["available"],
        latLng: MapLatLng(json["latitude"], json["longitude"]),
        altitude: json["altitude"],
        speed: json["speed"],
        course: json["course"],
        satellites: json["satellites"],
      );
  Map<String, dynamic> toJson() => {
        "timestamp": timestamp,
        "available": available,
        "latitude": latLng.latitude,
        "longitude": latLng.longitude,
        "altitude": altitude,
        "speed": speed,
        "course": course,
        "satellites": satellites,
      };
}
