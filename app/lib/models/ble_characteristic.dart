import '../const.dart';

enum BLESystemCharacteristic { system, unknown }

enum BLEGpsCharacteristic { position, navigation, unknown }

enum BLEMpuCharacteristic { accelerometer, gyroscope, unknown }

class BLECharacteristicHelper {
  ///CHARACTERISTIC

  static BLESystemCharacteristic systemCharacteristicPicker(String input) {
    switch (input) {
      case kBLESystemCharacteristic:
        return BLESystemCharacteristic.system;
    }
    return BLESystemCharacteristic.unknown;
  }

  static BLEGpsCharacteristic gpsCharacteristicPicker(String input) {
    switch (input) {
      case kBLEPositionCharacteristic:
        return BLEGpsCharacteristic.position;
      case kBLENavigationCharacteristic:
        return BLEGpsCharacteristic.navigation;
    }
    return BLEGpsCharacteristic.unknown;
  }

  static BLEMpuCharacteristic mpuCharacteristicPicker(String input) {
    switch (input) {
      case kBLEAccelerometerCharacteristic:
        return BLEMpuCharacteristic.accelerometer;
      case kBLEGyroscopeCharacteristic:
        return BLEMpuCharacteristic.gyroscope;
    }
    return BLEMpuCharacteristic.unknown;
  }

  static String gpsCharacteristicPickerName(BLEGpsCharacteristic input) {
    switch (input) {
      case BLEGpsCharacteristic.position:
        return 'Position';

      case BLEGpsCharacteristic.navigation:
        return 'Navigation';

      case BLEGpsCharacteristic.unknown:
        return 'Unknown';
    }
  }

  static String mpuCharacteristicPickerName(BLEMpuCharacteristic input) {
    switch (input) {
      case BLEMpuCharacteristic.accelerometer:
        return 'Accelerometer';

      case BLEMpuCharacteristic.gyroscope:
        return 'Gyroscope';

      case BLEMpuCharacteristic.unknown:
        return 'Unknown';
    }
  }
}
