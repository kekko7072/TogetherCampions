import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

class SerialMonitor extends StatefulWidget {
  const SerialMonitor(
      {Key? key,
      required this.id,
      required this.isSession,
      required this.serialPort,
      required this.serialPortReader})
      : super(key: key);
  final String id;
  final bool isSession;
  final SerialPort serialPort;
  final SerialPortReader serialPortReader;

  @override
  State<SerialMonitor> createState() => _SerialMonitorState();
}

class _SerialMonitorState extends State<SerialMonitor> {
  TextEditingController input = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Serial Monitor',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: input,
                          ),
                        ),
                        IconButton(
                            onPressed: () async {
                              if (!widget.serialPort.isOpen &&
                                  !widget.serialPort.openReadWrite()) {
                                print(SerialPort.lastError);
                              } else {
                                widget.serialPort.write(
                                    Uint8List.fromList(input.text.codeUnits));

                                widget.serialPortReader.stream.listen((data) {
                                  print(
                                      'Received: ${String.fromCharCodes(data)}');
                                });
                                input.clear();
                              }
                            },
                            icon: const Icon(CupertinoIcons.paperplane_fill)),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Description:  ${widget.serialPort.description}'),
                        Text(
                            'Transport: ${widget.serialPort.transport.toTransport()}'),
                        Text(
                            'USB Bus: ${widget.serialPort.busNumber?.toPadded()}'),
                        Text(
                            'USB Device:  ${widget.serialPort.deviceNumber?.toPadded()}'),
                        Text(
                            'Vendor ID: ${widget.serialPort.vendorId?.toHex()}'),
                        Text(
                            'Product ID: ${widget.serialPort.productId?.toHex()}'),
                        Text('Manufacturer: ${widget.serialPort.manufacturer}'),
                        Text('Product Name: ${widget.serialPort.productName}'),
                        Text(
                            'Serial Number: ${widget.serialPort.serialNumber}'),
                        Text('MAC Address: ${widget.serialPort.macAddress}'),
                        Flexible(
                          child: StreamBuilder<Uint8List>(
                              stream: widget.serialPortReader.stream,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Text('...');
                                }
                                return Text(
                                    '${DateTime.now()}-->${String.fromCharCodes(snapshot.data!)}');
                              }),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
