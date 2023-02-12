import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class SessionMap extends StatefulWidget {
  const SessionMap({
    Key? key,
    required this.sessionFile,
    required this.unitsSystem,
  }) : super(key: key);

  final SessionFile sessionFile;
  final UnitsSystem unitsSystem;

  @override
  State<SessionMap> createState() => SessionMapState();
}

class SessionMapState extends State<SessionMap>
    with SingleTickerProviderStateMixin {
  late TimestampF start;
  late TimestampF end;

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
    if (widget.sessionFile.timestamp != null) {
      start = widget.sessionFile.timestamp!.first;
      end = widget.sessionFile.timestamp!.last;

      for (TimestampF log in widget.sessionFile.timestamp!) {
        if (log.gpsPosition != null) {
          polylinePoints.add(log.gpsPosition!.latLng);
        }
      }

      telemetry = CalculationService.telemetry(
          timestamp: widget.sessionFile.timestamp!, segment: polylinePoints);

      if (polylinePoints.isNotEmpty) {
        indexFastestLog =
            MapService.findFastestLogFromList(widget.sessionFile.timestamp!);

        _mapController = MapTileLayerController();

        _zoomPanBehavior = MapService.initialCameraPosition(
            list: polylinePoints, isPreview: false);

        _animationController = AnimationController(
          duration: Duration(
              seconds: (widget.sessionFile.timestamp!.length - 1) ~/
                  durationDivision),
          animationBehavior: AnimationBehavior.normal,
          vsync: this,
        );

        _animationController.forward(
            from: widget.sessionFile.timestamp!.length - 1);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void moveCam(int index) {
    if (widget.sessionFile.timestamp != null &&
        widget.sessionFile.timestamp![index].gpsPosition != null) {
      polylinePointsAnimation
          .add(widget.sessionFile.timestamp![index].gpsPosition!.latLng);

      _zoomPanBehavior
        ..focalLatLng = widget.sessionFile.timestamp![index].gpsPosition!.latLng
        ..zoomLevel = 19;
    }

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
                    if (widget.sessionFile.timestamp != null) ...[
                      Expanded(
                        flex: 2,
                        child: TrackPreview(
                          timestamp: widget.sessionFile.timestamp!,
                        ),
                      ),
                    ],
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
                              widget.sessionFile.info!.name,
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
                                      .format(widget.sessionFile.info!.start),
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
                                      .format(widget.sessionFile.info!.start),
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
                                      .format(widget.sessionFile.info!.end),
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
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
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

                ///GPS AVAILABLE
                if (polylinePoints.isNotEmpty) ...[
                  AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, _) {
                        int index = (_animationController.value *
                                (widget.sessionFile.timestamp!.length - 1))
                            .toInt();

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
                                          widget.sessionFile.timestamp!.length,
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0,
                                                          top: 5.0,
                                                          bottom: 5.0),
                                                  width: 150,
                                                  color:
                                                      index == indexFastestLog
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
                                                                      widget.sessionFile.timestamp!
                                                                              .length -
                                                                          1
                                                                  ? 'End'
                                                                  : 'Speed: ${UnitsService.speedUnitsConvertFromKTS(widget.unitsSystem.speedUnits, widget.sessionFile.timestamp?[index].gpsPosition?.speed).roundToDouble()} ${UnitsService.speedUnitsToString(widget.unitsSystem.speedUnits)}',
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 5.0),
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                'Altitude: ${widget.sessionFile.timestamp?[index].gpsNavigation?.altitude.roundToDouble()} m',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                              Text(
                                                                'Course: ${widget.sessionFile.timestamp?[index].gpsNavigation?.course.roundToDouble()}°',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        10,
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
                                        if (widget.sessionFile.timestamp !=
                                                null &&
                                            widget.sessionFile.timestamp![index]
                                                    .gpsPosition !=
                                                null) {
                                          if (runningAnimation) {
                                            return MapMarker(
                                              latitude: widget
                                                  .sessionFile
                                                  .timestamp![index]
                                                  .gpsPosition!
                                                  .latLng
                                                  .latitude,
                                              longitude: widget
                                                  .sessionFile
                                                  .timestamp![index]
                                                  .gpsPosition!
                                                  .latLng
                                                  .longitude,
                                              alignment: Alignment.bottomCenter,
                                              child: RotationTransition(
                                                turns: AlwaysStoppedAnimation(
                                                    (widget
                                                                .sessionFile
                                                                .timestamp?[
                                                                    index]
                                                                .gpsNavigation
                                                                ?.course ??
                                                            0 / 360)
                                                        .toDouble()),
                                                child: const FittedBox(
                                                  child: Icon(Icons.navigation,
                                                      color:
                                                          AppStyle.primaryColor,
                                                      size: 40),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return MapMarker(
                                              latitude: widget
                                                  .sessionFile
                                                  .timestamp![i]
                                                  .gpsPosition!
                                                  .latLng
                                                  .latitude,
                                              longitude: widget
                                                  .sessionFile
                                                  .timestamp![index]
                                                  .gpsPosition!
                                                  .latLng
                                                  .longitude,
                                              alignment: Alignment.bottomCenter,
                                              child: FittedBox(
                                                child: Icon(Icons.location_on,
                                                    color: i == 0 ||
                                                            i ==
                                                                widget
                                                                        .sessionFile
                                                                        .timestamp!
                                                                        .length -
                                                                    1
                                                        ? AppStyle.primaryColor
                                                        : i == indexFastestLog
                                                            ? Colors.green
                                                            : Colors
                                                                .transparent,
                                                    size: i == 0 ||
                                                            i ==
                                                                widget
                                                                        .sessionFile
                                                                        .timestamp!
                                                                        .length -
                                                                    1
                                                        ? 50
                                                        : 30),
                                              ),
                                            );
                                          }
                                        } else {
                                          return MapMarker(
                                              latitude: 0.0, longitude: 0.0);
                                        }
                                      },
                                      sublayers: <MapSublayer>[
                                        MapPolylineLayer(
                                            polylines: <MapPolyline>{
                                              MapPolyline(
                                                points: polylinePoints,
                                                width: 6.0,
                                                color: AppStyle.primaryColor
                                                    .withOpacity(
                                                        runningAnimation
                                                            ? 0.5
                                                            : 1),
                                              )
                                            },
                                            // animation: _animation,
                                            tooltipBuilder:
                                                (BuildContext context,
                                                    int index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text("Track",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption!
                                                        .copyWith(
                                                            color:
                                                                Colors.black)),
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
                                            tooltipBuilder:
                                                (BuildContext context,
                                                    int index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text("Live",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption!
                                                        .copyWith(
                                                            color:
                                                                Colors.black)),
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
                                              CalculationService.timestamp(
                                                  widget
                                                      .sessionFile
                                                      .timestamp?[index]
                                                      .gpsPosition
                                                      ?.timestamp),
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                  behavior: HitTestBehavior
                                                      .translucent,
                                                  child: Column(
                                                    children: [
                                                      const Icon(
                                                        CupertinoIcons
                                                            .speedometer,
                                                        size: 40,
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        '${UnitsService.speedUnitsConvertFromKTS(widget.unitsSystem.speedUnits, widget.sessionFile.timestamp?[index].gpsPosition?.speed).roundToDouble()} ${UnitsService.speedUnitsToString(widget.unitsSystem.speedUnits)}',
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
                                                                color: Colors
                                                                    .grey),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  behavior: HitTestBehavior
                                                      .translucent,
                                                  child: Column(
                                                    children: [
                                                      const Icon(
                                                        FontAwesomeIcons
                                                            .compass,
                                                        size: 40,
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        '${widget.sessionFile.timestamp?[index].gpsNavigation?.course.toStringAsFixed(0)}°',
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
                                                                color: Colors
                                                                    .grey),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  behavior: HitTestBehavior
                                                      .translucent,
                                                  child: Column(
                                                    children: [
                                                      const Icon(
                                                        FontAwesomeIcons.rotate,
                                                        size: 40,
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        '${CalculationService.pitch(widget.sessionFile.timestamp?[index].accelerometer)}°',
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
                                                                color: Colors
                                                                    .grey),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  behavior: HitTestBehavior
                                                      .translucent,
                                                  child: Column(
                                                    children: [
                                                      const Icon(
                                                        FontAwesomeIcons
                                                            .arrowsUpDown,
                                                        size: 40,
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        '${CalculationService.roll(widget.sessionFile.timestamp?[index].accelerometer)}°',
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
                                                                color: Colors
                                                                    .grey),
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
                                                      ? CupertinoIcons
                                                          .stop_circle
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

                  ///NO GPS AVAILABLE BUT OTHER DATA YES
                ] else if (widget.sessionFile.timestamp != null) ...[
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.sessionFile.timestamp!.length,
                        itemBuilder: (_, index) {
                          return ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${UnitsService.temperatureUnitsFromCELSIUS(widget.unitsSystem.temperatureUnits, widget.sessionFile.timestamp![index].system!.temperature).toStringAsFixed(2)} ${UnitsService.temperatureUnitsToString(widget.unitsSystem.temperatureUnits)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  CalculationService.timestamp(widget
                                      .sessionFile
                                      .timestamp![index]
                                      .system!
                                      .timestamp),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    BatteryIndicator(
                                      batteryFromPhone: false,
                                      batteryLevel: widget.sessionFile
                                          .timestamp![index].system!.battery,
                                      style: BatteryIndicatorStyle.skeumorphism,
                                      colorful: true,
                                      showPercentNum: false,
                                      size: 25,
                                      ratio: 1.5,
                                      showPercentSlide: true,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "${widget.sessionFile.timestamp![index].system!.battery} %",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    '| A |: ${CalculationService.mediumAcceleration(widget.sessionFile.timestamp![index].accelerometer).toStringAsFixed(2)} g'),
                                Wrap(
                                  spacing: 10,
                                  children: [
                                    Text(
                                      'Ax: ${(widget.sessionFile.timestamp![index].accelerometer?.aX ?? 0 / 16384.0).toStringAsFixed(2)} g',
                                    ),
                                    Text(
                                      'Ay: ${(widget.sessionFile.timestamp![index].accelerometer?.aY ?? 0 / 16384.0).toStringAsFixed(2)} g',
                                    ),
                                    Text(
                                      'Az: ${(widget.sessionFile.timestamp![index].accelerometer?.aZ ?? 0 / 16384.0).toStringAsFixed(2)} g',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            'Pitch: ${CalculationService.pitch(widget.sessionFile.timestamp![index].accelerometer)}°',
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            'Roll: ${CalculationService.roll(widget.sessionFile.timestamp![index].accelerometer)}°',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
