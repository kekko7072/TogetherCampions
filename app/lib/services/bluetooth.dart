// To parse this JSON data, do
//
//     final deviceData = deviceDataFromJson(jsonString);

import 'imports.dart';

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => FlutterBluePlus.instance
            .startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(const Duration(seconds: 2))
                    .asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map((d) => ListTile(
                            title: Text(d.name),
                            subtitle: Text(d.id.toString()),
                            trailing: StreamBuilder<BluetoothDeviceState>(
                              stream: d.state,
                              initialData: BluetoothDeviceState.disconnected,
                              builder: (c, snapshot) {
                                if (snapshot.data ==
                                    BluetoothDeviceState.connected) {
                                  return ElevatedButton(
                                    child: const Text('OPEN'),
                                    onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DeviceScreen(device: d))),
                                  );
                                }
                                return Text(snapshot.data.toString());
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBluePlus.instance.scanResults,
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .where((element) => element.device.name == kDeviceName)
                      .map(
                        (r) => ScanResultTile(
                          result: r,
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            r.device.connect();
                            return DeviceScreen(device: r.device);
                          })),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBluePlus.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              onPressed: () => FlutterBluePlus.instance.stopScan(),
              backgroundColor: Colors.red,
              child: const Icon(Icons.stop),
            );
          } else {
            return FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () => FlutterBluePlus.instance
                    .startScan(timeout: const Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map(
                  (c) => CharacteristicTile(
                    characteristic: c,
                    onReadPressed: () => c.read(),
                    onWritePressed: () async {
                      await c.write(_getRandomBytes(), withoutResponse: true);
                      await c.read();
                    },
                    onNotificationPressed: () async {
                      await c.setNotifyValue(!c.isNotifying);
                      await c.read();
                    },
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return TextButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: TextStyle(color: AppStyle.primaryColor),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    snapshot.data == BluetoothDeviceState.connected
                        ? const Icon(Icons.bluetooth_connected)
                        : const Icon(Icons.bluetooth_disabled),
                    snapshot.data == BluetoothDeviceState.connected
                        ? StreamBuilder<int>(
                            stream: rssiStream(),
                            builder: (context, snapshot) {
                              return Text(
                                  snapshot.hasData ? '${snapshot.data}dBm' : '',
                                  style: Theme.of(context).textTheme.caption);
                            })
                        : Text('', style: Theme.of(context).textTheme.caption),
                  ],
                ),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data! ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => device.discoverServices(),
                      ),
                      const IconButton(
                        icon: SizedBox(
                          width: 18.0,
                          height: 18.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: const [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Stream<int> rssiStream() async* {
    var isConnected = true;
    final subscription = device.state.listen((state) {
      isConnected = state == BluetoothDeviceState.connected;
    });
    while (isConnected) {
      yield await device.readRssi();
      await Future.delayed(const Duration(seconds: 1));
    }
    subscription.cancel();
    // Device disconnected, stopping RSSI stream
  }
}

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key? key, required this.result, this.onTap})
      : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;

  Widget _buildTitle(BuildContext context) {
    if (result.device.name.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            result.device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.caption),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  ?.apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    String manufacturer = 'manufacturer';
    result.advertisementData.manufacturerData.forEach((key, value) {
      manufacturer = String.fromCharCodes(value);
    });

    return ExpansionTile(
      title: _buildTitle(context),
      leading: Text(result.rssi.toString()),
      trailing: ElevatedButton(
        onPressed: (result.advertisementData.connectable) ? onTap : null,
        child: const Text('CONNECT'),
      ),
      children: <Widget>[
        _buildAdvRow(
            context, 'Complete Local Name', result.advertisementData.localName),
        _buildAdvRow(context, 'Tx Power Level',
            '${result.advertisementData.txPowerLevel ?? 'N/A'}'),
        _buildAdvRow(context, 'Manufacturer Data', manufacturer),
        _buildAdvRow(
            context,
            'Service UUIDs',
            (result.advertisementData.serviceUuids.isNotEmpty)
                ? result.advertisementData.serviceUuids.join(', ').toUpperCase()
                : 'N/A'),
        _buildAdvRow(context, 'Service Data',
            getNiceServiceData(result.advertisementData.serviceData)),
      ],
    );
  }
}

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile(
      {Key? key, required this.service, required this.characteristicTiles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (characteristicTiles.isNotEmpty) {
      return ExpansionTile(
        initiallyExpanded: true,
        title: Text(BLEServiceHelper.servicePickerName(
            BLEServiceHelper.servicePicker(
                service.uuid.toString().toUpperCase().substring(4, 8)))),
        children: characteristicTiles,
      );
    } else {
      return ListTile(
        title: const Text('Service'),
        subtitle:
            Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}'),
      );
    }
  }
}

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  //final List<DescriptorTile> descriptorTiles;
  final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;
  final VoidCallback? onNotificationPressed;

  const CharacteristicTile(
      {Key? key,
      required this.characteristic,
      // required this.descriptorTiles,
      this.onReadPressed,
      this.onWritePressed,
      this.onNotificationPressed})
      : super(key: key);

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  @override
  void initState() {
    super.initState();
    if (widget.onNotificationPressed != null) {
      widget.onNotificationPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: widget.characteristic.value,
      initialData: widget.characteristic.lastValue,
      builder: (c, snapshot) {
        final value = snapshot.data;
        //ORIGINAL POST FOR DART: https://stackoverflow.com/a/57416590/13397584
        debugPrint(
            '\nCharacteristic: ${widget.characteristic.uuid.toString().toUpperCase().substring(4, 8)}\n');

        BLECharacteristic bleCharacteristic =
            BLECharacteristicHelper.characteristicPicker(widget
                .characteristic.uuid
                .toString()
                .toUpperCase()
                .substring(4, 8));

        String characteristic =
            BLECharacteristicHelper.characteristicPickerName(bleCharacteristic);

        ///PARSE
        switch (bleCharacteristic) {
          case BLECharacteristic.timestamp:
            {
              int timestamp = 0;

              if (value != null) {
                ByteBuffer buffer = Int8List.fromList(value).buffer;
                ByteData byteData = ByteData.view(buffer);
                try {
                  timestamp = byteData.getInt32(0, Endian.little);
                } catch (e) {
                  debugPrint("\nERROR: $e\n");
                }
              }
              return ExpansionTile(
                title: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          '$characteristic  ${Duration(milliseconds: timestamp).inHours < 1 ? '' : '${Duration(milliseconds: timestamp).inHours}:'}${Duration(milliseconds: timestamp).inMinutes.remainder(60) < 10 ? '0${Duration(milliseconds: timestamp).inMinutes.remainder(60)}' : Duration(milliseconds: timestamp).inMinutes.remainder(60)}:${(Duration(milliseconds: timestamp).inSeconds.remainder(60) < 10 ? '0${Duration(milliseconds: timestamp).inSeconds.remainder(60)}' : Duration(milliseconds: timestamp).inSeconds.remainder(60))}')
                    ],
                  ),
                  contentPadding: const EdgeInsets.all(0.0),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.file_download,
                        color:
                            Theme.of(context).iconTheme.color?.withOpacity(0.5),
                      ),
                      onPressed: widget.onReadPressed,
                    ),
                    IconButton(
                      icon: Icon(
                          widget.characteristic.isNotifying
                              ? Icons.sync_disabled
                              : Icons.sync,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withOpacity(0.5)),
                      onPressed: widget.onNotificationPressed,
                    )
                  ],
                ),
                // children: descriptorTiles,
              );
            }
          case BLECharacteristic.batteryLevel:
            {
              int batteryLevel = 0;

              if (value != null) {
                ByteBuffer buffer = Int8List.fromList(value).buffer;
                ByteData byteData = ByteData.view(buffer);
                try {
                  batteryLevel = byteData.getInt32(0, Endian.little);
                } catch (e) {
                  debugPrint("\nERROR: $e\n");
                }
              }
              return ExpansionTile(
                title: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$characteristic  $batteryLevel %',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.all(0.0),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.file_download,
                        color:
                            Theme.of(context).iconTheme.color?.withOpacity(0.5),
                      ),
                      onPressed: widget.onReadPressed,
                    ),
                    IconButton(
                      icon: Icon(
                          widget.characteristic.isNotifying
                              ? Icons.sync_disabled
                              : Icons.sync,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withOpacity(0.5)),
                      onPressed: widget.onNotificationPressed,
                    )
                  ],
                ),
                // children: descriptorTiles,
              );
            }
          case BLECharacteristic.temperature:
            {
              double temperature = 0;
              if (value != null) {
                ByteBuffer buffer = Int8List.fromList(value).buffer;
                ByteData byteData = ByteData.view(buffer);
                try {
                  temperature = byteData.getFloat32(0, Endian.little);
                } catch (e) {
                  debugPrint("\nERROR: $e\n");
                }
              }
              return ExpansionTile(
                title: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$characteristic  ${temperature.toStringAsFixed(2)} °C',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.all(0.0),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.file_download,
                        color:
                            Theme.of(context).iconTheme.color?.withOpacity(0.5),
                      ),
                      onPressed: widget.onReadPressed,
                    ),
                    IconButton(
                      icon: Icon(
                          widget.characteristic.isNotifying
                              ? Icons.sync_disabled
                              : Icons.sync,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withOpacity(0.5)),
                      onPressed: widget.onNotificationPressed,
                    )
                  ],
                ),
              );
            }

          case BLECharacteristic.accelerometer:
            {
              ///X, Y, Z
              List<int> acceleration = [0, 0, 0];

              if (value != null) {
                ByteBuffer buffer = Int8List.fromList(value).buffer;
                ByteData byteData = ByteData.view(buffer);
                try {
                  acceleration[0] = byteData.getInt32(0, Endian.little);
                  acceleration[1] = byteData.getInt32(4, Endian.little);
                  acceleration[2] = byteData.getInt32(8, Endian.little);
                } catch (e) {
                  debugPrint("\nERROR: $e\n");
                }
              }
              return ExpansionTile(
                title: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        characteristic,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                          '| A |: ${sqrt(pow(acceleration[0] / 16384.0, 2) + pow(acceleration[1] / 16384.0, 2) + pow(acceleration[2] / 16384.0, 2)).toStringAsFixed(2)} g'),
                      Wrap(
                        spacing: 10,
                        children: [
                          Text(
                            'Ax: ${(acceleration[0] / 16384.0).toStringAsFixed(2)} g',
                          ),
                          Text(
                            'Ay: ${(acceleration[1] / 16384.0).toStringAsFixed(2)} g',
                          ),
                          Text(
                            'Az: ${(acceleration[2] / 16384.0).toStringAsFixed(2)} g',
                          ),
                          /* SizedBox(
                            height: MediaQuery.of(context).size.height / 4,
                            width: MediaQuery.of(context).size.width,
                            //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

                            child: Chart(
                              data: widget.logs,
                              variables: {
                                'timestamp': Variable(
                                  accessor: (Log log) => log.timestamp,
                                  scale: TimeScale(
                                      formatter: (date) =>
                                          '${date.hour}:${date.minute < 10 ? '0${date.minute}' : date.minute}:${date.second < 10 ? '0${date.second}' : date.second}'),
                                ),
                                'speed': Variable(
                                    accessor: (Log log) => log.gps.speed,
                                    scale: LinearScale(
                                        title: 'Speed',
                                        formatter: (number) => '$number km/h')),
                              },
                              coord: RectCoord(),
                              elements: [LineElement()],
                              rebuild: true,
                              axes: [
                                Defaults.horizontalAxis,
                                Defaults.verticalAxis,
                              ],
                            ),
                          ),*/
                        ],
                      )
                    ],
                  ),
                  contentPadding: const EdgeInsets.all(0.0),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    /* IconButton(
                      icon: Icon(
                        Icons.file_download,
                        color:
                            Theme.of(context).iconTheme.color?.withOpacity(0.5),
                      ),
                      onPressed: widget.onReadPressed,
                    ),*/
                    IconButton(
                      icon: Icon(
                          widget.characteristic.isNotifying
                              ? Icons.sync_disabled
                              : Icons.sync,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withOpacity(0.5)),
                      onPressed: widget.onNotificationPressed,
                    )
                  ],
                ),
                // children: descriptorTiles,
              );
            }
          case BLECharacteristic.speed:
            {
              ///X, Y, Z
              List<double> speed = [0, 0, 0];

              if (value != null) {
                ByteBuffer buffer = Int8List.fromList(value).buffer;
                ByteData byteData = ByteData.view(buffer);
                try {
                  speed[0] = byteData.getFloat32(0, Endian.little);
                  speed[1] = byteData.getFloat32(4, Endian.little);
                  speed[2] = byteData.getFloat32(8, Endian.little);
                } catch (e) {
                  debugPrint("\nERROR: $e\n");
                }
              }
              return ExpansionTile(
                title: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        characteristic,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                        '| V |: ${sqrt(pow(speed[0], 2) + pow(speed[1], 2) + pow(speed[2], 2)).toStringAsFixed(2)} m/s',
                      ),
                      Wrap(
                        spacing: 10,
                        children: [
                          Text(
                            'Vx: ${speed[0].toStringAsFixed(2)} m/s',
                          ),
                          Text(
                            'Vy: ${speed[1].toStringAsFixed(2)} m/s',
                          ),
                          Text(
                            'Vz: ${(speed[2]).toStringAsFixed(2)} m/s',
                          ),
                        ],
                      ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.all(0.0),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.file_download,
                        color:
                            Theme.of(context).iconTheme.color?.withOpacity(0.5),
                      ),
                      onPressed: widget.onReadPressed,
                    ),
                    IconButton(
                      icon: Icon(
                          widget.characteristic.isNotifying
                              ? Icons.sync_disabled
                              : Icons.sync,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withOpacity(0.5)),
                      onPressed: widget.onNotificationPressed,
                    )
                  ],
                ),
                // children: descriptorTiles,
              );
            }

          case BLECharacteristic.gyroscope:
            {
              ///PITCH, ROLL
              List<int> gyroscope = [0, 0, 0];

              if (value != null) {
                ByteBuffer buffer = Int8List.fromList(value).buffer;
                ByteData byteData = ByteData.view(buffer);
                try {
                  gyroscope[0] = byteData.getInt32(0, Endian.little);
                  gyroscope[1] = byteData.getInt32(4, Endian.little);
                } catch (e) {
                  debugPrint("\nERROR: $e\n");
                }
              }
              return ExpansionTile(
                title: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        characteristic,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Wrap(
                        spacing: 10,
                        children: [
                          Text(
                            'Pitch: ${gyroscope[0]}°',
                          ),
                          Text(
                            'Roll: ${gyroscope[1]}°',
                          )
                        ],
                      ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.all(0.0),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.file_download,
                        color:
                            Theme.of(context).iconTheme.color?.withOpacity(0.5),
                      ),
                      onPressed: widget.onReadPressed,
                    ),
                    IconButton(
                      icon: Icon(
                          widget.characteristic.isNotifying
                              ? Icons.sync_disabled
                              : Icons.sync,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withOpacity(0.5)),
                      onPressed: widget.onNotificationPressed,
                    )
                  ],
                ),
                // children: descriptorTiles,
              );
            }
          case BLECharacteristic.gps:
            {
              List<double> gps = [0, 0];

              if (value != null) {
                ByteBuffer buffer = Int8List.fromList(value).buffer;
                ByteData byteData = ByteData.view(buffer);
                try {
                  gps[0] = byteData.getFloat32(0, Endian.little);
                  gps[1] = byteData.getFloat32(4, Endian.little);
                } catch (e) {
                  debugPrint("\nERROR: $e\n");
                }
              }
              return ExpansionTile(
                title: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        characteristic,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Wrap(
                        spacing: 10,
                        children: [
                          Text(
                            'Lat: ${gps[0]}',
                          ),
                          Text(
                            'Lng: ${gps[1]}',
                          )
                        ],
                      ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.all(0.0),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.file_download,
                        color:
                            Theme.of(context).iconTheme.color?.withOpacity(0.5),
                      ),
                      onPressed: widget.onReadPressed,
                    ),
                    IconButton(
                      icon: Icon(
                          widget.characteristic.isNotifying
                              ? Icons.sync_disabled
                              : Icons.sync,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withOpacity(0.5)),
                      onPressed: widget.onNotificationPressed,
                    )
                  ],
                ),
                // children: descriptorTiles,
              );
            }
          case BLECharacteristic.unknown:
            return const Padding(
              padding: EdgeInsets.all(10.0),
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }
}

