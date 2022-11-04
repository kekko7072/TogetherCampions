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
  Stream<List<String>> streamPorts() async* {
    await Future.delayed(const Duration(seconds: 1));
    yield SerialConnectionService.connectionEnabled()
        ? SerialPort.availablePorts
        : [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    return userData != null
        ? Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Center(
                    child: StreamBuilder<List<Device>>(
                        stream: DatabaseDevice().allDevices(uid: userData.uid),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text('No data');
                          }
                          List<Device> devices = snapshot.data ?? [];
                          return Wrap(
                            direction: Axis.horizontal,
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              for (Device device in devices) ...[
                                CardDevice(
                                  device: device,
                                  uid: userData.uid,
                                  serialConnected: false,
                                )
                              ]
                            ],
                          );
                          /*   return StreamBuilder<List<String>>(
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
                                        uid: userData.uid,
                                        serialConnected: SerialConnectionService
                                            .checkAvailablePorts(
                                                availablePorts:
                                                    snapshot.data ?? [''],
                                                serialNumber:
                                                    device.serialNumber),
                                        serialPort: SerialConnectionService
                                            .setSerialPorts(
                                                availablePorts: snapshot.data!,
                                                serialNumber:
                                                    device.serialNumber),
                                      )
                                    ]
                                  ],
                                );
                              });*/
                        }),
                  ),
                ),
              ),
            ),
            floatingActionButton: TextButton(
              onPressed: () async => showModalBottomSheet(
                context: context,
                shape: AppStyle.kModalBottomStyle,
                isScrollControlled: true,
                isDismissible: true,
                builder: (context) => AddEditDevice(
                  uid: userData.uid,
                  isEdit: false,
                ),
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
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
