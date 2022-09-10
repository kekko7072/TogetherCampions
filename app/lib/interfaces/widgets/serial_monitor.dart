import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

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
  List<String> values = [];

  void sendCommand(String value) {
    widget.serialPort.write(Uint8List.fromList(value.codeUnits));

    widget.serialPortReader.stream.listen((data) {
      setState(() {
        values.addAll(String.fromCharCodes(data).split("\n"));
      });
    });
    input.clear();
  }

  ///TODO
  ///PROBLEM: every time is needed to reload code to make sure device stays connected
  ///SOLUTION: Implement a way to auto refresh the state of connection...

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: !widget.serialPort.isOpen &&
                      !widget.serialPort.openReadWrite()
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
                                      onSubmitted: (value) =>
                                          sendCommand(value),
                                      decoration: InputDecoration(
                                        hintText: 'Input command',
                                        hintStyle: const TextStyle(
                                          color: Colors.white60,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 20.0),
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(32.0)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppStyle.primaryColor,
                                              width: 2.0),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(32.0)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppStyle.primaryColor,
                                              width: 2.0),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(32.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () => sendCommand(input.text),
                                      icon: Icon(
                                        CupertinoIcons.paperplane_fill,
                                        color: AppStyle.primaryColor,
                                      )),
                                ],
                              ),
                            ),
                            Flexible(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: values.length,
                                  itemBuilder: (context, index) => Text(
                                      "${DateFormat("kk:mm:ss").format(DateTime.now())}  -->  ${values[index]}")),
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
                                            Text(
                                                'Description:  ${widget.serialPort.description}'),
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
                                            Text(
                                                'Manufacturer: ${widget.serialPort.manufacturer}'),
                                            Text(
                                                'Product Name: ${widget.serialPort.productName}'),
                                            Text(
                                                'Serial Number: ${widget.serialPort.serialNumber}'),
                                            Text(
                                                'MAC Address: ${widget.serialPort.macAddress}'),
                                          ],
                                        ),
                                      )),
                              icon: const Icon(CupertinoIcons.info)),
                        ),
                      ],
                    ),
            ),
          );
        });
  }
}