class AdapterStateTile extends StatelessWidget {
  const AdapterStateTile({Key? key, required this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      child: ListTile(
        title: Text(
          'Bluetooth adapter is ${state.toString().substring(15)}',
          style: Theme.of(context).primaryTextTheme.subtitle2,
        ),
        trailing: Icon(
          Icons.error,
          color: Theme.of(context).primaryTextTheme.subtitle2?.color,
        ),
      ),
    );
  }
}

enum BLEService { systemService, telemetryService, unknown }

class BLEServiceHelper {
  ///SERVICE
  static BLEService servicePicker(String input) {
    switch (input) {
      case kBLESystemService:
        return BLEService.systemService;
      case kBLETelemetryService:
        return BLEService.telemetryService;
    }
    return BLEService.unknown;
  }

  static String servicePickerName(BLEService input) {
    switch (input) {
      case BLEService.systemService:
        return 'System Service';
      case BLEService.telemetryService:
        return 'Telemetry Service';
      case BLEService.unknown:
        return 'Unknown';
    }
  }
}

enum BLESystemCharacteristic { timestamp, battery, temperature, unknown }

enum BLETelemetryCharacteristic {
  accelerometer,
  speed,
  gyroscope,
  gps,
  unknown
}

enum BLECharacteristic {
  timestamp,
  batteryLevel,
  temperature,
  accelerometer,
  speed,
  gyroscope,
  gps,
  unknown
}

