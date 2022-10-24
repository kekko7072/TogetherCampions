import 'package:app/services/imports.dart';

class Gps {
  Gps({
    required this.timestamp,
    required this.available,
    required this.latLng,
    required this.altitude,
    required this.speed,
    required this.course,
    required this.variation,
  });

  final int timestamp;
  final bool available;
  final MapLatLng latLng;
  final double altitude;
  final double speed;
  final double course;
  final double variation;

  factory Gps.formListInt(List<int> bit) {
    ByteBuffer buffer = Int8List.fromList(bit).buffer;
    ByteData byteData = ByteData.view(buffer);
    return Gps(
      timestamp: byteData.getFloat32(0, Endian.little).toInt(),
      available: byteData.getFloat32(4, Endian.little) == 0.0,
      latLng: MapLatLng(byteData.getFloat32(8, Endian.little),
          byteData.getFloat32(12, Endian.little)),
      altitude: byteData.getFloat32(16, Endian.little),
      speed: byteData.getFloat32(20, Endian.little),
      course: byteData.getFloat32(24, Endian.little),
      variation: byteData.getFloat32(28, Endian.little),
    );
  }

  factory Gps.fromJson(Map<String, dynamic> json) => Gps(
        timestamp: json["timestamp"],
        available: json["available"],
        latLng: MapLatLng(json["latitude"], json["longitude"]),
        altitude: json["altitude"],
        speed: json["speed"],
        course: json["course"],
        variation: json["variation"],
      );
  Map<String, dynamic> toJson() => {
        "timestamp": timestamp,
        "available": available,
        "latitude": latLng.latitude,
        "longitude": latLng.longitude,
        "altitude": altitude,
        "speed": speed,
        "course": course,
        "variation": variation,
      };
}
