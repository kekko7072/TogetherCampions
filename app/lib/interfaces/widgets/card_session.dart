import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class CardSession extends StatefulWidget {
  const CardSession(
      {Key? key,
      required this.userData,
      required this.id,
      required this.session,
      required this.logs})
      : super(key: key);
  final UserData userData;
  final String id;
  final Session session;
  final List<Log> logs;

  @override
  State<CardSession> createState() => _CardSessionState();
}

class _CardSessionState extends State<CardSession> {
  List<MapLatLng> polylinePoints = [];

  @override
  void initState() {
    super.initState();

    for (Log log in widget.logs) {
      polylinePoints.add(log.gps.latLng);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Slidable(
        key: const ValueKey(0),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (con) async => await DatabaseUser.sessionCreateRemove(
                  isCreate: false,
                  uid: widget.userData.uid,
                  session: widget.session),
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
                builder: (context) => AddEditSession(
                  userData: widget.userData,
                  isEdit: true,
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
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: AppStyle.backgroundColor),
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
                              widget.session.name,
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
                                  CupertinoIcons.clock,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  DateFormat('EEE dd')
                                      .format(widget.session.start),
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
                                      .format(widget.session.start),
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
                                  CupertinoIcons.map,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${CalculationService.telemetry(logs: widget.logs, segment: polylinePoints).distance} km',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.logs.isEmpty) ...[
                      const Text('No data from GPS found...')
                    ] else ...[
                      Expanded(
                        flex: 2,
                        child: TrackPreview(
                          logs: widget.logs,
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ),
            onTap: () {
              if (widget.logs.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SessionMap(
                            id: widget.id,
                            session: widget.session,
                            logs: widget.logs,
                          )),
                );
              }
            }),
      ),
    );
  }
}

class TrackPreview extends StatefulWidget {
  const TrackPreview({Key? key, required this.logs}) : super(key: key);
  final List<Log> logs;

  @override
  State<TrackPreview> createState() => TrackPreviewState();
}

class TrackPreviewState extends State<TrackPreview> {
  late Log start;
  late Log end;

  List<MapLatLng> segment = [];

  late MapTileLayerController _mapController;

  late MapZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    start = widget.logs.first;
    end = widget.logs.last;

    for (Log log in widget.logs) {
      segment.add(log.gps.latLng);
    }

    _mapController = MapTileLayerController();

    _zoomPanBehavior = CalculationService.initialCameraPosition(
        list: segment, isPreview: true);
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