class BLECharacteristicHelper {
  ///CHARACTERISTIC
  static BLECharacteristic characteristicPicker(String input) {
    switch (input) {

      ///System Service
      case kBLETimestampCharacteristic:
        return BLECharacteristic.timestamp;
      case kBLEBatteryLevelCharacteristic:
        return BLECharacteristic.batteryLevel;
      case kBLETemperatureCharacteristic:
        return BLECharacteristic.temperature;

      ///Telemetry Service
      case kBLEAccelerometerCharacteristic:
        return BLECharacteristic.accelerometer;
      case kBLESpeedCharacteristic:
        return BLECharacteristic.speed;
      case kBLEGyroscopeCharacteristic:
        return BLECharacteristic.gyroscope;
      case kBLEGpsCharacteristic:
        return BLECharacteristic.gps;
    }
    return BLECharacteristic.unknown;
  }

  static BLESystemCharacteristic systemCharacteristicPicker(String input) {
    switch (input) {

      ///System Service
      case kBLETimestampCharacteristic:
        return BLESystemCharacteristic.timestamp;
      case kBLEBatteryLevelCharacteristic:
        return BLESystemCharacteristic.battery;
      case kBLETemperatureCharacteristic:
        return BLESystemCharacteristic.temperature;
    }
    return BLESystemCharacteristic.unknown;
  }

  static BLECharacteristic telemetryCharacteristicPicker(String input) {
    switch (input) {

      ///Telemetry Service
      case kBLEAccelerometerCharacteristic:
        return BLECharacteristic.accelerometer;
      case kBLESpeedCharacteristic:
        return BLECharacteristic.speed;
      case kBLEGyroscopeCharacteristic:
        return BLECharacteristic.gyroscope;
      case kBLEGpsCharacteristic:
        return BLECharacteristic.gps;
    }
    return BLECharacteristic.unknown;
  }

  static String characteristicPickerName(BLECharacteristic input) {
    switch (input) {

      ///System Service
      case BLECharacteristic.timestamp:
        return 'Timestamp';
      case BLECharacteristic.batteryLevel:
        return 'Battery Level';
      case BLECharacteristic.temperature:
        return 'Temperature';

      ///Telemetry Service
      case BLECharacteristic.accelerometer:
        return 'Accelerometer';
      case BLECharacteristic.speed:
        return 'Speed';
      case BLECharacteristic.gyroscope:
        return 'Gyroscope';
      case BLECharacteristic.gps:
        return 'Gps';
      case BLECharacteristic.unknown:
        return 'Unknown';
    }
  }
}
