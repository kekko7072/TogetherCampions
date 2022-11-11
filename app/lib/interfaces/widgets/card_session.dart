import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'edit_session.dart';

class CardSession extends StatefulWidget {
  const CardSession({
    Key? key,
    required this.userData,
    required this.deviceID,
    required this.session,
  }) : super(key: key);
  final UserData userData;
  final String deviceID;
  final Session session;

  @override
  State<CardSession> createState() => _CardSessionState();
}

class _CardSessionState extends State<CardSession> {
  @override
  Widget build(BuildContext context) {
    final unitSystem = Provider.of<UnitsSystem>(context);

    return FutureBuilder<SessionFile>(
        future: DatabaseSession(deviceID: widget.deviceID)
            .downloadFile(sessionID: widget.session.id)
            .then((value) {
          setState(() {});
          return SessionFile.fromJson(jsonDecode(value));
        }),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint("ERROR: ${snapshot.error}");
          }

          List<GpsPosition>? gpsPosition = snapshot.data?.gpsPosition;
          List<GpsNavigation>? gpsNavigation = snapshot.data?.gpsNavigation;
          List<Accelerometer>? accelerometer = snapshot.data?.accelerometer;
          List<Gyroscope>? gyroscope = snapshot.data?.gyroscope;
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              margin: EdgeInsets.zero,
              width: AppStyle.resizeAutomaticallyWidth(context),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: AppStyle.backgroundColor),
              child: Slidable(
                key: const ValueKey(0),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (con) async {
                        EasyLoading.show();
                        await DatabaseSession(deviceID: widget.deviceID)
                            .delete(id: widget.session.id);
                        EasyLoading.dismiss();
                      },
                      backgroundColor: CupertinoColors.destructiveRed,
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
                        builder: (context) => EditSession(
                          deviceID: widget.deviceID,
                          session: widget.session,
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
                    behavior: HitTestBehavior.translucent,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.session.info.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        CupertinoIcons.calendar,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        DateFormat('EEE dd MMM')
                                            .format(widget.session.info.start),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(
                                        CupertinoIcons.clock,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        DateFormat('kk:mm')
                                            .format(widget.session.info.start),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        '|',
                                        style: TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        DateFormat('kk:mm')
                                            .format(widget.session.info.end),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  /*
                                    //REMOVED BECAUSE REQUIRE STREAM OF HEAVY OBJECT
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.map,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '${UnitsService.distanceUnitsConvertFromMETER(unitSystem.distanceUnits, CalculationService.telemetry(
                                                gpsPosition: widget.gpsPosition,
                                                gpsNavigation: widget.gpsNavigation,
                                                segment: polylinePoints,
                                              ).distance).toStringAsFixed(2)} ${UnitsService.distanceUnitsToString(unitSystem.distanceUnits)}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),*/
                                ],
                              ),
                            ),
                          ),
                          if (gpsPosition != null &&
                              gpsPosition.isNotEmpty) ...[
                            Expanded(
                              flex: 2,
                              child: TrackPreview(gps: gpsPosition),
                            )
                          ] else ...[
                            Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      color: Colors.grey),
                                  height: 100,
                                  child: const Center(
                                      child: CircularProgressIndicator()),
                                ))
                          ]
                        ],
                      ),
                    ),
                    onTap: () {
                      if (gpsPosition != null &&
                          gpsPosition.isNotEmpty &&
                          gpsNavigation != null &&
                          gpsNavigation.isNotEmpty &&
                          accelerometer != null &&
                          accelerometer.isNotEmpty &&
                          gyroscope != null &&
                          gyroscope.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SessionMap(
                                    session: widget.session,
                                    unitsSystem: unitSystem,
                                    gpsPosition: gpsPosition,
                                    gpsNavigation: gpsNavigation,
                                    accelerometer: accelerometer,
                                    gyroscope: gyroscope,
                                  )),
                        );
                      } else {
                        EasyLoading.showInfo('Loading data...');
                      }
                    }),
              ),
            ),
          );
        });
  }
}

class TrackPreview extends StatefulWidget {
  const TrackPreview({Key? key, required this.gps}) : super(key: key);
  final List<GpsPosition> gps;

  @override
  State<TrackPreview> createState() => TrackPreviewState();
}

class TrackPreviewState extends State<TrackPreview> {
  late GpsPosition start;
  late GpsPosition end;

  List<MapLatLng> segment = [];

  late MapTileLayerController _mapController;

  late MapZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    start = widget.gps.first;
    end = widget.gps.last;

    for (GpsPosition log in widget.gps) {
      segment.add(log.latLng);
    }

    _mapController = MapTileLayerController();

    _zoomPanBehavior =
        MapService.initialCameraPosition(list: segment, isPreview: true);
  }

  @override
  Widget build(BuildContext context) {
    return segment.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : MouseRegion(
            child: IgnorePointer(
              child: Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: AppStyle.backgroundColor),
                child: SfMaps(
                  layers: <MapLayer>[
                    MapTileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      zoomPanBehavior: _zoomPanBehavior,
                      controller: _mapController,
                      initialMarkersCount: 0,
                      tooltipSettings: const MapTooltipSettings(
                        color: Colors.white,
                      ),
                      sublayers: <MapSublayer>[
                        MapPolylineLayer(
                            polylines: <MapPolyline>{
                              MapPolyline(
                                points: segment,
                                width: 6.0,
                                color: AppStyle.primaryColor,
                              )
                            },
                            tooltipBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Tracciato",
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(color: Colors.black)),
                              );
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
