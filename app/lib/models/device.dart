@Deprecated('WITH BLE DEVICE IS NO MORE NECESSARY')
enum Mode { realtime, record, sync }

class Device {
  Device({
    required this.serialNumber,
    required this.modelNumber,
    required this.modelName,
    required this.uid,
    required this.name,
    required this.clock,
    required this.frequency,
    required this.sdCardAvailable,
    required this.mode,
    required this.software,
  });

  final String serialNumber;
  final String modelNumber;
  final String modelName;
  final String uid;
  final String name;
  @Deprecated('WITH BLE DEVICE IS NO MORE NECESSARY')
  final int clock;
  @Deprecated('WITH BLE DEVICE IS NO MORE NECESSARY')
  final int frequency;
  @Deprecated('WITH BLE DEVICE IS NO MORE NECESSARY')
  final bool sdCardAvailable;
  //@Deprecated
  @Deprecated('WITH BLE DEVICE IS NO MORE NECESSARY')
  final Mode mode;
  final Software software;

  ///TODO add DEVICE POSITION IN SPACE (x,y,z) to create an inertial system
}

class Software {
  Software({
    required this.name,
    required this.version,
  });
  final String name;
  final String version;
}
