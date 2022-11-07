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
        x: json["x"],
        y: json["y"],
        z: json["z"],
      );

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
        "z": z,
      };
}

class SessionUpload {
  SessionUpload({
    required this.deviceId,
    required this.sessionId,
    required this.info,
    required this.devicePosition,
    required this.system,
    required this.gpsPosition,
    required this.gpsNavigation,
    required this.accelerometer,
    required this.gyroscope,
  });

  String deviceId;
  String sessionId;
  SessionInfo info;
  DevicePosition devicePosition;
  List<System> system;
  List<GpsPosition> gpsPosition;
  List<GpsNavigation> gpsNavigation;
  List<Accelerometer> accelerometer;
  List<Gyroscope> gyroscope;

  factory SessionUpload.fromJson(Map<String, dynamic> json) => SessionUpload(
        deviceId: json["deviceID"],
        sessionId: json["sessionID"],
        info: SessionInfo.fromJson(json["info"]),
        devicePosition: DevicePosition.fromJson(json["devicePosition"]),
        system:
            List<System>.from(json["system"].map((x) => System.fromJson(x))),
        gpsPosition: List<GpsPosition>.from(
            json["gps_position"].map((x) => GpsPosition.fromJson(x))),
        gpsNavigation: List<GpsNavigation>.from(
            json["gps_navigation"].map((x) => GpsNavigation.fromJson(x))),
        accelerometer: List<Accelerometer>.from(
            json["accelerometer"].map((x) => Accelerometer.fromJson(x))),
        gyroscope: List<Gyroscope>.from(
            json["gyroscope"].map((x) => Gyroscope.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "deviceID": deviceId,
        "sessionID": sessionId,
        "info": info.toJson(),
        "devicePosition": devicePosition.toJson(),
        "system": List<dynamic>.from(system.map((x) => x.toJson())),
        "gps_position": List<dynamic>.from(gpsPosition.map((x) => x.toJson())),
        "gps_navigation":
            List<dynamic>.from(gpsNavigation.map((x) => x.toJson())),
        "accelerometer":
            List<dynamic>.from(accelerometer.map((x) => x.toJson())),
        "gyroscope": List<dynamic>.from(gyroscope.map((x) => x.toJson())),
      };
}
