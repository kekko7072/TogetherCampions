import '../../services/imports.dart';

class BLEFindDevices extends StatefulWidget {
  const BLEFindDevices({Key? key}) : super(key: key);

  @override
  State<BLEFindDevices> createState() => _BLEFindDevicesState();
}

class _BLEFindDevicesState extends State<BLEFindDevices> {
  TextEditingController model = TextEditingController(text: kDeviceModelTKR1A1);

  @override
  Widget build(BuildContext context) {
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
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(const Duration(seconds: 2))
                    .asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .where((element) => element.name == model.text)
                      .map((d) => ListTile(
                            leading: Image(
                              image: AssetImage(
                                'assets/${d.name}.png',
                              ),
                              fit: BoxFit.cover,
                              height: 150,
                            ),
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
                                                BLEDeviceScreen(device: d))),
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
                      .where((element) => element.device.name == model.text)
                      .map(
                        (r) => ScanResultTile(
                          result: r,
                          onTap: () async => await r.device.connect().then(
                              (value) => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return BLEDeviceScreen(device: r.device);
                                  }))),
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
