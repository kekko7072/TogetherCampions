class MonoDimensionalValueInt {
  MonoDimensionalValueInt({
    required this.value,
    required this.timestamp,
  });

  final int value;
  final int timestamp;
}

class MonoDimensionalValueDouble {
  MonoDimensionalValueDouble({
    required this.value,
    required this.timestamp,
  });

  final double value;
  final int timestamp;
}

class ThreeDimensionalValueInt {
  ThreeDimensionalValueInt({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  final int x;
  final int y;
  final int z;
  final int timestamp;
}

class ThreeDimensionalValueDouble {
  ThreeDimensionalValueDouble({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  final double x;
  final double y;
  final double z;
  final int timestamp;
}
