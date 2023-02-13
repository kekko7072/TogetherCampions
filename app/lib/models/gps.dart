import 'package:app/services/imports.dart';

class GpsPosition {
  GpsPosition({
    required this.timestamp,
    required this.available,
    required this.latLng,
    required this.speed,
  });

  final int timestamp;
  final bool available;
  final MapLatLng latLng;
  final double speed;

  static bool isAvailable(List<int> bit) {
    ByteBuffer buffer = Int8List.fromList(bit).buffer;
    ByteData byteData = ByteData.view(buffer);
    return byteData.getFloat32(4, Endian.little).toInt() == 1;
  }

  factory GpsPosition.formListInt(List<int> bit) {
    ByteBuffer buffer = Int8List.fromList(bit).buffer;
    ByteData byteData = ByteData.view(buffer);
    return GpsPosition(
      timestamp: byteData.getFloat32(0, Endian.little).toInt(),
      available: byteData.getFloat32(4, Endian.little).toInt() == 1,
      latLng: MapLatLng(byteData.getFloat32(8, Endian.little),
          byteData.getFloat32(12, Endian.little)),
      speed: byteData.getFloat32(16, Endian.little),
    );
  }

  factory GpsPosition.fromJson(Map<String, dynamic> json) => GpsPosition(
        timestamp: json["timestamp"] ?? 0,
        available: json["available"] ?? false,
        latLng: MapLatLng(json["latitude"] ?? 0.0, json["longitude"] ?? 0.0),
        speed: json["speed"] ?? 0.0,
      );
  Map<String, dynamic> toJson() => {
        "timestamp": timestamp,
        "available": available,
        "latitude": latLng.latitude,
        "longitude": latLng.longitude,
        "speed": speed,
      };
}

class GpsNavigation {
  GpsNavigation({
    required this.timestamp,
    required this.available,
    required this.altitude,
    required this.course,
    required this.variation,
  });

  final int timestamp;
  final bool available;
  final double altitude;

  final double course;
  final double variation;

  static bool isAvailable(List<int> bit) {
    ByteBuffer buffer = Int8List.fromList(bit).buffer;
    ByteData byteData = ByteData.view(buffer);
    return byteData.getFloat32(4, Endian.little).toInt() == 1;
  }

  factory GpsNavigation.formListInt(List<int> bit) {
    ByteBuffer buffer = Int8List.fromList(bit).buffer;
    ByteData byteData = ByteData.view(buffer);
    return GpsNavigation(
      timestamp: byteData.getFloat32(0, Endian.little).toInt(),
      available: byteData.getFloat32(4, Endian.little).toInt() == 1,
      altitude: byteData.getFloat32(8, Endian.little),
      course: byteData.getFloat32(12, Endian.little),
      variation: byteData.getFloat32(16, Endian.little),
    );
  }

  factory GpsNavigation.fromJson(Map<String, dynamic> json) => GpsNavigation(
        timestamp: json["timestamp"] ?? 0,
        available: json["available"] ?? false,
        altitude: json["altitude"] ?? 0.0,
        course: json["course"] ?? 0.0,
        variation: json["variation"] ?? 0.0,
      );
  Map<String, dynamic> toJson() => {
        "timestamp": timestamp,
        "available": available,
        "altitude": altitude,
        "course": course,
        "variation": variation,
      };
}
