import 'imports.dart';

class BluetoothHelper {
  static String formatUUID(Guid uuid) =>
      uuid.toString().toUpperCase().substring(4, 8);

  static BluetoothCharacteristic? characteristic(
          BluetoothService? service, String uuid) =>
      service?.characteristics.firstWhere(
          (element) => BluetoothHelper.formatUUID(element.uuid) == uuid);
}
