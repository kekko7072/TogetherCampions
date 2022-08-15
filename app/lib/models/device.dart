class Device {
  Device({
    required this.id,
    required this.uid,
    required this.name,
    required this.clock,
    required this.frequency,
  });

  final String id;
  final String uid;
  final String name;
  final int clock;
  final int frequency;
}
