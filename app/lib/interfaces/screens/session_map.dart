import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class SessionMap extends StatefulWidget {
  const SessionMap(
      {Key? key,
      required this.session,
      required this.unitsSystem,
      required this.gpsPosition,
      required this.gpsNavigation,
      required this.accelerometer,
      required this.gyroscope})
      : super(key: key);

  final Session session;
  final UnitsSystem unitsSystem;
  final List<GpsPosition> gpsPosition;
  final List<GpsNavigation> gpsNavigation;
  final List<Accelerometer> accelerometer;
  final List<Gyroscope> gyroscope;

  @override
  State<SessionMap> createState() => SessionMapState();
}

class SessionMapState extends State<SessionMap>
    with SingleTickerProviderStateMixin {
  late GpsPosition start;
  late GpsPosition end;

  late TelemetryAnalytics telemetry;

  List<MapLatLng> polylinePoints = [];
  List<MapLatLng> polylinePointsAnimation = [];

  late MapTileLayerController _mapController;

  late MapZoomPanBehavior _zoomPanBehavior;

  late AnimationController _animationController;

  int durationDivision = 2;
  bool runningAnimation = false;
  int indexFastestLog = 0;

  @override
  void initState() {
    super.initState();
    start = widget.gpsPosition.first;
    end = widget.gpsPosition.last;

    for (GpsPosition log in widget.gpsPosition) {
      polylinePoints.add(log.latLng);
    }

    telemetry = CalculationService.telemetry(
        gpsPosition: widget.gpsPosition,
        gpsNavigation: widget.gpsNavigation,
        segment: polylinePoints);

    indexFastestLog = MapService.findFastestLogFromList(widget.gpsPosition);

    _mapController = MapTileLayerController();

    _zoomPanBehavior = MapService.initialCameraPosition(
        list: polylinePoints, isPreview: false);

    _animationController = AnimationController(
      duration: Duration(
          seconds: (widget.gpsPosition.length - 1) ~/ durationDivision),
      animationBehavior: AnimationBehavior.normal,
      vsync: this,
    );

    _animationController.forward(from: widget.gpsPosition.length - 1);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void moveCam(int index) {
    polylinePointsAnimation.add(widget.gpsPosition[index].latLng);

    _zoomPanBehavior
      ..focalLatLng = widget.gpsPosition[index].latLng
      ..zoomLevel = 19;

    _mapController.updateMarkers([0]);
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
                        gps: widget.gpsPosition,
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
                AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, _) {
                      int index = (_animationController.value *
                              (widget.gpsPosition.length - 1))
                          .toInt();

                      int timestamp = widget.gpsPosition[index].timestamp;

                      if (index == 0) {
                        polylinePointsAnimation.clear();
                      }

                      moveCam(index);
                      return Expanded(
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
                                    initialMarkersCount:
                                        widget.gpsPosition.length,
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        index == 0
                                                            ? 'Start'
                                                            : index ==
                                                                    widget.gpsPosition
                                                                            .length -
                                                                        1
                                                                ? 'End'
                                                                : 'Speed: ${UnitsService.speedUnitsConvertFromKTS(widget.unitsSystem.speedUnits, widget.gpsPosition[index].speed).roundToDouble()} ${UnitsService.speedUnitsToString(widget.unitsSystem.speedUnits)}',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5.0),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              'Altitude: ${widget.gpsNavigation[index].altitude.roundToDouble()} m',
                                                              style: const TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            Text(
                                                              'Course: ${widget.gpsNavigation[index].course.roundToDouble()}°',
                                                              style: const TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ]),
                                              ),
                                            ]),
                                      );
                                    },
                                    markerBuilder:
                                        (BuildContext context, int i) {
                                      if (runningAnimation) {
                                        return MapMarker(
                                          latitude: widget.gpsPosition[index]
                                              .latLng.latitude,
                                          longitude: widget.gpsPosition[index]
                                              .latLng.longitude,
                                          alignment: Alignment.bottomCenter,
                                          child: RotationTransition(
                                            turns: AlwaysStoppedAnimation(
                                                (widget.gpsNavigation[index]
                                                            .course /
                                                        360)
                                                    .toDouble()),
                                            child: FittedBox(
                                              child: Icon(Icons.navigation,
                                                  color: AppStyle.primaryColor,
                                                  size: 40),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return MapMarker(
                                          latitude: widget
                                              .gpsPosition[i].latLng.latitude,
                                          longitude: widget
                                              .gpsPosition[i].latLng.longitude,
                                          alignment: Alignment.bottomCenter,
                                          child: FittedBox(
                                            child: Icon(Icons.location_on,
                                                color: i == 0 ||
                                                        i ==
                                                            widget.gpsPosition
                                                                    .length -
                                                                1
                                                    ? AppStyle.primaryColor
                                                    : i == indexFastestLog
                                                        ? Colors.green
                                                        : Colors.transparent,
                                                size: i == 0 ||
                                                        i ==
                                                            widget.gpsPosition
                                                                    .length -
                                                                1
                                                    ? 50
                                                    : 30),
                                          ),
                                        );
                                      }
                                    },
                                    sublayers: <MapSublayer>[
                                      MapPolylineLayer(
                                          polylines: <MapPolyline>{
                                            MapPolyline(
                                              points: polylinePoints,
                                              width: 6.0,
                                              color: AppStyle.primaryColor
                                                  .withOpacity(runningAnimation
                                                      ? 0.5
                                                      : 1),
                                            )
                                          },
                                          // animation: _animation,
                                          tooltipBuilder: (BuildContext context,
                                              int index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text("Track",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption!
                                                      .copyWith(
                                                          color: Colors.black)),
                                            );
                                          }),
                                      MapPolylineLayer(
                                          polylines: <MapPolyline>{
                                            MapPolyline(
                                              points: polylinePointsAnimation,
                                              width: 6.0,
                                              color: AppStyle.primaryColor,
                                            )
                                          },
                                          tooltipBuilder: (BuildContext context,
                                              int index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text("Live",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption!
                                                      .copyWith(
                                                          color: Colors.black)),
                                            );
                                          }),
                                    ],
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Card(
                                    margin: const EdgeInsets.all(10.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            CupertinoIcons.timer,
                                            size: 40,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            CalculationService.timestamp(widget
                                                .gpsPosition[index].timestamp),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Card(
                                    margin: const EdgeInsets.all(10.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                child: Column(
                                                  children: [
                                                    const Icon(
                                                      CupertinoIcons
                                                          .speedometer,
                                                      size: 40,
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      '${UnitsService.speedUnitsConvertFromKTS(widget.unitsSystem.speedUnits, widget.gpsPosition[index].speed).roundToDouble()} ${UnitsService.speedUnitsToString(widget.unitsSystem.speedUnits)}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                    Text(
                                                      'Speed',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                              color:
                                                                  Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                child: Column(
                                                  children: [
                                                    const Icon(
                                                      FontAwesomeIcons.compass,
                                                      size: 40,
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      '${widget.gpsNavigation[index].course.toStringAsFixed(0)}°',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                    Text(
                                                      'Course',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                              color:
                                                                  Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                child: Column(
                                                  children: [
                                                    const Icon(
                                                      FontAwesomeIcons.rotate,
                                                      size: 40,
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      '${CalculationService.pitch(widget.accelerometer.firstWhere((element) => '${element.timestamp}'.substring(0, 4) == '$timestamp'.substring(0, 4)))}°',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                    Text(
                                                      'Pitch',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                              color:
                                                                  Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                child: Column(
                                                  children: [
                                                    const Icon(
                                                      FontAwesomeIcons
                                                          .arrowsUpDown,
                                                      size: 40,
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      '${CalculationService.roll(widget.accelerometer.firstWhere((element) => '${element.timestamp}'.substring(0, 4) == '$timestamp'.substring(0, 4)))}°',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                    Text(
                                                      'Roll',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                              color:
                                                                  Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
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
                                                    : CupertinoIcons
                                                        .play_circle,
                                                size: 22,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            if (_animationController
                                                .isCompleted) {
                                              _animationController.reset();
                                              polylinePointsAnimation.clear();
                                            }

                                            runningAnimation
                                                ? _animationController.stop()
                                                : _animationController
                                                    .forward();
                                            setState(() => runningAnimation =
                                                !runningAnimation);
                                          },
                                        ),
                                        /*const SizedBox(width: 10),
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
                                              seconds:
                                                  (widget.gpsPosition.length - 1) ~/
                                                      durationDivision);

                                          _animationController?.forward();
                                        }),
                                      ),*/
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
