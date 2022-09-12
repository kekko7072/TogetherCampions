import 'dart:typed_data';

///This is a WEB implementation only to allow code to work also on web,
///on future could be implemented using https://developer.mozilla.org/en-US/docs/Web/API/Navigator/serial

class SerialPort {
  final String name;

  /// Gets the description of the port, for presenting to end users.
  String? get description {
    throw 0;
  }

  /// Gets the transport type used by the port.
  ///
  /// See also:
  /// - [SerialPortTransport]
  int get transport {
    throw 0;
  }

  /// Gets the USB bus number of a USB serial adapter port.
  int? get busNumber {
    throw 0;
  }

  /// Gets the USB device number of a USB serial adapter port.
  int? get deviceNumber {
    throw 0;
  }

  /// Gets the USB vendor ID of a USB serial adapter port.
  int? get vendorId {
    throw 0;
  }

  /// Gets the USB Product ID of a USB serial adapter port.
  int? get productId {
    throw 0;
  }

  /// Get the USB manufacturer of a USB serial adapter port.
  String? get manufacturer {
    throw "";
  }

  /// Gets the USB product name of a USB serial adapter port.
  String? get productName {
    throw "";
  }

  /// Gets the USB serial number of a USB serial adapter port.
  String? get serialNumber {
    throw "";
  }

  /// Gets the MAC address of a Bluetooth serial adapter port.
  String? get macAddress {
    throw "";
  }

  static List<String> availablePorts = ['web'];
  static SerialPortError? lastError;

  SerialPort(this.name);

  bool openReadWrite() {
    return false;
  }

  bool isOpen = false;

  int write(Uint8List bytes, {int timeout = -1}) {
    return 0;
  }
}

class SerialPortError {}

class SerialPortReader {
  /// Gets the port the reader operates on.
  final SerialPort port;

  SerialPortReader(this.port);

  Stream<Uint8List> get stream {
    // TODO: implement stream
    throw UnimplementedError();
  }

  /// Closes the stream.
  //void close();
}

class SerialPortTransport {
  /// Native platform serial port. @since 0.1.1
  static const int native = 0;

  /// USB serial port adapter. @since 0.1.1
  static const int usb = 1;

  /// Bluetooth serial port adapter. @since 0.1.1
  static const int bluetooth = 2;
}
