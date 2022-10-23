import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class SessionMap extends StatefulWidget {
  const SessionMap({Key? key, required this.session, required this.gps})
      : super(key: key);

  final Session session;
  final List<GPS> gps;

  @override
  State<SessionMap> createState() => SessionMapState();
}

class SessionMapState extends State<SessionMap>
    with SingleTickerProviderStateMixin {
  late GPS start;
  late GPS end;

  late TelemetryAnalytics telemetry;

  List<MapLatLng> polylinePoints = [];

  late MapTileLayerController _mapController;

  late MapZoomPanBehavior _zoomPanBehavior;

  AnimationController? _animationController;
  late Animation<double> _animation;

  int durationDivision = 2;
  bool runningAnimation = false;
  int indexFastestLog = 0;

  @override
  void initState() {
    super.initState();
    start = widget.gps.first;
    end = widget.gps.last;

    for (GPS log in widget.gps) {
      polylinePoints.add(log.latLng);
    }

    telemetry =
        CalculationService.telemetry(gps: widget.gps, segment: polylinePoints);

    indexFastestLog = MapService.findFastestLogFromList(widget.gps);

    _mapController = MapTileLayerController();

    _zoomPanBehavior = MapService.initialCameraPosition(
        list: polylinePoints, isPreview: false);

    _animationController = AnimationController(
      duration: Duration(seconds: widget.gps.length ~/ durationDivision),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInCirc,
    );

    _animationController?.forward(from: widget.gps.length - 1);
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppStyle.backgroundColor,
      child: WillPopScope(
        onWillPop: () => Future.value(false),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TrackPreview(
                        gps: widget.gps,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
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
                                  DateFormat('EEE dd MMM yyyy')
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
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            CupertinoIcons.xmark_circle_fill,
                            size: 50,
                            color: AppStyle.primaryColor,
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        color: AppStyle.backgroundColor),
                    child: Stack(
                      children: [
                        SfMaps(
                          layers: <MapLayer>[
                            MapTileLayer(
                              /// URL to request the tiles from the providers.
                              ///
                              /// The [urlTemplate] accepts the URL in WMTS format i.e. {z} —
                              /// zoom level, {x} and {y} — tile coordinates.
                              ///
                              /// We will replace the {z}, {x}, {y} internally based on the
                              /// current center point and the zoom level.
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              zoomPanBehavior: _zoomPanBehavior,
                              controller: _mapController,
                              initialMarkersCount: widget.gps.length,
                              tooltipSettings: const MapTooltipSettings(
                                color: Colors.white,
                              ),
                              markerTooltipBuilder:
                                  (BuildContext context, int index) {
                                return ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.only(
                                              left: 10.0,
                                              top: 5.0,
                                              bottom: 5.0),
                                          width: 150,
                                          color: index == indexFastestLog
                                              ? Colors.green
                                              : Colors.white,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  index == 0
                                                      ? 'Start'
                                                      : index ==
                                                              widget.gps
                                                                      .length -
                                                                  1
                                                          ? 'End'
                                                          : 'Speed: ${widget.gps[index].speed.roundToDouble()} km/h',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5.0),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        'Altitude: ${widget.gps[index].altitude.roundToDouble()} m',
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Text(
                                                        'Course: ${widget.gps[index].course.roundToDouble()}°',
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.black),
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
                                  latitude: widget.gps[index].latLng.latitude,
                                  longitude: widget.gps[index].latLng.longitude,
                                  alignment: Alignment.bottomCenter,
                                  child: FittedBox(
                                    child: Icon(Icons.location_on,
                                        color: index == 0 ||
                                                index == widget.gps.length - 1
                                            ? AppStyle.primaryColor
                                            : index == indexFastestLog
                                                ? Colors.green
                                                : Colors.transparent,
                                        size: index == 0 ||
                                                index == widget.gps.length - 1
                                            ? 50
                                            : 20),
                                  ),
                                );
                              },

                              sublayers: <MapSublayer>[
                                MapPolylineLayer(
                                    polylines: <MapPolyline>{
                                      MapPolyline(
                                        points: polylinePoints,
                                        width: 6.0,
                                        color: AppStyle.primaryColor,
                                      )
                                    },
                                    animation: _animation,
                                    tooltipBuilder:
                                        (BuildContext context, int index) {
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
                        /* CardTelemetry(
                          id: widget.id,
                          telemetry: telemetry,
                          session: widget.session,
                        ),*/
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 10),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    child: Container(
                                      height: 35,
                                      width: 35,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Center(
                                        child: Icon(
                                          runningAnimation
                                              ? CupertinoIcons.stop_circle
                                              : CupertinoIcons.play_circle,
                                          size: 22,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      if (_animationController!.isCompleted) {
                                        _animationController?.reset();
                                      }
                                      runningAnimation
                                          ? _animationController?.stop()
                                          : _animationController?.forward();
                                      setState(() =>
                                          runningAnimation = !runningAnimation);
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    child: Container(
                                      height: 35,
                                      width: 35,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: const Center(
                                        child: Icon(
                                          CupertinoIcons.forward_end_alt,
                                          size: 22,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    onTap: () => setState(() {
                                      _animationController?.stop();
                                      durationDivision = durationDivision * 2;
                                      _animationController!.duration = Duration(
                                          seconds: widget.gps.length ~/
                                              durationDivision);

                                      _animationController?.forward();
                                    }),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
