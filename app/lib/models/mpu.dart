import 'dart:typed_data';

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

  factory Mpu.formListInt(List<int> bit) {
    ByteBuffer buffer = Int8List.fromList(bit).buffer;
    ByteData byteData = ByteData.view(buffer);
    return Mpu(
      timestamp: byteData.getInt32(0, Endian.little),
      aX: byteData.getInt32(4, Endian.little),
      aY: byteData.getInt32(8, Endian.little),
      aZ: byteData.getInt32(12, Endian.little),
      gX: byteData.getInt32(16, Endian.little),
      gY: byteData.getInt32(20, Endian.little),
      gZ: byteData.getInt32(20, Endian.little),
    );
  }

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
