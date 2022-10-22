import 'package:app/interfaces/widgets/serial_monitor.dart';
import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CardDevice extends StatefulWidget {
  const CardDevice(
      {Key? key,
      required this.device,
      required this.uid,
      required this.serialConnected,
      this.serialPort})
      : super(key: key);
  final Device device;
  final String uid;
  final bool serialConnected;
  final SerialPort? serialPort;

  @override
  State<CardDevice> createState() => _CardDeviceState();
}

class _CardDeviceState extends State<CardDevice> {
  int frequency = 0;
  Mode mode = Mode.realtime;

  bool showHelper = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    frequency = widget.device.frequency;
    mode = widget.device.mode;
  }

  Timer toastHelper(bool connected, bool isFrequency) =>
      Timer(const Duration(seconds: 3), () async {
        //if (connected) {
        EasyLoading.showToast(
            'Ricordati di spegnere e riaccendere ${widget.device.name} per applicare le modifice.',
            duration: const Duration(seconds: 7));
        //}
        if (isFrequency) {
          await DatabaseDevice().editFrequency(
              serialNumber: widget.device.serialNumber, frequency: frequency);
        } else {
          await DatabaseDevice()
              .editMode(serialNumber: widget.device.serialNumber, mode: mode);
        }
      });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: StreamBuilder<List<Log>>(
          stream: DatabaseLog(id: widget.device.serialNumber).lastLog,
          builder: (context, snapshot) {
            List<Log> logs = [];
            if (snapshot.hasData) {
              logs = snapshot.data!;
            }
            bool connected = logs.isNotEmpty
                ? DateTime.now().isBefore(logs.last.timestamp.add(Duration(
                    seconds: widget.device.clock * widget.device.frequency)))
                : false;

            return Container(
              margin: EdgeInsets.zero,
              width: AppStyle.resizeAutomaticallyWidth(context),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: AppStyle.primaryColor),
              child: Padding(
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
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: AppStyle.resizeAutomaticallyWidth(context),
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
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                              ),
                              if (connected) ...[
                                Row(
                                  children: [
                                    BatteryIndicator(
                                      batteryFromPhone: false,
                                      batteryLevel: CalculationService
                                          .calculateBatteryPercentage(
                                              volts:
                                                  snapshot.data!.last.battery),
                                      style: BatteryIndicatorStyle.skeumorphism,
                                      colorful: true,
                                      showPercentNum: false,
                                      size: 25,
                                      ratio: 1.5,
                                      showPercentSlide: true,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "${CalculationService.calculateBatteryPercentage(volts: snapshot.data!.last.battery)} %",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              ] else if (widget.serialConnected &&
                                  widget.serialPort != null) ...[
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () => showModalBottomSheet(
                                    context: context,
                                    shape: AppStyle.kModalBottomStyle,
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    builder: (context) => Dismissible(
                                        key: UniqueKey(),
                                        child: SerialMonitor(
                                          device: widget.device,
                                        )),
                                  ),
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    color: CupertinoColors.activeGreen,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'CONNECTED',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                      ),
                                    ),
                                  ),
                                )
                              ] else ...[
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
                                                                FontWeight
                                                                    .bold),
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
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .titleMedium!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                        Text(
                                                          widget.device
                                                              .modelNumber,
                                                          style:
                                                              Theme.of(context)
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
                                                          'Nome modello:',
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .titleMedium!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                        Text(
                                                          widget
                                                              .device.modelName,
                                                          style:
                                                              Theme.of(context)
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
                                                          style: Theme.of(
                                                                  context)
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
                                                          style:
                                                              Theme.of(context)
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
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .titleMedium!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                        Text(
                                                          "${widget.device.software.version}    ${widget.device.software.name}",
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Center(
                                                    child:
                                                        CupertinoButton.filled(
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
                                    widget.device.modelNumber,
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.5)),
                                  ),
                                )),
                          ),
                          const Center(
                              child: Image(
                            image: AssetImage(
                              'assets/tracker_image.png',
                            ),
                            fit: BoxFit.cover,
                            height: 150,
                          )),
                          Wrap(
                            spacing: 4,
                            children: [
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                              onPressed: frequency == 1
                                                  ? null
                                                  : () {
                                                      if (timer != null &&
                                                          timer!.isActive) {
                                                        timer!.cancel();
                                                      }
                                                      setState(() {
                                                        --frequency;
                                                        timer = toastHelper(
                                                            connected, true);
                                                      });
                                                    },
                                              child: const Icon(
                                                  CupertinoIcons.minus_circle),
                                            ),
                                          ),
                                          Card(
                                            child: CupertinoButton(
                                              onPressed: frequency == 12
                                                  ? null
                                                  : () {
                                                      if (timer != null &&
                                                          timer!.isActive) {
                                                        timer!.cancel();
                                                      }
                                                      setState(() {
                                                        ++frequency;
                                                        timer = toastHelper(
                                                            connected, true);
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Posizione',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        if (widget.serialConnected) ...[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: StreamBuilder<Position>(
                                                stream: Geolocator
                                                    .getPositionStream(),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return Container();
                                                  }
                                                  return DeviceLocation(
                                                    logs: [
                                                      Log(
                                                          id: 'connectedSerial',
                                                          timestamp:
                                                              DateTime.now(),
                                                          battery: 4.2,
                                                          gps: GPS(
                                                              latLng: MapLatLng(
                                                                  snapshot.data!
                                                                      .latitude,
                                                                  snapshot.data!
                                                                      .longitude),
                                                              altitude: snapshot
                                                                  .data!
                                                                  .altitude,
                                                              speed: snapshot
                                                                  .data!.speed,
                                                              course: 0,
                                                              satellites: 10))
                                                    ],
                                                  );
                                                }),
                                          ),
                                        ] else ...[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: StreamBuilder<List<Log>>(
                                                stream: DatabaseLog(
                                                        id: widget.device
                                                            .serialNumber)
                                                    .lastLog,
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return snapshot
                                                            .data!.isNotEmpty
                                                        ? DeviceLocation(
                                                            logs:
                                                                snapshot.data!,
                                                          )
                                                        : const SizedBox(
                                                            width: 100,
                                                            height: 130,
                                                            child: Text(
                                                              'Mappa non dipsonibile',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          );
                                                  } else {
                                                    return const SizedBox(
                                                      width: 100,
                                                      height: 130,
                                                      child: Text(
                                                        'Caricamento mappa',
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    );
                                                  }
                                                }),
                                          ),
                                        ],
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class DeviceLocation extends StatefulWidget {
  const DeviceLocation({Key? key, required this.logs}) : super(key: key);
  final List<Log> logs;

  @override
  State<DeviceLocation> createState() => DeviceLocationState();
}

