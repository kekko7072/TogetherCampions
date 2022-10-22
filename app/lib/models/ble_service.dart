import '../const.dart';

enum BLEService { systemService, telemetryService, unknown }

class BLEServiceHelper {
  ///SERVICE
  static BLEService servicePicker(String input) {
    switch (input) {
      case kBLESystemService:
        return BLEService.systemService;
      case kBLETelemetryService:
        return BLEService.telemetryService;
    }
    return BLEService.unknown;
  }

  static String servicePickerName(BLEService input) {
    switch (input) {
      case BLEService.systemService:
        return 'System Service';
      case BLEService.telemetryService:
        return 'Telemetry Service';
      case BLEService.unknown:
        return 'Unknown';
    }
  }
}
