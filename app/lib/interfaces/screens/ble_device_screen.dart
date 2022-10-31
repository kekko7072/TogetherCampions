import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

class BLEDeviceScreen extends StatefulWidget {
  const BLEDeviceScreen(
      {Key? key,
      required this.deviceBLE,
      required this.device,
      required this.unitsSystem})
      : super(key: key);

  final BluetoothDevice deviceBLE;
  final Device device;
  final UnitsSystem unitsSystem;

  @override
  State<BLEDeviceScreen> createState() => _BLEDeviceScreenState();
}

class _BLEDeviceScreenState extends State<BLEDeviceScreen> {
  bool recording = false;
  bool reconnectAutomatically = true;

  List<System> system = [];
  bool gpsPositionAvailable = false;
  List<GpsPosition> gpsPosition = [];
  bool gpsNavigationAvailable = false;
  List<GpsNavigation> gpsNavigation = [];
  List<Accelerometer> accelerometer = [];
  List<Gyroscope> gyroscope = [];

  //TODO USE unitsSystem

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  void loadServices() async => await widget.deviceBLE.discoverServices();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothDeviceState>(
        stream: widget.deviceBLE.state,
        initialData: BluetoothDeviceState.connected,
        builder: (context, snapshot) {
          bool showLoading = false;
          switch (snapshot.data) {
            case BluetoothDeviceState.disconnected:
              {
                showLoading = true;
                if (reconnectAutomatically) {
                  widget.deviceBLE.connect().then((value) => loadServices());
                }
                break;
              }
            case BluetoothDeviceState.connecting:
              break;
            case BluetoothDeviceState.connected:
              showLoading = false;
              break;
            case BluetoothDeviceState.disconnecting:
              showLoading = true;
              if (reconnectAutomatically) {
                widget.deviceBLE.connect().then((value) => loadServices());
              }
              break;
            case null:
              debugPrint("STATE IS NULL");
              break;
          }

          return Scaffold(
            appBar: recording
                ? AppBar(
                    automaticallyImplyLeading: false,
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
                                    widget.deviceBLE.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  StreamBuilder<BluetoothDeviceState>(
                                    stream: widget.deviceBLE.state,
                                    initialData:
                                        BluetoothDeviceState.connecting,
                                    builder: (c, snapshot) => ListTile(
                                      leading: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          snapshot.data ==
                                                  BluetoothDeviceState.connected
                                              ? const Icon(
                                                  Icons.bluetooth_connected)
                                              : const Icon(
                                                  Icons.bluetooth_disabled),
                                          snapshot.data ==
                                                  BluetoothDeviceState.connected
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
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption),
                                        ],
                                      ),
                                      title: Text(
                                          'Device is ${snapshot.data.toString().split('.')[1]}.'),
                                      subtitle: Text('${widget.deviceBLE.id}'),
                                      trailing: StreamBuilder<bool>(
                                        stream: widget
                                            .deviceBLE.isDiscoveringServices,
                                        initialData: false,
                                        builder: (c, snapshot) => IndexedStack(
                                          index: snapshot.data! ? 1 : 0,
                                          children: <Widget>[
                                            StreamBuilder<BluetoothDeviceState>(
                                              stream: widget.deviceBLE.state,
                                              initialData: BluetoothDeviceState
                                                  .connecting,
                                              builder: (c, snapshot) {
                                                VoidCallback? onPressed;
                                                IconData icon;
                                                switch (snapshot.data) {
                                                  case BluetoothDeviceState
                                                      .connected:
                                                    onPressed = () => widget
                                                        .deviceBLE
                                                        .disconnect();
                                                    icon = Icons
                                                        .bluetooth_disabled;
                                                    break;
                                                  case BluetoothDeviceState
                                                      .disconnected:
                                                    onPressed = () => widget
                                                        .deviceBLE
                                                        .connect();
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
                                                      color: AppStyle
                                                          .primaryColor),
                                                );
                                              },
                                            ),
                                            const IconButton(
                                              icon: SizedBox(
                                                width: 18.0,
                                                height: 18.0,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          Colors.grey),
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
                        child: Text(widget.deviceBLE.name)),
                    actions: <Widget>[
                      FilterChip(
                        onSelected: (value) => showCupertinoModalPopup(
                          context: context,
                          builder: (context) => CupertinoActionSheet(
                            message: const Text(
                              'Do you want to end session?',
                            ),
                            actions: [
                              CupertinoActionSheetAction(
                                  onPressed: () async {
                                    setState(
                                        () => reconnectAutomatically = false);
                                    await widget.deviceBLE
                                        .disconnect()
                                        .then((value) => showCupertinoDialog(
                                            context: context,
                                            builder: (_) => UploadSessionDialog(
                                                  device: widget.deviceBLE,
                                                  devicePosition: widget
                                                      .device.devicePosition,
                                                  system: system,
                                                  gpsPosition: gpsPosition,
                                                  gpsNavigation: gpsNavigation,
                                                  accelerometer: accelerometer,
                                                  gyroscope: gyroscope,
                                                )));
                                  },
                                  isDefaultAction: true,
                                  child: const Text('End'))
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () => Navigator.of(context).pop(),
                              isDestructiveAction: true,
                              child: const Text('Cancel'),
                            ),
                          ),
                        ),
                        backgroundColor: AppStyle.backgroundColor,
                        label: const Text(
                          'END',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10)
                    ],
                  )
                : AppBar(
                    leading: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        CupertinoIcons.xmark,
                        size: 30,
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
                                    onPressed: () async => await widget
                                        .deviceBLE
                                        .disconnect()
                                        .then((value) {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    }),
                                  ),
                                  CupertinoDialogAction(
                                    isDefaultAction: true,
                                    child: const Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
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
                                    widget.deviceBLE.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  StreamBuilder<BluetoothDeviceState>(
                                    stream: widget.deviceBLE.state,
                                    initialData:
                                        BluetoothDeviceState.connecting,
                                    builder: (c, snapshot) => ListTile(
                                      leading: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          snapshot.data ==
                                                  BluetoothDeviceState.connected
                                              ? const Icon(
                                                  Icons.bluetooth_connected)
                                              : const Icon(
                                                  Icons.bluetooth_disabled),
                                          snapshot.data ==
                                                  BluetoothDeviceState.connected
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
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption),
                                        ],
                                      ),
                                      title: Text(
                                          'Device is ${snapshot.data.toString().split('.')[1]}.'),
                                      subtitle: Text('${widget.deviceBLE.id}'),
                                      trailing: StreamBuilder<bool>(
                                        stream: widget
                                            .deviceBLE.isDiscoveringServices,
                                        initialData: false,
                                        builder: (c, snapshot) => IndexedStack(
                                          index: snapshot.data! ? 1 : 0,
                                          children: <Widget>[
                                            StreamBuilder<BluetoothDeviceState>(
                                              stream: widget.deviceBLE.state,
                                              initialData: BluetoothDeviceState
                                                  .connecting,
                                              builder: (c, snapshot) {
                                                VoidCallback? onPressed;
                                                IconData icon;
                                                switch (snapshot.data) {
                                                  case BluetoothDeviceState
                                                      .connected:
                                                    onPressed = () => widget
                                                        .deviceBLE
                                                        .disconnect();
                                                    icon = Icons
                                                        .bluetooth_disabled;
                                                    break;
                                                  case BluetoothDeviceState
                                                      .disconnected:
                                                    onPressed = () => widget
                                                        .deviceBLE
                                                        .connect();
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
                                                      color: AppStyle
                                                          .primaryColor),
                                                );
                                              },
                                            ),
                                            const IconButton(
                                              icon: SizedBox(
                                                width: 18.0,
                                                height: 18.0,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          Colors.grey),
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
                        child: Text(widget.deviceBLE.name)),
                    actions: <Widget>[
                      StreamBuilder<bool>(
                        stream: widget.deviceBLE.isDiscoveringServices,
                        initialData: false,
                        builder: (c, snapshot) => IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.refresh,
                            color: AppStyle.primaryColor,
                            size: 30,
                          ),
                          onPressed: () => widget.deviceBLE.discoverServices(),
                        ),
                      ),
                      FilterChip(
                        onSelected: (value) => setState(() {
                          recording = true;
                          system.clear();
                          gpsPosition.clear();
                          gpsNavigation.clear();
                          accelerometer.clear();
                          gyroscope.clear();
                        }),
                        backgroundColor: AppStyle.primaryColor,
                        label: const Text(
                          'START',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
            body: showLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async => await widget.deviceBLE
                        .connect()
                        .then((value) => loadServices()),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              StreamBuilder<List<BluetoothService>>(
                                stream: widget.deviceBLE.services,
                                builder: (c, snapshot) {
                                  if (snapshot.data != null) {
                                    return Column(
                                      children:
                                          _buildServiceTiles(snapshot.data!),
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          );
        });
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    void enableNotification(BluetoothCharacteristic? characteristic) async {
      await characteristic?.setNotifyValue(true);
      await characteristic?.read();
    }

    List<Widget> list = [];
    for (BluetoothService service in services) {
      if (BluetoothHelper.formatUUID(service.uuid) == kBLESystemService) {
        BluetoothCharacteristic? systemCharacteristic =
            BluetoothHelper.characteristic(service, kBLESystemCharacteristic);

        enableNotification(systemCharacteristic);

        list.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: StreamBuilder<List<int>>(
              stream: BluetoothHelper.characteristic(
                      service, kBLESystemCharacteristic)
                  ?.value,
              initialData: BluetoothHelper.characteristic(
                      service, kBLESystemCharacteristic)
                  ?.lastValue,
              builder: (c, snapshot) {
                final value = snapshot.data;

                if (value != null) {
                  try {
                    system.add(System.formListInt(value));
                  } catch (e) {
                    debugPrint('\n\n\n\nERROR PARSING VALUE SYSTEM: $e');
                  }
                }
                return systemCharacteristic != null &&
                        systemCharacteristic.isNotifying
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => showCupertinoDialog(
                                context: context,
                                builder: (_) => DataChartVisualizationSystem(
                                      service: service,
                                      systemDataVisualization:
                                          SystemDataVisualization.temperature,
                                    ),
                                barrierDismissible: true),
                            child: Text(
                              ///TODO temp in different uinits
                              '${system.isNotEmpty ? system.last.temperature.toStringAsFixed(2) : 'Loading...'} °C',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            CalculationService.timestamp(
                                system.last.timestamp - system.first.timestamp),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () => showCupertinoDialog(
                                context: context,
                                builder: (_) => DataChartVisualizationSystem(
                                      service: service,
                                      systemDataVisualization:
                                          SystemDataVisualization.battery,
                                    ),
                                barrierDismissible: true),
                            child: Row(
                              children: [
                                BatteryIndicator(
                                  batteryFromPhone: false,
                                  batteryLevel: system.last.battery,
                                  style: BatteryIndicatorStyle.skeumorphism,
                                  colorful: true,
                                  showPercentNum: false,
                                  size: 25,
                                  ratio: 1.5,
                                  showPercentSlide: true,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "${system.last.battery} %",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : IconButton(
                        icon: Icon(Icons.sync,
                            color: Theme.of(context)
                                .iconTheme
                                .color
                                ?.withOpacity(0.5)),
                        onPressed: () async {
                          await systemCharacteristic?.setNotifyValue(
                              !systemCharacteristic.isNotifying);
                          await systemCharacteristic?.read();
                        },
                      );
              }),
        ));
      } else if (BluetoothHelper.formatUUID(service.uuid) == kBLEGpsService) {
        for (var element in service.characteristics) {
          enableNotification(element);
        }
        list.addAll(service.characteristics.map((c) => StreamBuilder<List<int>>(
              stream: c.value,
              initialData: c.lastValue,
              builder: (context, snapshot) {
                final value = snapshot.data;
                //ORIGINAL POST FOR DART: https://stackoverflow.com/a/57416590/13397584

                BLEGpsCharacteristic bleCharacteristic =
                    BLECharacteristicHelper.gpsCharacteristicPicker(
                        BluetoothHelper.formatUUID(c.uuid));

                String characteristic =
                    BLECharacteristicHelper.gpsCharacteristicPickerName(
                        bleCharacteristic);

                ///PARSE
                switch (bleCharacteristic) {
                  case BLEGpsCharacteristic.position:
                    {
                      if (value != null) {
                        try {
                          gpsPositionAvailable = GpsPosition.isAvailable(value);
                          if (gpsPositionAvailable) {
                            gpsPosition.add(GpsPosition.formListInt(value));
                          }
                        } catch (e) {
                          debugPrint("\n\n\n\nERROR ADDING GPS POSITION: $e\n");
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
                            if (c.isNotifying) ...[
                              if (gpsPosition.isNotEmpty) ...[
                                if (kDebugMode) ...[
                                  Text('Available: $gpsPositionAvailable'),
                                  Wrap(
                                    spacing: 10,
                                    children: [
                                      Text(
                                          'Lat: ${gpsPosition.last.latLng.latitude.toStringAsFixed(6)}'),
                                      Text(
                                          'Lng: ${gpsPosition.last.latLng.longitude.toStringAsFixed(6)}'),
                                    ],
                                  ),
                                ],
                                TrackMap(
                                  gpsPosition: gpsPosition,
                                ),
                              ] else ...[
                                Text('Waiting $characteristic data...')
                              ],
                            ] else ...[
                              IconButton(
                                icon: Icon(
                                    c.isNotifying
                                        ? Icons.sync_disabled
                                        : Icons.sync,
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color
                                        ?.withOpacity(0.5)),
                                onPressed: () async {
                                  await c.setNotifyValue(!c.isNotifying);
                                  await c.read();
                                },
                              )
                            ]
                          ],
                        ),
                        contentPadding: const EdgeInsets.all(0.0),
                      );
                    }

                  case BLEGpsCharacteristic.navigation:
                    {
                      if (value != null) {
                        try {
                          gpsNavigationAvailable =
                              GpsNavigation.isAvailable(value);
                          if (gpsNavigationAvailable) {
                            gpsNavigation.add(GpsNavigation.formListInt(value));
                          }
                        } catch (e) {
                          debugPrint(
                              "\n\n\n\nERROR ADDING GPS NAVIGATION: $e\n");
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
                            if (c.isNotifying) ...[
                              if (gpsPosition.isNotEmpty) ...[
                                Wrap(
                                  spacing: 10,
                                  children: [
                                    Text('Available: $gpsNavigationAvailable'),
                                  ],
                                ),
                                TrackTelemetries(
                                  gpsNavigation: gpsNavigation,
                                ),
                              ] else ...[
                                Text('Waiting $characteristic data...')
                              ],
                            ] else ...[
                              IconButton(
                                icon: Icon(
                                    c.isNotifying
                                        ? Icons.sync_disabled
                                        : Icons.sync,
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color
                                        ?.withOpacity(0.5)),
                                onPressed: () async {
                                  await c.setNotifyValue(!c.isNotifying);
                                  await c.read();
                                },
                              )
                            ]
                          ],
                        ),
                        contentPadding: const EdgeInsets.all(0.0),
                      );
                    }
                  case BLEGpsCharacteristic.unknown:
                    return const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(),
                    );
                }
              },
            )));
      } else if (BluetoothHelper.formatUUID(service.uuid) == kBLEMpuService) {
        for (var element in service.characteristics) {
          enableNotification(element);
        }
        list.addAll(service.characteristics.map((c) => StreamBuilder<List<int>>(
              stream: c.value,
              initialData: c.lastValue,
              builder: (context, snapshot) {
                final value = snapshot.data;

                BLEMpuCharacteristic bleCharacteristic =
                    BLECharacteristicHelper.mpuCharacteristicPicker(
                        BluetoothHelper.formatUUID(c.uuid));

                String characteristic =
                    BLECharacteristicHelper.mpuCharacteristicPickerName(
                        bleCharacteristic);

                ///PARSE
                switch (bleCharacteristic) {
                  case BLEMpuCharacteristic.accelerometer:
                    {
                      if (value != null) {
                        try {
                          accelerometer.add(Accelerometer.formListInt(
                              value, widget.device.devicePosition));
                        } catch (e) {
                          debugPrint("\nERROR ADDING ACCELEROMETER: $e\n");
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
                            if (c.isNotifying) ...[
                              if (accelerometer.isNotEmpty) ...[
                                Text(
                                    '| A |: ${CalculationService.mediumAcceleration(accelerometer.last).toStringAsFixed(2)} g'),
                                Wrap(
                                  spacing: 10,
                                  children: [
                                    Text(
                                      'Ax: ${(accelerometer.last.aX / 16384.0).toStringAsFixed(2)} g',
                                    ),
                                    Text(
                                      'Ay: ${(accelerometer.last.aY / 16384.0).toStringAsFixed(2)} g',
                                    ),
                                    Text(
                                      'Az: ${(accelerometer.last.aZ / 16384.0).toStringAsFixed(2)} g',
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              4,
                                      width: MediaQuery.of(context).size.width,
                                      //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

                                      child: Chart(
                                        data: accelerometer,
                                        variables: {
                                          'timestamp': Variable(
                                            accessor: (Accelerometer log) =>
                                                log.timestamp -
                                                accelerometer.first.timestamp,
                                            scale: LinearScale(
                                                formatter: (number) =>
                                                    CalculationService
                                                        .timestamp(
                                                            number.toInt())),
                                          ),
                                          'acceleration': Variable(
                                            accessor: (Accelerometer log) =>
                                                CalculationService
                                                    .mediumAcceleration(log),
                                            scale: LinearScale(
                                                formatter: (number) =>
                                                    '$number g'),
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
                                            'Pitch: ${CalculationService.pitch(accelerometer.last)}°',
                                          ),
                                          SizedBox(
                                            height: 100,

                                            //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

                                            child: Chart(
                                              data: accelerometer,
                                              variables: {
                                                'timestamp': Variable(
                                                  accessor:
                                                      (Accelerometer log) =>
                                                          log.timestamp,
                                                  scale: LinearScale(
                                                      formatter: (number) =>
                                                          ''), //Leave empty
                                                ),
                                                'pitch': Variable(
                                                  accessor:
                                                      (Accelerometer log) =>
                                                          CalculationService
                                                                  .pitch(log)
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
                                            'Roll: ${CalculationService.roll(accelerometer.last)}°',
                                          ),
                                          SizedBox(
                                            height: 100,
                                            //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d
                                            child: Chart(
                                              data: accelerometer,
                                              variables: {
                                                'timestamp': Variable(
                                                  accessor:
                                                      (Accelerometer log) =>
                                                          log.timestamp,
                                                  scale: LinearScale(
                                                      formatter: (number) =>
                                                          ''), //Leave empty
                                                ),
                                                'roll': Variable(
                                                  accessor:
                                                      (Accelerometer log) =>
                                                          CalculationService
                                                                  .roll(log)
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
                                    c.isNotifying
                                        ? Icons.sync_disabled
                                        : Icons.sync,
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color
                                        ?.withOpacity(0.5)),
                                onPressed: () async {
                                  await c.setNotifyValue(!c.isNotifying);
                                  await c.read();
                                },
                              )
                            ]
                          ],
                        ),
                        contentPadding: const EdgeInsets.all(0.0),
                      );
                    }
                  case BLEMpuCharacteristic.gyroscope:
                    {
                      if (value != null) {
                        try {
                          gyroscope.add(Gyroscope.formListInt(value));
                        } catch (e) {
                          debugPrint("\nERROR ADDING GYROSCOPE: $e\n");
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
                            if (c.isNotifying) ...[
                              if (gyroscope.isNotEmpty) ...[
                                Wrap(
                                  spacing: 10,
                                  children: [
                                    Text(
                                      'Rx: ${(gyroscope.last.gX / 131.0).toStringAsFixed(2)} °',
                                    ),
                                    Text(
                                      'Ry: ${(gyroscope.last.gY / 131.0).toStringAsFixed(2)} °',
                                    ),
                                    Text(
                                      'Rz: ${(gyroscope.last.gZ / 131.0).toStringAsFixed(2)} °',
                                    ),
                                  ],
                                ),
                              ] else ...[
                                Text('Waiting $characteristic data...')
                              ]
                            ] else ...[
                              IconButton(
                                icon: Icon(
                                    c.isNotifying
                                        ? Icons.sync_disabled
                                        : Icons.sync,
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color
                                        ?.withOpacity(0.5)),
                                onPressed: () async {
                                  await c.setNotifyValue(!c.isNotifying);
                                  await c.read();
                                },
                              )
                            ]
                          ],
                        ),
                        contentPadding: const EdgeInsets.all(0.0),
                      );
                    }

                  case BLEMpuCharacteristic.unknown:
                    return const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(),
                    );
                }
              },
            )));
      }
    }

    return list;
  }

  Stream<int> rssiStream() async* {
    var isConnected = true;
    final subscription = widget.deviceBLE.state.listen((state) {
      isConnected = state == BluetoothDeviceState.connected;
    });
    while (isConnected) {
      yield await widget.deviceBLE.readRssi();
      await Future.delayed(const Duration(seconds: 1));
    }
    subscription.cancel();
    // Device disconnected, stopping RSSI stream
  }
}
