import 'package:app/services/imports.dart';

class SerialConnectionService {
  static bool connectionEnabled() => kIsWeb ? false : !Platform.isIOS;

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
