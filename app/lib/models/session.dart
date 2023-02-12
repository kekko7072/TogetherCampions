import 'package:app/models/system.dart';

import 'gps.dart';
import 'mpu.dart';

class Session {
  Session({
    required this.id,
    required this.info,
    required this.devicePosition,
  });
  final String id;
  final SessionInfo info;
  final DevicePosition devicePosition;
}

class SessionInfo {
  SessionInfo({
    required this.name,
    required this.start,
    required this.end,
  });
  final String name;
  final DateTime start;
  final DateTime end;

  factory SessionInfo.fromJson(Map<String, dynamic> json) => SessionInfo(
        name: json["name"],
        start: DateTime.parse(json["start"]),
        end: DateTime.parse(json["end"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "start": start.toIso8601String(),
        "end": end.toIso8601String(),
      };
}

class DevicePosition {
  DevicePosition({
    required this.x,
    required this.y,
    required this.z,
  });
  final int x;
  final int y;
  final int z;
  factory DevicePosition.fromJson(Map<String, dynamic> json) => DevicePosition(
        x: json["x"] ?? 0,
        y: json["y"] ?? 0,
        z: json["z"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
        "z": z,
      };
}

class TimestampF {
  TimestampF({
    required this.system,
    required this.gpsPosition,
    required this.gpsNavigation,
    required this.accelerometer,
    required this.gyroscope,
  });

  System? system;
  GpsPosition? gpsPosition;
  GpsNavigation? gpsNavigation;
  Accelerometer? accelerometer;
  Gyroscope? gyroscope;

  factory TimestampF.fromJson(Map<String, dynamic> json) => TimestampF(
        system: json["system"] == null ? null : System.fromJson(json["system"]),
        gpsPosition: json["gps_position"] == null
            ? null
            : GpsPosition.fromJson(json["gps_position"]),
        gpsNavigation: json["gps_navigation"] == null
            ? null
            : GpsNavigation.fromJson(json["gps_navigation"]),
        accelerometer: json["accelerometer"] == null
            ? null
            : Accelerometer.fromJson(json["accelerometer"]),
        gyroscope: json["gyroscope"] == null
            ? null
            : Gyroscope.fromJson(json["gyroscope"]),
      );

  /*Map<String, dynamic> toJson() => {
        "system": system.toJson(),
        "gps_position": gpsPosition.toJson(),
        "gps_navigation": gpsNavigation.toJson(),
        "accelerometer": accelerometer.toJson(),
        "gyroscope": gyroscope.toJson(),
      };*/
}

class SessionFile {
  SessionFile({
    this.deviceId,
    this.sessionId,
    this.info,
    this.devicePosition,
    this.timestamp,
  });

  String? deviceId;
  String? sessionId;
  SessionInfo? info;
  DevicePosition? devicePosition;
  List<TimestampF>? timestamp;

  factory SessionFile.fromJson(Map<String, dynamic> json) {
    print(json["timestamp"]);
    return SessionFile(
      deviceId: json["device_id"] ?? '',
      sessionId: json["session_id"] ?? '',
      info: json["info"] == null ? null : SessionInfo.fromJson(json["info"]),
      devicePosition: json["device_position"] == null
          ? null
          : DevicePosition.fromJson(json["device_position"]),
      timestamp: json["timestamp"] == null
          ? null
          : List<TimestampF>.from(
              json["timestamp"].map((x) => TimestampF.fromJson(x))),
    );
  }
  /* Map<String, dynamic> toJson() => {
        "device_id": deviceId,
        "session_id": sessionId,
        "info": info.toJson(),
        "device_position": devicePosition.toJson(),
        "timestamp": List<dynamic>.from(timestamp.map((x) => x.toJson())),
      };*/
}
