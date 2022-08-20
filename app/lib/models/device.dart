enum Mode { cloud, sdCard }

class Device {
  Device({
    required this.serialNumber,
    required this.modelNumber,
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
  final String uid;
  final String name;
  final int clock;
  final int frequency;
  final bool sdCardAvailable;
  final Mode mode;
  final Software software;
}

class Software {
  Software({
    required this.name,
    required this.version,
  });
  final String name;
  final String version;
}
