import 'package:flutter/cupertino.dart';

import '../../services/imports.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({Key? key}) : super(key: key);

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  TextEditingController model = TextEditingController(text: kDeviceModelTKR1A1);
  bool connecting = false;

  ///CONNECTION
  TextEditingController serverController =
      TextEditingController(text: "firringer362.cloud.shiftr.io");

  TextEditingController serverUserController =
      TextEditingController(text: "firringer362");

  TextEditingController serverPasswordController =
      TextEditingController(text: "tw8hqY2Cx0v65tjp");

  TextEditingController deviceIdController =
      TextEditingController(text: "AAAA0000AAAA");

  MqttServerClient client = MqttServerClient('', '');

  late MQTTService mqttService = MQTTService(client, deviceIdController.text);

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => FlutterBluePlus.instance
            .startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                  StreamBuilder<BluetoothState>(
                      stream: FlutterBluePlus.instance.state,
                      initialData: BluetoothState.off,
                      builder: (context, snapshot) {
                        BluetoothState? state = snapshot.data;

                        if (snapshot.hasData) {
                          if (state == BluetoothState.on) {
                            if (Platform.isAndroid) {
                              return StreamBuilder<List<ScanResult>>(
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
                                                    builder: (_) => AlertDialog(
                                                          title: const Text(
                                                              'Connect to device'),
                                                          content: SizedBox(
                                                            height: 50,
                                                            child: ListTile(
                                                              title: Text(r
                                                                  .device.name),
                                                              subtitle: Text(
                                                                r.device.id.id,
                                                              ),
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(),
                                                              child: const Text(
                                                                'Cancel',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                            ),
                                                            TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  try {
                                                                    if (!connecting) {
                                                                      setState(() =>
                                                                          connecting =
                                                                              true);
                                                                      EasyLoading
                                                                          .show();
                                                                      UnitsSystem
                                                                          unitsSystem =
                                                                          await UnitsSystem
                                                                              .loadFromSettings();
                                                                      await r
                                                                          .device
                                                                          .connect();
                                                                      setState(() =>
                                                                          connecting =
                                                                              false);
                                                                      EasyLoading.dismiss().then((value) =>
                                                                          Navigator.of(context).push(MaterialPageRoute(builder:
                                                                              (context) {
                                                                            return TrackBLEScreen(
                                                                              deviceBLE: r.device,
                                                                              unitsSystem: unitsSystem,
                                                                              device: Device(serialNumber: "serialNumber", modelNumber: "modelNumber", uid: "uid", name: "name", software: Software(name: "", version: "version"), devicePosition: DevicePosition(x: 0, y: 0, z: 0)),
                                                                            );
                                                                          })));
                                                                    }
                                                                  } catch (e) {
                                                                    EasyLoading
                                                                        .showError(
                                                                            e.toString());
                                                                  }
                                                                },
                                                                child: const Text(
                                                                    'Connect')),
                                                          ],
                                                        )),
                                              ))
                                          .toList()));
                            } else {
                              ///iOS
                              return StreamBuilder<List<ScanResult>>(
                                stream: FlutterBluePlus.instance.scanResults,
                                initialData: const [],
                                builder: (c, snapshot) => Column(
                                  children: snapshot.data!
                                      .where((element) =>
                                          element.device.name == model.text)
                                      .map(
                                        (r) => ScanResultTile(
                                          result: r,
                                          onTap: () async {
                                            UnitsSystem unitsSystem =
                                                await UnitsSystem
                                                    .loadFromSettings();
                                            await r.device.connect().then(
                                                (value) => Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                            builder: (context) {
                                                      return TrackBLEScreen(
                                                          deviceBLE: r.device,
                                                          unitsSystem:
                                                              unitsSystem,
                                                          device: Device(
                                                              serialNumber:
                                                                  "serialNumber",
                                                              modelNumber:
                                                                  "modelNumber",
                                                              uid: "uid",
                                                              name: "name",
                                                              software: Software(
                                                                  name: "",
                                                                  version:
                                                                      "version"),
                                                              devicePosition:
                                                                  DevicePosition(
                                                                      x: 0,
                                                                      y: 0,
                                                                      z: 0)));
                                                    })));
                                          },
                                        ),
                                      )
                                      .toList(),
                                ),
                              );
                            }
                          } else {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.bluetooth_disabled,
                                  size: 200,
                                  color: AppStyle.primaryColor,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 40.0, horizontal: 15),
                                  child: Text(
                                    'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                CupertinoButton.filled(
                                  onPressed: Platform.isAndroid
                                      ? () => FlutterBluePlus.instance.turnOn()
                                      : () => setState(() {}),
                                  child: const Text('TURN ON'),
                                ),
                              ],
                            );
                          }
                        } else if (Platform.isMacOS ||
                            Platform.isWindows ||
                            Platform.isLinux) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.bluetooth_disabled,
                                size: 200,
                                color: AppStyle.primaryColor,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 40.0, horizontal: 15),
                                child: Text(
                                  'Bluetooth is not supported in this platform.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      })
                ] else if (model.text == kDeviceModelTKR1B1) ...[
                  const SizedBox(height: 20),
                  Text('Server address',
                      style: Theme.of(context).textTheme.titleMedium),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 20),
                    child: TextFormField(
                      controller: serverController,
                      textAlign: TextAlign.center,
                      decoration: AppStyle().kTextFieldDecoration(
                          icon: Icons.device_hub, hintText: 'Server address'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('User', style: Theme.of(context).textTheme.titleMedium),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 20),
                    child: TextFormField(
                      controller: serverUserController,
                      textAlign: TextAlign.center,
                      decoration: AppStyle().kTextFieldDecoration(
                          icon: Icons.person, hintText: 'Server address'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Password',
                      style: Theme.of(context).textTheme.titleMedium),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 20),
                    child: TextFormField(
                      controller: serverPasswordController,
                      textAlign: TextAlign.center,
                      decoration: AppStyle().kTextFieldDecoration(
                          icon: Icons.lock, hintText: 'Server address'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Device id',
                      style: Theme.of(context).textTheme.titleMedium),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 20),
                    child: TextFormField(
                      controller: deviceIdController,
                      textAlign: TextAlign.center,
                      decoration: AppStyle().kTextFieldDecoration(
                          icon: Icons.devices, hintText: 'Server address'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CupertinoButton.filled(
                        child: const Text('CONNECT TO MQTT'),
                        onPressed: () async {
                          EasyLoading.show();

                          client = MqttServerClient(serverController.text, '');
                          mqttService =
                              MQTTService(client, deviceIdController.text);

                          String clientIdentifier =
                              await mqttService.deviceInfo();

                          bool connected = await mqttService.connect(
                              user: serverUserController.text,
                              password: serverPasswordController.text,
                              clientIdentifier: clientIdentifier);
                          debugPrint("CONNECTED SUCESSSFULLY: $connected");
                          setState(() {});
                          if (connected) {
                            mqttService.subscribeToAllTopic();
                          }

                          EasyLoading.dismiss();

                          await UnitsSystem.loadFromSettings().then(
                              (unitsSystem) => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return TrackMQTTScreen(
                                      unitsSystem: unitsSystem,
                                      client: client,
                                      mqttService: mqttService,
                                    );
                                  })));
                        }),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: model.text == kDeviceModelTKR1A1
          ? StreamBuilder<bool>(
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
            )
          : Container(),
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
            style: Theme.of(context).textTheme.labelSmall,
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
          Text(title, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
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
          style: Theme.of(context).primaryTextTheme.titleSmall,
        ),
        trailing: Icon(
          Icons.error,
          color: Theme.of(context).primaryTextTheme.titleSmall?.color,
        ),
      ),
    );
  }
}
