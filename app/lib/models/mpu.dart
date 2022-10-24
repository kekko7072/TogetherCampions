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
  factory Mpu.fromJson(Map<String, dynamic> json) => Mpu(
        timestamp: json["timestamp"],
        aX: json["aX"],
        aY: json["aY"],
        aZ: json["aZ"],
        gX: json["gX"],
        gY: json["gY"],
        gZ: json["gZ"],
      );
  Map<String, dynamic> toJson() => {
        "timestamp": timestamp,
        "aX": aX,
        "aY": aY,
        "aZ": aZ,
        "gX": gX,
        "gY": gY,
        "gZ": gZ,
      };
}
