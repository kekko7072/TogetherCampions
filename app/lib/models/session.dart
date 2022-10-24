import 'package:app/services/imports.dart';

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
}
