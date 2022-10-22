import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

import '../../models/ble_characteristic.dart';
import '../screens/ble_find_device.dart';
import '../../services/bluetooth_helper.dart';

class BLEDeviceScreen extends StatefulWidget {
  const BLEDeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<BLEDeviceScreen> createState() => _BLEDeviceScreenState();
}

class _BLEDeviceScreenState extends State<BLEDeviceScreen> {
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

  bool recording = false;
  @override
  void initState() {
    super.initState();
    loadServices();
  }

  void loadServices() async => await widget.device.discoverServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            CupertinoIcons.back,
            size: 40,
            color: AppStyle.primaryColor,
          ),
          onPressed: () async => showCupertinoDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => CupertinoAlertDialog(
                    title: const Text('Do you want to disconnect?'),
                    actions: [
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        child: const Text('Disconnect'),
                        onPressed: () async =>
                            await widget.device.disconnect().then((value) {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }),
                      ),
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  )),
        ),
        title: GestureDetector(
            onTap: () => showModalBottomSheet(
                  context: context,
                  shape: AppStyle.kModalBottomStyle,
                  isScrollControlled: true,
                  isDismissible: true,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.device.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      StreamBuilder<BluetoothDeviceState>(
                        stream: widget.device.state,
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
                                            snapshot.hasData
                                                ? '${snapshot.data}dBm'
                                                : '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption);
                                      })
                                  : Text('',
                                      style:
                                          Theme.of(context).textTheme.caption),
                            ],
                          ),
                          title: Text(
                              'Device is ${snapshot.data.toString().split('.')[1]}.'),
                          subtitle: Text('${widget.device.id}'),
                          trailing: StreamBuilder<bool>(
                            stream: widget.device.isDiscoveringServices,
                            initialData: false,
                            builder: (c, snapshot) => IndexedStack(
                              index: snapshot.data! ? 1 : 0,
                              children: <Widget>[
                                StreamBuilder<BluetoothDeviceState>(
                                  stream: widget.device.state,
                                  initialData: BluetoothDeviceState.connecting,
                                  builder: (c, snapshot) {
                                    VoidCallback? onPressed;
                                    IconData icon;
                                    switch (snapshot.data) {
                                      case BluetoothDeviceState.connected:
                                        onPressed =
                                            () => widget.device.disconnect();
                                        icon = Icons.bluetooth_disabled;
                                        break;
                                      case BluetoothDeviceState.disconnected:
                                        onPressed =
                                            () => widget.device.connect();
                                        icon = Icons.bluetooth;
                                        break;
                                      default:
                                        onPressed = null;
                                        icon = Icons.error_outline;
                                        debugPrint(
                                            "ERROR: ${snapshot.data.toString().substring(21).toUpperCase()}");
                                        break;
                                    }
                                    return TextButton(
                                      onPressed: onPressed,
                                      child: Icon(icon,
                                          color: AppStyle.primaryColor),
                                    );
                                  },
                                ),
                                const IconButton(
                                  icon: SizedBox(
                                    width: 18.0,
                                    height: 18.0,
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.grey),
                                    ),
                                  ),
                                  onPressed: null,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            child: Text(widget.device.name)),
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => setState(() => recording = !recording),
            icon: Icon(
              recording
                  ? CupertinoIcons.stop_circle
                  : CupertinoIcons.play_circle,
              color: AppStyle.primaryColor,
              size: 30,
            ),
          ),
          StreamBuilder<bool>(
            stream: widget.device.isDiscoveringServices,
            initialData: false,
            builder: (c, snapshot) => IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.refresh,
                color: AppStyle.primaryColor,
                size: 30,
              ),
              onPressed: () => widget.device.discoverServices(),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => widget.device.discoverServices(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  StreamBuilder<List<BluetoothService>>(
                    stream: widget.device.services,
                    builder: (c, snapshot) {
                      return Column(
                        children: _buildServiceTiles(snapshot.data!),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Stream<int> rssiStream() async* {
    var isConnected = true;
    final subscription = widget.device.state.listen((state) {
      isConnected = state == BluetoothDeviceState.connected;
    });
    while (isConnected) {
      yield await widget.device.readRssi();
      await Future.delayed(const Duration(seconds: 1));
    }
    subscription.cancel();
    // Device disconnected, stopping RSSI stream
  }
}

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile(
      {Key? key, required this.service, required this.characteristicTiles})
      : super(key: key);

  void enableNotification(BluetoothCharacteristic? characteristic) async {
    await characteristic?.setNotifyValue(true);
    await characteristic?.read();
  }

  @override
  Widget build(BuildContext context) {
    switch (BluetoothHelper.formatUUID(service.uuid)) {
      case kBLESystemService:
        {
          /// System
          List<MonoDimensionalValueInt> batteryLevels = [];
          List<MonoDimensionalValueDouble> temperatures = [];

          BluetoothCharacteristic? temperatureCharacteristic =
              BluetoothHelper.characteristic(
                  service, kBLETemperatureCharacteristic);

          enableNotification(temperatureCharacteristic);

          BluetoothCharacteristic? timestampCharacteristic =
              BluetoothHelper.characteristic(
                  service, kBLETimestampCharacteristic);

          enableNotification(timestampCharacteristic);

          BluetoothCharacteristic? batteryCharacteristic =
              BluetoothHelper.characteristic(
                  service, kBLEBatteryCharacteristic);

          enableNotification(batteryCharacteristic);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: temperatureCharacteristic != null,
                  child: GestureDetector(
                    onTap: () => showCupertinoDialog(
                        context: context,
                        builder: (_) =>
                            DataChartVisualizationTemperature(service: service),
                        barrierDismissible: true),
                    child: StreamBuilder<List<int>>(
                        stream: BluetoothHelper.characteristic(
                                service, kBLETemperatureCharacteristic)
                            ?.value,
                        initialData: BluetoothHelper.characteristic(
                                service, kBLETemperatureCharacteristic)
                            ?.lastValue,
                        builder: (c, snapshot) {
                          final value = snapshot.data;

                          if (value != null) {
                            ByteBuffer buffer = Int8List.fromList(value).buffer;
                            ByteData byteData = ByteData.view(buffer);
                            try {
                              temperatures.add(MonoDimensionalValueDouble(
                                value: CalculationService.temperature(
                                    byteData.getInt32(0, Endian.little)),
                                timestamp: byteData.getInt32(4, Endian.little),
                              ));
                            } catch (e) {
                              debugPrint("\nERROR: $e\n");
                            }
                          }

                          return temperatureCharacteristic != null &&
                                  temperatureCharacteristic.isNotifying
                              ? Text(
                                  '${temperatures.isNotEmpty ? temperatures.last.value.toStringAsFixed(2) : 'Loading...'} °C',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(fontWeight: FontWeight.bold),
                                )
                              : IconButton(
                                  icon: Icon(Icons.sync,
                                      color: Theme.of(context)
                                          .iconTheme
                                          .color
                                          ?.withOpacity(0.5)),
                                  onPressed: () async {
                                    await temperatureCharacteristic
                                        ?.setNotifyValue(
                                            !temperatureCharacteristic
                                                .isNotifying);
                                    await temperatureCharacteristic?.read();
                                  },
                                );
                        }),
                  ),
                ),
                Visibility(
                  visible: timestampCharacteristic != null,
                  child: StreamBuilder<List<int>>(
                      stream: timestampCharacteristic?.value,
                      initialData: timestampCharacteristic?.lastValue,
                      builder: (c, snapshot) {
                        final value = snapshot.data;
                        List<int> timestamps = [];
                        if (value != null) {
                          ByteBuffer buffer = Int8List.fromList(value).buffer;
                          ByteData byteData = ByteData.view(buffer);
                          try {
                            timestamps.add(byteData.getInt32(0, Endian.little));
                          } catch (e) {
                            debugPrint("\nERROR: $e\n");
                          }
                        }
                        return timestampCharacteristic != null &&
                                timestampCharacteristic.isNotifying
                            ? Text(
                                CalculationService.timestamp(timestamps.last),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              )
                            : IconButton(
                                icon: Icon(Icons.sync,
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color
                                        ?.withOpacity(0.5)),
                                onPressed: () async {
                                  await timestampCharacteristic?.setNotifyValue(
                                      !timestampCharacteristic.isNotifying);
                                  await timestampCharacteristic?.read();
                                },
                              );
                      }),
                ),
                Visibility(
                  visible: batteryCharacteristic != null,
                  child: GestureDetector(
                    onTap: () => showCupertinoDialog(
                        context: context,
                        builder: (_) =>
                            DataChartVisualizationBattery(service: service),
                        barrierDismissible: true),
                    child: StreamBuilder<List<int>>(
                        stream: batteryCharacteristic?.value,
                        initialData: batteryCharacteristic?.lastValue,
                        builder: (context, snapshot) {
                          final value = snapshot.data;
                          if (value != null) {
                            ByteBuffer buffer = Int8List.fromList(value).buffer;
                            ByteData byteData = ByteData.view(buffer);
                            try {
                              batteryLevels.add(MonoDimensionalValueInt(
                                value: byteData.getInt32(0, Endian.little),
                                timestamp: byteData.getInt32(4, Endian.little),
                              ));
                            } catch (e) {
                              debugPrint("\nERROR: $e\n");
                            }
                          }
                          return batteryCharacteristic != null &&
                                  batteryCharacteristic.isNotifying
                              ? batteryLevels.isNotEmpty
                                  ? Row(
                                      children: [
                                        BatteryIndicator(
                                          batteryFromPhone: false,
                                          batteryLevel:
                                              batteryLevels.last.value,
                                          style: BatteryIndicatorStyle
                                              .skeumorphism,
                                          colorful: true,
                                          showPercentNum: false,
                                          size: 25,
                                          ratio: 1.5,
                                          showPercentSlide: true,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "${batteryLevels.last.value} %",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  : const CircularProgressIndicator()
                              : IconButton(
                                  icon: Icon(Icons.sync,
                                      color: Theme.of(context)
                                          .iconTheme
                                          .color
                                          ?.withOpacity(0.5)),
                                  onPressed: () async {
                                    await batteryCharacteristic?.setNotifyValue(
                                        !batteryCharacteristic.isNotifying);
                                    await batteryCharacteristic?.read();
                                  },
                                );
                        }),
                  ),
                ),
              ],
            ),
          );
        }
      case kBLETelemetryService:
        //SERVICE NAME: BLEServiceHelper.servicePickerName(
        //               BLEServiceHelper.servicePicker(
        //                   service.uuid.toString().toUpperCase().substring(4, 8)))
        return Column(
          children: characteristicTiles,
        );
      default:
        return Container();
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
  ///DEFINE ALL

  /// System
  List<int> timestamps = [];
  List<MonoDimensionalValueInt> batteryLevels = [];
  List<MonoDimensionalValueDouble> temperatures = [];

  /// Telemetry
  List<ThreeDimensionalValueInt> accelerations = [];
  List<ThreeDimensionalValueDouble> speeds = [];
  List<ThreeDimensionalValueInt> gyroscopes = [];
  List<GPS> gps = [];

  @override
  void initState() {
    super.initState();
    enableNotification(widget.characteristic);
  }

  void enableNotification(BluetoothCharacteristic? characteristic) async {
    await characteristic?.setNotifyValue(true);
    await characteristic?.read();
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

        BLETelemetryCharacteristic bleCharacteristic =
            BLECharacteristicHelper.telemetryCharacteristicPicker(
                BluetoothHelper.formatUUID(widget.characteristic.uuid));

        String characteristic =
            BLECharacteristicHelper.characteristicPickerName(bleCharacteristic);

        ///PARSE
        switch (bleCharacteristic) {
          case BLETelemetryCharacteristic.accelerometer:
            {
              if (value != null) {
                ByteBuffer buffer = Int8List.fromList(value).buffer;
                ByteData byteData = ByteData.view(buffer);
                try {
                  accelerations.add(ThreeDimensionalValueInt(
                    x: byteData.getInt32(0, Endian.little),
                    y: byteData.getInt32(4, Endian.little),
                    z: byteData.getInt32(8, Endian.little),
                    timestamp: byteData.getInt32(12, Endian.little),
                  ));
                } catch (e) {
                  debugPrint("\nERROR: $e\n");
                }
              }
              return ListTile(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      characteristic,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    if (widget.characteristic.isNotifying) ...[
                      if (accelerations.isNotEmpty) ...[
                        Text(
                            '| A |: ${CalculationService.mediumAcceleration(accelerations.last).toStringAsFixed(2)} g'),
                        Wrap(
                          spacing: 10,
                          children: [
                            Text(
                              'Ax: ${(accelerations.last.x / 16384.0).toStringAsFixed(2)} g',
                            ),
                            Text(
                              'Ay: ${(accelerations.last.y / 16384.0).toStringAsFixed(2)} g',
                            ),
                            Text(
                              'Az: ${(accelerations.last.z / 16384.0).toStringAsFixed(2)} g',
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 4,
                              width: MediaQuery.of(context).size.width,
                              //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

                              child: Chart(
                                data: accelerations,
                                variables: {
                                  'timestamp': Variable(
                                    accessor: (ThreeDimensionalValueInt log) =>
                                        log.timestamp,
                                    scale: LinearScale(
                                        formatter: (number) =>
                                            CalculationService.timestamp(
                                                number.toInt())),
                                  ),
                                  'acceleration': Variable(
                                    accessor: (ThreeDimensionalValueInt log) =>
                                        sqrt(pow(log.x / 16384.0, 2) +
                                            pow(log.y / 16384.0, 2) +
                                            pow(log.z / 16384.0, 2)),
                                    scale: LinearScale(
                                        formatter: (number) => '$number g'),
                                  ),
                                },
                                coord: RectCoord(),
                                elements: [LineElement()],
                                rebuild: true,
                                axes: [
                                  Defaults.horizontalAxis,
                                  Defaults.verticalAxis,
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'Pitch: ${CalculationService.pitch(accelerations.last)}°',
                                  ),
                                  SizedBox(
                                    height: 100,

                                    //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

                                    child: Chart(
                                      data: accelerations,
                                      variables: {
                                        'timestamp': Variable(
                                          accessor:
                                              (ThreeDimensionalValueInt log) =>
                                                  log.timestamp,
                                          scale: LinearScale(
                                              formatter: (number) =>
                                                  CalculationService.timestamp(
                                                      number.toInt())),
                                        ),
                                        'pitch': Variable(
                                          accessor:
                                              (ThreeDimensionalValueInt log) =>
                                                  CalculationService.pitch(log)
                                                      .roundToDouble(),
                                          scale: LinearScale(
                                              formatter: (number) =>
                                                  '${number.roundToDouble()} °'),
                                        ),
                                      },
                                      coord: PolarCoord(),
                                      elements: [LineElement()],
                                      rebuild: true,
                                      axes: [
                                        Defaults.horizontalAxis,
                                        Defaults.verticalAxis,
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'Roll: ${CalculationService.roll(accelerations.last)}°',
                                  ),
                                  SizedBox(
                                    height: 100,
                                    //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d
                                    child: Chart(
                                      data: accelerations,
                                      variables: {
                                        'timestamp': Variable(
                                          accessor:
                                              (ThreeDimensionalValueInt log) =>
                                                  log.timestamp,
                                          scale: LinearScale(
                                              formatter: (number) =>
                                                  CalculationService.timestamp(
                                                      number.toInt())),
                                        ),
                                        'roll': Variable(
                                          accessor:
                                              (ThreeDimensionalValueInt log) =>
                                                  CalculationService.roll(log)
                                                      .toInt(),
                                          scale: LinearScale(
                                              formatter: (number) =>
                                                  '${number.toInt()} °'),
                                        ),
                                      },
                                      coord: PolarCoord(),
                                      elements: [LineElement()],
                                      rebuild: true,
                                      axes: [
                                        Defaults.horizontalAxis,
                                        Defaults.verticalAxis,
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text('Waiting $characteristic data...')
                      ]
                    ] else ...[
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
                    ]
                  ],
                ),
                contentPadding: const EdgeInsets.all(0.0),
              );
            }

          case BLETelemetryCharacteristic.gyroscope:
            {
              if (value != null) {
                ByteBuffer buffer = Int8List.fromList(value).buffer;
                ByteData byteData = ByteData.view(buffer);
                try {
                  gyroscopes.add(ThreeDimensionalValueInt(
                    x: byteData.getInt32(0, Endian.little),
                    y: byteData.getInt32(4, Endian.little),
                    z: byteData.getInt32(8, Endian.little),
                    timestamp: byteData.getInt32(12, Endian.little),
                  ));
                } catch (e) {
                  debugPrint("\nERROR: $e\n");
                }
              }
              return ListTile(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      characteristic,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    if (widget.characteristic.isNotifying) ...[
                      if (gyroscopes.isNotEmpty) ...[
                        Wrap(
                          spacing: 10,
                          children: [
                            Text(
                              'Rx: ${(gyroscopes.last.x / 131.0).toStringAsFixed(2)} °',
                            ),
                            Text(
                              'Ry: ${(gyroscopes.last.y / 131.0).toStringAsFixed(2)} °',
                            ),
                            Text(
                              'Rz: ${(gyroscopes.last.z / 131.0).toStringAsFixed(2)} °',
                            ),
                          ],
                        ),
                      ] else ...[
                        Text('Waiting $characteristic data...')
                      ]
                    ] else ...[
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
                    ]
                  ],
                ),
                contentPadding: const EdgeInsets.all(0.0),
              );
            }
          case BLETelemetryCharacteristic.gps:
            {
              bool availableGPS = false;
              int timestamp = 0;
              if (value != null) {
                ByteBuffer buffer = Int8List.fromList(value).buffer;
                ByteData byteData = ByteData.view(buffer);
                try {
                  debugPrint('GPS: ${byteData.getInt32(0, Endian.little)}');
                  availableGPS = byteData.getFloat32(0, Endian.little) == 0.0;
                  timestamp = byteData.getFloat32(16, Endian.little).toInt();
                  gps.add(GPS(
                      latLng: MapLatLng(byteData.getFloat32(4, Endian.little),
                          byteData.getFloat32(8, Endian.little)),
                      altitude: 1,
                      speed: byteData.getFloat32(12, Endian.little),
                      course: byteData.getFloat32(16, Endian.little),
                      satellites: 12));
                } catch (e) {
                  debugPrint("\nERROR: $e\n");
                }
              }
              return ListTile(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      characteristic,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    if (widget.characteristic.isNotifying) ...[
                      if (gps.isNotEmpty) ...[
                        Wrap(
                          spacing: 10,
                          children: [
                            Text('Available: $availableGPS'),
                            Text('Timestamp: $timestamp'),
                            Text(
                              'Lat: ${gps.last.latLng.latitude}',
                            ),
                            Text(
                              'Lng: ${gps.last.latLng.longitude}',
                            ),
                            Text(
                              'Speed: ${gps.last.speed}',
                            ),
                          ],
                        ),
                        DeviceLocationBLE(
                          logs: [
                            Log(
                                id: 'connectedSerial',
                                timestamp: DateTime.now(),
                                battery: 4.2,
                                gps: GPS(
                                    latLng: gps.last.latLng,
                                    altitude: gps.last.altitude,
                                    speed: gps.last.speed,
                                    course: 0,
                                    satellites: 10))
                          ],
                        ),
                      ] else ...[
                        Text('Waiting $characteristic data...')
                      ],
                    ] else ...[
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
                    ]
                  ],
                ),
                contentPadding: const EdgeInsets.all(0.0),
              );
            }
          case BLETelemetryCharacteristic.unknown:
            return const Padding(
              padding: EdgeInsets.all(10.0),
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }
}
