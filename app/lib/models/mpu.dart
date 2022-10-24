import 'dart:typed_data';

class Accelerometer {
  Accelerometer({
    required this.timestamp,
    required this.aX,
    required this.aY,
    required this.aZ,
  });

  final int timestamp;
  final int aX;
  final int aY;
  final int aZ;

  factory Accelerometer.formListInt(List<int> bit) {
    ByteBuffer buffer = Int8List.fromList(bit).buffer;
    ByteData byteData = ByteData.view(buffer);
    return Accelerometer(
      timestamp: byteData.getInt32(0, Endian.little),
      aX: byteData.getInt32(4, Endian.little),
      aY: byteData.getInt32(8, Endian.little),
      aZ: byteData.getInt32(12, Endian.little),
    );
  }

  factory Accelerometer.fromJson(Map<String, dynamic> json) => Accelerometer(
        timestamp: json["timestamp"],
        aX: json["aX"],
        aY: json["aY"],
        aZ: json["aZ"],
      );
  Map<String, dynamic> toJson() => {
        "timestamp": timestamp,
        "aX": aX,
        "aY": aY,
        "aZ": aZ,
      };
}

class Gyroscope {
  Gyroscope({
    required this.timestamp,
    required this.gX,
    required this.gY,
    required this.gZ,
  });

  final int timestamp;
  final int gX;
  final int gY;
  final int gZ;

  factory Gyroscope.formListInt(List<int> bit) {
    ByteBuffer buffer = Int8List.fromList(bit).buffer;
    ByteData byteData = ByteData.view(buffer);
    return Gyroscope(
      timestamp: byteData.getInt32(0, Endian.little),
      gX: byteData.getInt32(4, Endian.little),
      gY: byteData.getInt32(8, Endian.little),
      gZ: byteData.getInt32(12, Endian.little),
    );
  }

  factory Gyroscope.fromJson(Map<String, dynamic> json) => Gyroscope(
        timestamp: json["timestamp"],
        gX: json["gX"],
        gY: json["gY"],
        gZ: json["gZ"],
      );
  Map<String, dynamic> toJson() => {
        "timestamp": timestamp,
        "gX": gX,
        "gY": gY,
        "gZ": gZ,
      };
}
