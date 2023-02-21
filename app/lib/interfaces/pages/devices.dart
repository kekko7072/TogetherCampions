import 'package:app/services/imports.dart';
import 'package:app/services/serial_connection.dart';

class Devices extends StatefulWidget {
  const Devices({Key? key}) : super(key: key);

  @override
  State<Devices> createState() => _DevicesState();
}

extension IntToString on int {
  String toHex() => '0x${toRadixString(16)}';
  String toPadded([int width = 3]) => toString().padLeft(width, '0');
  String toTransport() {
    switch (this) {
      case SerialPortTransport.usb:
        return 'USB';
      case SerialPortTransport.bluetooth:
        return 'Bluetooth';
      case SerialPortTransport.native:
        return 'Native';
      default:
        return 'Unknown';
    }
  }
}

class _DevicesState extends State<Devices> {
  List<Device> devices = [
    Device(
        serialNumber: "serialNumber",
        modelNumber: "modelNumber",
        uid: "uid",
        name: "name",
        software: Software(name: "", version: "version"),
        devicePosition: DevicePosition(x: 0, y: 0, z: 0)),
  ];

  Stream<List<String>> streamPorts() async* {
    await Future.delayed(const Duration(seconds: 1));
    yield SerialConnectionService.connectionEnabled()
        ? SerialPort.availablePorts
        : [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Center(
                child: StreamBuilder<List<String>>(
                    stream: streamPorts(),
                    initialData: const [],
                    builder: (context, snapshot) {
                      return Wrap(
                        direction: Axis.horizontal,
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          for (Device device in devices) ...[
                            CardDevice(
                              device: device,
                              serialConnected:
                                  SerialConnectionService.checkAvailablePorts(
                                      availablePorts: snapshot.data ?? [''],
                                      serialNumber: device.serialNumber),
                              serialPort:
                                  SerialConnectionService.setSerialPorts(
                                      availablePorts: snapshot.data!,
                                      serialNumber: device.serialNumber),
                            )
                          ]
                        ],
                      );
                    })),
          ),
        ),
      ),
      floatingActionButton: TextButton(
        onPressed: () async => showModalBottomSheet(
          context: context,
          shape: AppStyle.kModalBottomStyle,
          isScrollControlled: true,
          isDismissible: true,
          builder: (context) => const AddEditDevice(isEdit: false),
        ),
        child: Card(
            margin: EdgeInsets.zero,
            color: Theme.of(context).primaryColor,
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            )),
      ),
    );
  }
}
