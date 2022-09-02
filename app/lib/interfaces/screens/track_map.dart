import 'package:app/services/imports.dart';

class TrackMap extends StatefulWidget {
  const TrackMap({Key? key, required this.id, required this.logs})
      : super(key: key);
  final String id;
  final List<Log> logs;

  @override
  State<TrackMap> createState() => TrackMapState();
}

class TrackMapState extends State<TrackMap> {
  late Log start;
  late Log end;
  List<MapLatLng> polylinePoints = [];
  TelemetryViewLive telemetryViewRange = TelemetryViewLive.speed;
  TelemetryViewLive telemetryViewCharts = TelemetryViewLive.speed;
  late MapTileLayerController _mapController;
  late MapZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    start = widget.logs.first;
    end = widget.logs.last;

    for (Log log in widget.logs) {
      polylinePoints.add(log.gps.latLng);
    }

    _mapController = MapTileLayerController();

    _zoomPanBehavior = CalculationService.initialCameraPosition(
        list: polylinePoints, isPreview: false);
  }

  @override
  Widget build(BuildContext context) {
    Telemetry telemetry = CalculationService.telemetry(
        logs: widget.logs, segment: polylinePoints);
    return Stack(
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
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              zoomPanBehavior: _zoomPanBehavior,
              controller: _mapController,
              initialMarkersCount: widget.logs.length,
              tooltipSettings: const MapTooltipSettings(
                color: Colors.white,
              ),
              markerTooltipBuilder: (BuildContext context, int index) {
                return ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                          left: 10.0, top: 5.0, bottom: 5.0),
                      width: 150,
                      color: Colors.white,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Altitude: ${widget.logs[index].gps.altitude.roundToDouble()}',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.black),
                                  ),
                                  Text(
                                    'Course: ${widget.logs[index].gps.course.roundToDouble()}°',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.black),
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
                        color: index == 0 || index == widget.logs.length - 1
                            ? Colors.blue
                            : AppStyle.primaryColor,
                        size: index == 0 || index == widget.logs.length - 1
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
        /*   GoogleMap(
          polylines: _polyline,
          markers: _markers,
          onMapCreated: _onMapCreated,
          zoomControlsEnabled: false,
          mapType: MapType.satellite,
          initialCameraPosition: CalculationService.initialCameraPosition(
              list: segment, isPreview: false),
        ),*/
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilterChip(
                            backgroundColor:
                                telemetryViewRange == TelemetryViewLive.speed
                                    ? AppStyle.primaryColor
                                    : Colors.black12,
                            label: Text(
                              'Speed',
                              style: TextStyle(
                                  fontWeight: telemetryViewRange ==
                                          TelemetryViewLive.speed
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                            onSelected: (value) => setState(() =>
                                telemetryViewRange = TelemetryViewLive.speed)),
                        FilterChip(
                            backgroundColor:
                                telemetryViewRange == TelemetryViewLive.altitude
                                    ? AppStyle.primaryColor
                                    : Colors.black12,
                            label: Text(
                              'Altitude',
                              style: TextStyle(
                                  fontWeight: telemetryViewRange ==
                                          TelemetryViewLive.altitude
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                            onSelected: (value) => setState(() =>
                                telemetryViewRange =
                                    TelemetryViewLive.altitude)),
                        FilterChip(
                            backgroundColor:
                                telemetryViewRange == TelemetryViewLive.course
                                    ? AppStyle.primaryColor
                                    : Colors.black12,
                            label: Text(
                              'Course',
                              style: TextStyle(
                                  fontWeight: telemetryViewRange ==
                                          TelemetryViewLive.course
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                            onSelected: (value) => setState(() =>
                                telemetryViewRange = TelemetryViewLive.course)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    if (telemetryViewRange == TelemetryViewLive.speed) ...[
                      SizedBox(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Medium: ${telemetry.speed.medium} km/h'),
                            Text('Max: ${telemetry.speed.max} km/h'),
                            Text('Min: ${telemetry.speed.min} km/h'),
                          ],
                        ),
                      ),
                    ] else if (telemetryViewRange ==
                        TelemetryViewLive.altitude) ...[
                      SizedBox(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Medium: ${telemetry.altitude.medium} m'),
                            Text('Max: ${telemetry.altitude.max} m'),
                            Text('Min: ${telemetry.altitude.min} m'),
                          ],
                        ),
                      ),
                    ] else if (telemetryViewRange ==
                        TelemetryViewLive.course) ...[
                      SizedBox(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Medium: ${telemetry.course.medium} deg'),
                            Text('Max: ${telemetry.course.max} deg'),
                            Text('Min: ${telemetry.course.min} deg'),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 10,
                      children: [
                        FilterChip(
                            backgroundColor:
                                telemetryViewCharts == TelemetryViewLive.speed
                                    ? AppStyle.primaryColor
                                    : Colors.black12,
                            label: Text(
                              'Speed',
                              style: TextStyle(
                                  fontWeight: telemetryViewCharts ==
                                          TelemetryViewLive.speed
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                            onSelected: (value) => setState(() =>
                                telemetryViewCharts = TelemetryViewLive.speed)),
                        FilterChip(
                            backgroundColor: telemetryViewCharts ==
                                    TelemetryViewLive.altitude
                                ? AppStyle.primaryColor
                                : Colors.black12,
                            label: Text(
                              'Altitude',
                              style: TextStyle(
                                  fontWeight: telemetryViewCharts ==
                                          TelemetryViewLive.altitude
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                            onSelected: (value) => setState(() =>
                                telemetryViewCharts =
                                    TelemetryViewLive.altitude)),
                        FilterChip(
                            backgroundColor:
                                telemetryViewCharts == TelemetryViewLive.course
                                    ? AppStyle.primaryColor
                                    : Colors.black12,
                            label: Text(
                              'Course',
                              style: TextStyle(
                                  fontWeight: telemetryViewCharts ==
                                          TelemetryViewLive.course
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                            onSelected: (value) => setState(() =>
                                telemetryViewCharts =
                                    TelemetryViewLive.course)),
                      ],
                    ),
                    if (telemetryViewCharts == TelemetryViewLive.speed) ...[
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 4,
                        width: MediaQuery.of(context).size.width,
                        //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

                        child: Chart(
                          data: widget.logs,
                          variables: {
                            'timestamp': Variable(
                              accessor: (Log log) => log.timestamp,
                              scale: TimeScale(
                                  formatter: (date) =>
                                      '${date.hour}:${date.minute < 10 ? '0${date.minute}' : date.minute}:${date.second < 10 ? '0${date.second}' : date.second}'),
                            ),
                            'speed': Variable(
                                accessor: (Log log) => log.gps.speed,
                                scale: LinearScale(
                                    title: 'Speed',
                                    formatter: (number) => '$number km/h')),
                          },
                          coord: RectCoord(),
                          elements: [LineElement()],
                          rebuild: true,
                          axes: [
                            Defaults.horizontalAxis,
                            Defaults.verticalAxis,
                          ],
                        ),
                      ),
                    ] else if (telemetryViewCharts ==
                        TelemetryViewLive.altitude) ...[
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 4,
                        width: MediaQuery.of(context).size.width,
                        //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

                        child: Chart(
                          data: widget.logs,
                          variables: {
                            'timestamp': Variable(
                              accessor: (Log log) => log.timestamp,
                              scale: TimeScale(
                                  formatter: (date) =>
                                      '${date.hour}:${date.minute < 10 ? '0${date.minute}' : date.minute}:${date.second < 10 ? '0${date.second}' : date.second}'),
                            ),
                            'altitude': Variable(
                                accessor: (Log log) => log.gps.altitude,
                                scale: LinearScale(
                                    title: 'Altitude',
                                    formatter: (number) => '$number m')),
                          },
                          coord: RectCoord(),
                          elements: [LineElement()],
                          rebuild: true,
                          axes: [
                            Defaults.horizontalAxis,
                            Defaults.verticalAxis,
                          ],
                        ),
                      ),
                    ] else if (telemetryViewCharts ==
                        TelemetryViewLive.course) ...[
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 4,
                        width: MediaQuery.of(context).size.width,
                        //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

                        child: Chart(
                          data: widget.logs,
                          variables: {
                            'timestamp': Variable(
                              accessor: (Log log) => log.timestamp,
                              scale: TimeScale(
                                  formatter: (date) => ''), //Show nothing
                            ),
                            'course': Variable(
                                accessor: (Log log) => log.gps.course,
                                scale: LinearScale(
                                    title: 'Course',
                                    formatter: (number) => '$number °')),
                          },
                          coord: PolarCoord(),
                          elements: [LineElement()],
                          rebuild: true,
                          axes: [
                            Defaults.horizontalAxis,
                            Defaults.verticalAxis,
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
