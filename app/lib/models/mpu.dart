import 'dart:typed_data';

import 'package:app/models/session.dart';

class Accelerometer {
  Accelerometer({
    required this.timestamp,
    required this.aX,
    required this.aY,
    required this.aZ,
  });

  final int timestamp;
  final int aX;
  final int aY;
  final int aZ;

  factory Accelerometer.formListInt(List<int> bit, DevicePosition position) {
    ByteBuffer buffer = Int8List.fromList(bit).buffer;
    ByteData byteData = ByteData.view(buffer);
    return Accelerometer(
      timestamp: byteData.getInt32(0, Endian.little),
      aX: byteData.getInt32(4, Endian.little) - position.x,
      aY: byteData.getInt32(8, Endian.little) - position.y,
      aZ: byteData.getInt32(12, Endian.little) - position.z,
    );
  }

  factory Accelerometer.fromJson(Map<String, dynamic> json) => Accelerometer(
        timestamp: json["timestamp"] ?? 0,
        aX: json["aX"] ?? 0,
        aY: json["aY"] ?? 0,
        aZ: json["aZ"] ?? 0,
      );
  Map<String, dynamic> toJson() => {
        "timestamp": timestamp,
        "aX": aX,
        "aY": aY,
        "aZ": aZ,
      };
}

class Gyroscope {
  Gyroscope({
    required this.timestamp,
    required this.gX,
    required this.gY,
    required this.gZ,
  });

  final int timestamp;
  final int gX;
  final int gY;
  final int gZ;

  factory Gyroscope.formListInt(List<int> bit) {
    ByteBuffer buffer = Int8List.fromList(bit).buffer;
    ByteData byteData = ByteData.view(buffer);
    return Gyroscope(
      timestamp: byteData.getInt32(0, Endian.little),
      gX: byteData.getInt32(4, Endian.little),
      gY: byteData.getInt32(8, Endian.little),
      gZ: byteData.getInt32(12, Endian.little),
    );
  }

  factory Gyroscope.fromJson(Map<String, dynamic> json) => Gyroscope(
        timestamp: json["timestamp"] ?? 0,
        gX: json["gX"] ?? 0,
        gY: json["gY"] ?? 0,
        gZ: json["gZ"] ?? 0,
      );
  Map<String, dynamic> toJson() => {
        "timestamp": timestamp,
        "gX": gX,
        "gY": gY,
        "gZ": gZ,
      };
}
