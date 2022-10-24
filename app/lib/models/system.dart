import '../services/imports.dart';

class System {
  System({
    required this.timestamp,
    required this.battery,
    required this.temperature,
  });
  final int timestamp;
  final int battery;
  final double temperature;

  factory System.formListInt(List<int> bit) {
    ByteBuffer buffer = Int8List.fromList(bit).buffer;
    ByteData byteData = ByteData.view(buffer);
    return System(
      timestamp: byteData.getInt32(0, Endian.little),
      battery: byteData.getInt32(4, Endian.little),
      temperature:
          CalculationService.temperature(byteData.getInt32(8, Endian.little)),
    );
  }

  factory System.fromJson(Map<String, dynamic> json) => System(
        timestamp: json["timestamp"],
        battery: json["battery"],
        temperature: json["temperature"],
      );
  Map<String, dynamic> toJson() => {
        "timestamp": timestamp,
        "battery": battery,
        "temperature": temperature,
      };
}