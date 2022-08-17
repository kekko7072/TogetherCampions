class Device {
  Device({
    required this.serialNumber,
    required this.modelNumber,
    required this.uid,
    required this.name,
    required this.clock,
    required this.frequency,
  });

  final String serialNumber;
  final String modelNumber;
  final String uid;
  final String name;
  final int clock;
  final int frequency;
}
