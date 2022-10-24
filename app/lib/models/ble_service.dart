import '../const.dart';

enum BLEService { systemService, gpsService, mpuService, unknown }

class BLEServiceHelper {
  ///SERVICE
  static BLEService servicePicker(String input) {
    switch (input) {
      case kBLESystemService:
        return BLEService.systemService;
      case kBLEGpsService:
        return BLEService.gpsService;
      case kBLEMpuService:
        return BLEService.mpuService;
    }
    return BLEService.unknown;
  }

  static String servicePickerName(BLEService input) {
    switch (input) {
      case BLEService.systemService:
        return 'System Service';
      case BLEService.gpsService:
        return 'GPS Service';
      case BLEService.mpuService:
        return 'MPU Service';
      case BLEService.unknown:
        return 'Unknown';
    }
  }
}
