import 'package:app/models/session.dart';

class PositionDeviceHelper {
  static DevicePosition degreesToCompensationXYZ(DevicePosition degrees) {
    return DevicePosition(
      x: ((degrees.x / 9.8) * (-16384.0)).toInt(),
      y: ((degrees.y / 9.8) * (-16384.0)).toInt(),
      z: ((degrees.z / 9.8) * (-16384.0)).toInt(),
    );
  }

  static List<int> compensationToDegreesXY(DevicePosition devicePosition) {
    return [0, 0, 0];
  }
}
