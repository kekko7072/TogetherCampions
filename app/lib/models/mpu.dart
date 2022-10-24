class Mpu {
  Mpu({
    required this.timestamp,
    required this.aX,
    required this.aY,
    required this.aZ,
    required this.gX,
    required this.gY,
    required this.gZ,
  });

  final int timestamp;
  final int aX;
  final int aY;
  final int aZ;
  final int gX;
  final int gY;
  final int gZ;
}
