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
  late GoogleMapController controller;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};

  late Log start;
  late Log end;

  List<LatLng> segment = [];

  TelemetryViewLive telemetryViewRange = TelemetryViewLive.speed;
  TelemetryViewLive telemetryViewCharts = TelemetryViewLive.speed;

  @override
  void initState() {
    super.initState();
    start = widget.logs.first;
    end = widget.logs.last;

    for (Log log in widget.logs) {
      segment.add(log.gps.latLng);
    }
  }

  @override
  Widget build(BuildContext context) {
    Telemetry telemetry =
        CalculationService.telemetry(logs: widget.logs, segment: segment);
    return Stack(
      children: [
        GoogleMap(
          polylines: _polyline,
          markers: _markers,
          onMapCreated: _onMapCreated,
          zoomControlsEnabled: false,
          mapType: MapType.satellite,
          initialCameraPosition: CalculationService.initialCameraPosition(
              list: segment, isPreview: false),
        ),
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
                            Text('Medium: ${telemetry.speed.medium}'),
                            Text('Max: ${telemetry.speed.max}'),
                            Text('Min: ${telemetry.speed.min}'),
                          ],
                        ),
                      ),
                    ] else if (telemetryViewRange ==
                        TelemetryViewLive.altitude) ...[
                      SizedBox(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Medium: ${telemetry.altitude.medium}'),
                            Text('Max: ${telemetry.altitude.max}'),
                            Text('Min: ${telemetry.altitude.min}'),
                          ],
                        ),
                      ),
                    ] else if (telemetryViewRange ==
                        TelemetryViewLive.course) ...[
                      SizedBox(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Medium: ${telemetry.course.medium}'),
                            Text('Max: ${telemetry.course.max}'),
                            Text('Min: ${telemetry.course.min}'),
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
          snippet: CalculationService.formatDate(
              date: start.timestamp, year: true, seconds: true),
        ),
      ));
      _markers.add(Marker(
        markerId: const MarkerId('end'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        position: end.gps.latLng,
        infoWindow: InfoWindow(
          title: 'End',
          snippet: CalculationService.formatDate(
              date: end.timestamp, year: true, seconds: true),
        ),
      ));

      //ADD LINES
      _polyline.add(Polyline(
        polylineId: const PolylineId('line1'),
        visible: true,
        points: segment,
        width: 6,
        color: AppStyle.primaryColor,
        geodesic: true,
        jointType: JointType.round,
      ));

      /*
      _polyline.add(Polyline(
        polylineId: PolylineId('line2'),
        visible: true,
        points: segment1,
        width: 2,
        color: Colors.red,
      ));*/
    });
  }
}
