import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../services/serial_connection.dart';

class SerialMonitor extends StatefulWidget {
  const SerialMonitor({Key? key, required this.device}) : super(key: key);
  final Device device;

  @override
  State<SerialMonitor> createState() => _SerialMonitorState();
}

class _SerialMonitorState extends State<SerialMonitor> {
  TextEditingController input = TextEditingController();
  List<String> values = [];
  List<DateTime> valuesTimestamp = [];

  void sendCommand(String value, SerialPort serialPort, SerialPortReader serialPortReader) {
    serialPort.write(Uint8List.fromList(value.codeUnits));

    serialPortReader.stream.listen((data) {
      setState(() {
        List<String> splitValue = String.fromCharCodes(data).split("\n");
        for (String element in splitValue) {
          values.add(element);
          valuesTimestamp.add(DateTime.now());
        }
      });
    });
    input.clear();
  }

  Stream<SerialPort?> streamPorts() async* {
    await Future.delayed(const Duration(seconds: 1));
    yield SerialConnectionService.setSerialPorts(availablePorts: SerialPort.availablePorts, serialNumber: widget.device.serialNumber);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: StreamBuilder<SerialPort?>(
                  stream: streamPorts(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(child: Text('No data from serial port'));
                    }
                    SerialPort serialPort = snapshot.data!;
                    return !serialPort.isOpen && !serialPort.openReadWrite()
                        ? Text('${SerialPort.lastError}')
                        : Stack(
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Serial Monitor',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: input,
                                            onSubmitted: (value) => sendCommand(value, serialPort, SerialPortReader(serialPort)),
                                            decoration: InputDecoration(
                                              hintText: 'Input command',
                                              hintStyle: const TextStyle(
                                                color: Colors.white60,
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: AppStyle.primaryColor, width: 2.0),
                                                borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: AppStyle.primaryColor, width: 2.0),
                                                borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                            onPressed: () => sendCommand(input.text, serialPort, SerialPortReader(serialPort)),
                                            icon: Icon(
                                              CupertinoIcons.paperplane_fill,
                                              color: AppStyle.primaryColor,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    child: ListView.builder(shrinkWrap: true, itemCount: values.length, itemBuilder: (context, index) => Text("${DateFormat("kk:mm:ss").format(valuesTimestamp[index])}  -->  ${values[index]}")),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                    onPressed: () => showDialog(
                                        context: context,
                                        builder: (cont) => AlertDialog(
                                              title: const Text('Device info'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('Description:  ${serialPort.description}'),
                                                  Text('Transport: ${serialPort.transport.toTransport()}'),
                                                  Text('USB Bus: ${serialPort.busNumber?.toPadded()}'),
                                                  Text('USB Device:  ${serialPort.deviceNumber?.toPadded()}'),
                                                  Text('Vendor ID: ${serialPort.vendorId?.toHex()}'),
                                                  Text('Product ID: ${serialPort.productId?.toHex()}'),
                                                  Text('Manufacturer: ${serialPort.manufacturer}'),
                                                  Text('Product Name: ${serialPort.productName}'),
                                                  Text('Serial Number: ${serialPort.serialNumber}'),
                                                  Text('MAC Address: ${serialPort.macAddress}'),
                                                ],
                                              ),
                                            )),
                                    icon: const Icon(CupertinoIcons.info)),
                              ),
                            ],
                          );
                  }),
            ),
          );
        });
  }
}
