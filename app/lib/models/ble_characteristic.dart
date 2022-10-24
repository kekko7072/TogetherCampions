import '../const.dart';

enum BLESystemCharacteristic { system, unknown }

enum BLETelemetryCharacteristic {
  mpu,
  // speed,
  //gyroscope,
  gps,
  unknown
}

class BLECharacteristicHelper {
  ///CHARACTERISTIC

  static BLESystemCharacteristic systemCharacteristicPicker(String input) {
    switch (input) {

      ///System Service
      case kBLESystemCharacteristic:
        return BLESystemCharacteristic.system;
    }
    return BLESystemCharacteristic.unknown;
  }

  static BLETelemetryCharacteristic telemetryCharacteristicPicker(
      String input) {
    switch (input) {

      ///Telemetry Service
      case kBLEMpuCharacteristic:
        return BLETelemetryCharacteristic.mpu;
      case kBLEGpsCharacteristic:
        return BLETelemetryCharacteristic.gps;
    }
    return BLETelemetryCharacteristic.unknown;
  }

  static String characteristicPickerName(BLETelemetryCharacteristic input) {
    switch (input) {

      /*///System Service
      case BLECharacteristic.timestamp:
        return 'Timestamp';
      case BLECharacteristic.batteryLevel:
        return 'Battery Level';
      case BLECharacteristic.temperature:
        return 'Temperature';*/

      ///Telemetry Service
      case BLETelemetryCharacteristic.mpu:
        return 'Mpu';
      /* case BLETelemetryCharacteristic.speed:
        return 'Speed';*/
      case BLETelemetryCharacteristic.gps:
        return 'Gps';
      case BLETelemetryCharacteristic.unknown:
        return 'Unknown';
    }
  }
}