class DeviceLocationState extends State<DeviceLocation> {
  late Log start;

  late MapTileLayerController _mapController;

  late MapZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();

    start = widget.logs.first;

    _mapController = MapTileLayerController();

    _zoomPanBehavior = MapZoomPanBehavior(
      zoomLevel: 15,
      minZoomLevel: 3,
      maxZoomLevel: 30,
      focalLatLng: start.gps.latLng,
      showToolbar: false,
    );
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
        child: SfMaps(
          layers: <MapLayer>[
            MapTileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              zoomPanBehavior: _zoomPanBehavior,
              controller: _mapController,
              initialMarkersCount: widget.logs.length,
              tooltipSettings: const MapTooltipSettings(
                color: Colors.white,
              ),
              markerTooltipBuilder: (BuildContext context, int index) {
                return Container();
              },
              markerBuilder: (BuildContext context, int index) {
                return MapMarker(
                  latitude: widget.logs[index].gps.latLng.latitude,
                  longitude: widget.logs[index].gps.latLng.longitude,
                  alignment: Alignment.bottomCenter,
                  child: FittedBox(
                    child: Icon(Icons.location_on,
                        color: index == 0 || index == widget.logs.length - 1
                            ? AppStyle.primaryColor
                            : AppStyle.primaryColor,
                        size: index == 0 || index == widget.logs.length - 1
                            ? 50
                            : 20),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
