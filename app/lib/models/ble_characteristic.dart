import '../const.dart';

enum BLESystemCharacteristic { timestamp, battery, temperature, unknown }

enum BLETelemetryCharacteristic {
  accelerometer,
  // speed,
  gyroscope,
  gps,
  unknown
}

class BLECharacteristicHelper {
  ///CHARACTERISTIC

  static BLESystemCharacteristic systemCharacteristicPicker(String input) {
    switch (input) {

      ///System Service
      case kBLETimestampCharacteristic:
        return BLESystemCharacteristic.timestamp;
      case kBLEBatteryCharacteristic:
        return BLESystemCharacteristic.battery;
      case kBLETemperatureCharacteristic:
        return BLESystemCharacteristic.temperature;
    }
    return BLESystemCharacteristic.unknown;
  }

  static BLETelemetryCharacteristic telemetryCharacteristicPicker(
      String input) {
    switch (input) {

      ///Telemetry Service
      case kBLEAccelerometerCharacteristic:
        return BLETelemetryCharacteristic.accelerometer;
      case kBLEGyroscopeCharacteristic:
        return BLETelemetryCharacteristic.gyroscope;
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
      case BLETelemetryCharacteristic.accelerometer:
        return 'Accelerometer';
      /* case BLETelemetryCharacteristic.speed:
        return 'Speed';*/
      case BLETelemetryCharacteristic.gyroscope:
        return 'Gyroscope';
      case BLETelemetryCharacteristic.gps:
        return 'Gps';
      case BLETelemetryCharacteristic.unknown:
        return 'Unknown';
    }
  }
}
