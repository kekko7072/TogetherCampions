import 'package:flutter/cupertino.dart';

import '../../services/imports.dart';

class BLEFindDevices extends StatefulWidget {
  const BLEFindDevices({Key? key}) : super(key: key);

  @override
  State<BLEFindDevices> createState() => _BLEFindDevicesState();
}

class _BLEFindDevicesState extends State<BLEFindDevices> {
  TextEditingController model = TextEditingController(text: kDeviceModelTKR1A1);
  bool connecting = false;
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => FlutterBluePlus.instance
            .startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: Wrap(
                  spacing: 10,
                  children: [
                    FilterChip(
                        backgroundColor: model.text == kDeviceModelTKR1A1
                            ? AppStyle.primaryColor
                            : Colors.white,
                        label: Text(
                          kDeviceModelTKR1A1,
                          style: TextStyle(
                              fontWeight: model.text == kDeviceModelTKR1A1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: model.text == kDeviceModelTKR1A1
                                  ? Colors.white
                                  : AppStyle.primaryColor),
                        ),
                        onSelected: (value) =>
                            setState(() => model.text = kDeviceModelTKR1A1)),
                    FilterChip(
                        backgroundColor: model.text == kDeviceModelTKR1B1
                            ? AppStyle.primaryColor
                            : Colors.white,
                        label: Text(
                          kDeviceModelTKR1B1,
                          style: TextStyle(
                              fontWeight: model.text == kDeviceModelTKR1B1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: model.text == kDeviceModelTKR1B1
                                  ? Colors.white
                                  : AppStyle.primaryColor),
                        ),
                        onSelected: (value) =>
                            setState(() => model.text = kDeviceModelTKR1B1)),
                  ],
                ),
              ),
              if (model.text == kDeviceModelTKR1A1) ...[
                if (Platform.isAndroid) ...[
                  StreamBuilder<List<ScanResult>>(
                      stream: FlutterBluePlus.instance.scanResults,
                      initialData: const [],
                      builder: (c, snapshot) => Column(
                          children: snapshot.data!
                              .where((element) =>
                                  element.device.name == model.text)
                              .map((r) => ScanResultTile(
                                    result: r,
                                    onTap: () => showDialog(
                                        context: context,
                                        builder: (_) => CupertinoAlertDialog(
                                              title: const Text(
                                                  'Select device id'),
                                              content: StreamBuilder<
                                                      List<Device>>(
                                                  stream: DatabaseDevice()
                                                      .allDevices(
                                                          uid: userData!.uid),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasError) {
                                                      return Text(
                                                          "Error: ${snapshot.error}");
                                                    }
                                                    if (!snapshot.hasData) {
                                                      return const Text(
                                                          "No device found");
                                                    }
                                                    List<Device> devices =
                                                        snapshot.data!;
                                                    return SizedBox(
                                                      height:
                                                          (50 * devices.length)
                                                              .toDouble(),
                                                      child: ListView.builder(
                                                          itemCount:
                                                              devices.length,
                                                          itemBuilder:
                                                              (_, index) =>
                                                                  ListTile(
                                                                    title: Text(
                                                                        devices[index]
                                                                            .name),
                                                                    subtitle:
                                                                        Text(
                                                                      devices[index]
                                                                          .serialNumber,
                                                                    ),
                                                                    trailing: IconButton(
                                                                        onPressed: () async {
                                                                          try {
                                                                            if (!connecting) {
                                                                              setState(() => connecting = true);
                                                                              EasyLoading.show();
                                                                              await r.device.connect();
                                                                              setState(() => connecting = false);
                                                                              EasyLoading.dismiss().then((value) => Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                                                                    return TrackBLEScreen(
                                                                                      deviceBLE: r.device,
                                                                                      device: devices[index],
                                                                                    );
                                                                                  })));
                                                                            }
                                                                          } catch (e) {
                                                                            EasyLoading.showError(e.toString());
                                                                          }
                                                                        },
                                                                        icon: Icon(
                                                                          CupertinoIcons
                                                                              .arrow_right_circle_fill,
                                                                          color:
                                                                              AppStyle.primaryColor,
                                                                        )),
                                                                  )),
                                                    );
                                                  }),
                                              actions: [
                                                CupertinoDialogAction(
                                                  isDestructiveAction: true,
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text('Cancel'),
                                                )
                                              ],
                                            )),
                                  ))
                              .toList()))
                ] else ...[
                  StreamBuilder<List<ScanResult>>(
                    stream: FlutterBluePlus.instance.scanResults,
                    initialData: const [],
                    builder: (c, snapshot) => Column(
                      children: snapshot.data!
                          .where((element) => element.device.name == model.text)
                          .map(
                            (r) => StreamBuilder<Device>(
                                stream: DatabaseDevice()
                                    .device(id: r.device.id.toString()),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  if (!snapshot.hasData) {
                                    return const Text("Device not found");
                                  }
                                  final device = snapshot.data!;
                                  return ScanResultTile(
                                    result: r,
                                    onTap: () async => await r.device
                                        .connect()
                                        .then((value) => Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                    builder: (context) {
                                              return TrackBLEScreen(
                                                  deviceBLE: r.device,
                                                  device: device);
                                            }))),
                                  );
                                }),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ] else if (model.text == kDeviceModelTKR1B1) ...[
                ///STREAM FROM SERVER
              ]
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
                    .startScan(timeout: const Duration(seconds: 20)));
          }
        },
      ),
    );
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
      leading: Image(
        image: AssetImage(
          'assets/${result.device.name}.png',
        ),
        fit: BoxFit.cover,
        height: 150,
      ),
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
