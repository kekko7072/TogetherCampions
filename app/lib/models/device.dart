import 'package:app/models/session.dart';

@Deprecated('WITH BLE DEVICE IS NO MORE NECESSARY')
enum Mode { realtime, record, sync }

class Device {
  Device({
    required this.serialNumber,
    required this.modelNumber,
    required this.uid,
    required this.name,
    required this.software,
    required this.devicePosition,
  });

  final String serialNumber;
  final String modelNumber;
  final String uid;
  final String name;
  final Software software;
  final DevicePosition devicePosition;
}

class Software {
  Software({
    required this.name,
    required this.version,
  });
  final String name;
  final String version;
}
