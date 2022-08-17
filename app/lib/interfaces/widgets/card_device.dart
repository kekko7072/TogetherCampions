import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'add_edit_device.dart';

class CardDevice extends StatefulWidget {
  const CardDevice({Key? key, required this.device, required this.uid})
      : super(key: key);
  final Device device;
  final String uid;

  @override
  State<CardDevice> createState() => _CardDeviceState();
}

class _CardDeviceState extends State<CardDevice> {
  int frequency = 0;
  @override
  void initState() {
    super.initState();
    frequency = widget.device.frequency;
  }

  bool showHelper = false;
  Timer? timer;

  Timer toastHelper(bool connected) =>
      Timer(const Duration(seconds: 3), () async {
        if (connected) {
          EasyLoading.showToast(
              'Ricordati di riavviare ${widget.device.name} per applicare le modifice.',
              duration: const Duration(seconds: 7));
        }
        await DatabaseDevice().editFrequency(
            serialNumber: widget.device.serialNumber, frequency: frequency);
      });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Log>>(
        stream: DatabaseLog(id: widget.device.serialNumber).lastLog,
        builder: (context, snapshot) {
          List<Log> logs = [];
          if (snapshot.hasData) {
            logs = snapshot.data!;
          }
          bool connected = DateTime.now().isBefore(logs.last.timestamp.add(
              Duration(
                  seconds: widget.device.clock * widget.device.frequency)));

          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Slidable(
              key: const ValueKey(0),
              startActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (con) async => await DatabaseDevice().delete(
                        id: widget.device.serialNumber, uid: widget.uid),
                    backgroundColor: const Color(0xFFFE4A49),
                    foregroundColor: Colors.black,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                  SlidableAction(
                    onPressed: (cons) async => showModalBottomSheet(
                      context: context,
                      shape: AppStyle.kModalBottomStyle,
                      isScrollControlled: true,
                      isDismissible: true,
                      builder: (context) => AddEditDevice(
                        isEdit: true,
                        uid: widget.uid,
                        device: widget.device,
                      ),
                    ),
                    backgroundColor: AppStyle.primaryColor,
                    foregroundColor: Colors.black,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                ],
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.device.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (!connected) ...[
                              Card(
                                margin: EdgeInsets.zero,
                                color: Colors.red,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'OFFLINE',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                  ),
                                ),
                              )
                            ] else ...[
                              Row(
                                children: [
                                  BatteryIndicator(
                                    batteryFromPhone: false,
                                    batteryLevel: CalculationService
                                        .calculateBatteryPercent(
                                            volts: snapshot.data!.last.battery),
                                    style: BatteryIndicatorStyle.skeumorphism,
                                    colorful: true,
                                    showPercentNum: false,
                                    size: 25,
                                    ratio: 1.5,
                                    showPercentSlide: true,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "${CalculationService.calculateBatteryPercent(volts: snapshot.data!.last.battery)} %",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            ]
                          ],
                        ),
                        GestureDetector(
                          onTap: () => showModalBottomSheet(
                            context: context,
                            shape: AppStyle.kModalBottomStyle,
                            isScrollControlled: true,
                            isDismissible: true,
                            builder: (context) => Dismissible(
                                key: UniqueKey(),
                                child: DraggableScrollableSheet(
                                    expand: false,
                                    builder: (BuildContext context,
                                        ScrollController scrollController) {
                                      return SafeArea(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15.0, horizontal: 20),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Informazioni',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Numero modello:',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                      Text(
                                                        widget
                                                            .device.modelNumber,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Numero di serie:',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                      Text(
                                                        widget.device
                                                            .serialNumber,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Software',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                      Text(
                                                        "1.0.0 Beta    Tracker OS",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Center(
                                                  child: CupertinoButton.filled(
                                                      child: const Text(
                                                          'Aggiorna'),
                                                      onPressed: () {}),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    })),
                          ),
                          child: Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 4),
                                child: Text(
                                  widget.device.serialNumber,
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.5)),
                                ),
                              )),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.0),
                          child: Center(
                              child: Image(
                            image: AssetImage('assets/tracker_image.png'),
                            height: 150,
                          )),
                        ),
                        Wrap(
                          spacing: 4,
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sincronizzazione',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Text(
                                          'Clock:  ${widget.device.clock}',
                                        ),
                                        Text(
                                          'Frequenza:  $frequency s',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${CalculationService.formatTime(seconds: widget.device.clock * frequency)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Card(
                                          child: CupertinoButton(
                                            onPressed:
                                                frequency == kFrequencyMin
                                                    ? null
                                                    : () async {
                                                        if (timer != null &&
                                                            timer!.isActive) {
                                                          timer!.cancel();
                                                        }
                                                        setState(() {
                                                          --frequency;
                                                          timer = toastHelper(
                                                              connected);
                                                        });
                                                      },
                                            child: const Icon(
                                                CupertinoIcons.minus_circle),
                                          ),
                                        ),
                                        Card(
                                          child: CupertinoButton(
                                            onPressed:
                                                frequency == kFrequencyMax
                                                    ? null
                                                    : () {
                                                        if (timer != null &&
                                                            timer!.isActive) {
                                                          timer!.cancel();
                                                        }
                                                        setState(() {
                                                          ++frequency;
                                                          timer = toastHelper(
                                                              connected);
                                                        });
                                                      },
                                            child: const Icon(
                                                CupertinoIcons.add_circled),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Posizione',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: StreamBuilder<List<Log>>(
                                          stream: DatabaseLog(
                                                  id: widget
                                                      .device.serialNumber)
                                              .lastLog,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return DeviceLocation(
                                                logs: snapshot.data!,
                                              );
                                            } else {
                                              return const Text('Mappa..');
                                            }
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () => showModalBottomSheet(
                  context: context,
                  shape: AppStyle.kModalBottomStyle,
                  isScrollControlled: true,
                  isDismissible: true,
                  builder: (context) => Dismissible(
                      key: UniqueKey(),
                      child: ListLogs(
                          id: widget.device.serialNumber, isSession: false)),
                ),
              ),
            ),
          );
        });
  }
}

class DeviceLocation extends StatefulWidget {
  const DeviceLocation({Key? key, required this.logs}) : super(key: key);
  final List<Log> logs;

  @override
  State<DeviceLocation> createState() => DeviceLocationState();
}

class DeviceLocationState extends State<DeviceLocation> {
  late GoogleMapController controller;
  final Set<Marker> _markers = {};

  late Log start;

  @override
  void initState() {
    super.initState();
    start = widget.logs.first;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: 130,
        width: 100,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: GoogleMap(
          markers: _markers,
          onMapCreated: _onMapCreated,
          scrollGesturesEnabled: false,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: false,
          mapType: MapType.satellite,
          initialCameraPosition:
              CameraPosition(target: start.gps.latLng, zoom: 14),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controllerParam) {
    setState(() {
      controller = controllerParam;

      //ADD MARKERS
      _markers.add(Marker(
        markerId: const MarkerId('start'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        position: start.gps.latLng,
        infoWindow: InfoWindow(
          title: 'Start',
          snippet:
              'Started ${start.timestamp.day}/${start.timestamp.month}/${start.timestamp.year} at ${start.timestamp.hour}:${start.timestamp.minute}',
        ),
      ));
    });
  }
}
