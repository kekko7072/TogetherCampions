import 'package:app/services/imports.dart';

class SerialConnectionService {
  static bool connectionEnabled() {
    if (kIsWeb) {
      return false;
    } else if (Platform.isIOS || !Platform.isAndroid) {
      return false;
    } else {
      return true;
    }
  }

  static bool checkAvailablePorts(
          {required List<String> availablePorts,
          required String serialNumber}) =>
      availablePorts
          .where((element) => SerialPort(element).serialNumber == serialNumber)
          .isNotEmpty;

  static SerialPort? setSerialPorts(
          {required List<String> availablePorts,
          required String serialNumber}) =>
      checkAvailablePorts(
              availablePorts: availablePorts, serialNumber: serialNumber)
          ? SerialPort(availablePorts
              .where(
                  (element) => SerialPort(element).serialNumber == serialNumber)
              .first)
          : null;
}
