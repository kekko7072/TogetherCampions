import 'package:app/services/imports.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CardSession extends StatelessWidget {
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
                  isCreate: false, uid: userData.uid, session: session),
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
                builder: (context) => AddEditSession(
                  userData: userData,
                  isEdit: true,
                  session: session,
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
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        session.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Inizio:'),
                        Text(CalculationService.formatDate(
                            date: session.start, year: true, seconds: false)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fine:'),
                        Text(CalculationService.formatDate(
                            date: session.end, year: true, seconds: false)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    if (logs.isEmpty) ...[
                      const Text('No data from GPS found...')
                    ] else ...[
                      TrackPreview(
                        logs: logs,
                      )
                    ]
                  ],
                ),
              ),
            ),
            onTap: () {
              if (logs.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SessionMap(
                            id: id,
                            session: session,
                            logs: logs,
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
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: SfMaps(
                  layers: <MapLayer>[
                    MapTileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      zoomPanBehavior: _zoomPanBehavior,
                      controller: _mapController,
                      initialMarkersCount: widget.logs.length,
                      tooltipSettings: const MapTooltipSettings(
                        color: Colors.white,
                      ),
                      markerTooltipBuilder: (BuildContext context, int index) {
                        return ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, top: 5.0, bottom: 5.0),
                                  width: 150,
                                  color: Colors.white,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          index == 0
                                              ? 'Start'
                                              : index == widget.logs.length - 1
                                                  ? 'End'
                                                  : 'Speed: ${widget.logs[index].gps.speed.roundToDouble()} km/h',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Altitude: ${widget.logs[index].gps.altitude.roundToDouble()} m',
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.black),
                                              ),
                                              Text(
                                                'Course: ${widget.logs[index].gps.course.roundToDouble()}°',
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        )
                                      ]),
                                ),
                              ]),
                        );
                      },
                      markerBuilder: (BuildContext context, int index) {
                        return MapMarker(
                          latitude: widget.logs[index].gps.latLng.latitude,
                          longitude: widget.logs[index].gps.latLng.longitude,
                          alignment: Alignment.bottomCenter,
                          child: FittedBox(
                            child: Icon(Icons.location_on,
                                color: index == 0 ||
                                        index == widget.logs.length - 1
                                    ? Colors.blue
                                    : AppStyle.primaryColor,
                                size: index == 0 ||
                                        index == widget.logs.length - 1
                                    ? 50
                                    : 20),
                          ),
                        );
                      },
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
