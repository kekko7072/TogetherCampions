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

  List<MapLatLng> segment = [];

  TelemetryViewLive telemetryViewRange = TelemetryViewLive.speed;
  TelemetryViewLive telemetryViewCharts = TelemetryViewLive.speed;

  ///
  late MapTileLayerController _mapController;

  late MapZoomPanBehavior _zoomPanBehavior;

  //late List<_WonderDetails> _worldWonders;

  late int _currentSelectedIndex;
  late int _previousSelectedIndex;
  late int _tappedMarkerIndex;

  late double _cardHeight;

  late bool _canUpdateFocalLatLng;
  late bool _canUpdateZoomLevel;
  late bool _isDesktop;

  @override
  void initState() {
    super.initState();
    start = widget.logs.first;
    end = widget.logs.last;

    for (Log log in widget.logs) {
      segment.add(log.gps.latLng);
    }

    ///
    _canUpdateFocalLatLng = true;
    _canUpdateZoomLevel = true;
    _mapController = MapTileLayerController();
    /* _worldWonders = <_WonderDetails>[];

    _worldWonders.add(const _WonderDetails(
        place: 'Chichen Itza',
        state: 'Yucatan',
        country: 'Mexico',
        latitude: 20.6843,
        longitude: -88.5678,
        description:
        "Mayan ruins on Mexico's Yucatan Peninsula. It was one of the largest Maya cities, thriving from around A.D. 600 to 1200.",
        imagePath: 'images/maps_chichen_itza.jpg',
        tooltipImagePath: 'images/maps-chichen-itza.jpg'));

    _worldWonders.add(const _WonderDetails(
        place: 'Machu Picchu',
        state: 'Cuzco',
        country: 'Peru',
        latitude: -13.1631,
        longitude: -72.5450,
        description:
        'An Inca citadel built in the mid-1400s. It was not widely known until the early twentieth century.',
        imagePath: 'images/maps_machu_pichu.jpg',
        tooltipImagePath: 'images/maps-machu-picchu.jpg'));

    _worldWonders.add(const _WonderDetails(
        place: 'Christ the Redeemer',
        state: 'Rio de Janeiro',
        country: 'Brazil',
        latitude: -22.9519,
        longitude: -43.2105,
        description:
        'An enormous statue of Jesus Christ with open arms, constructed between 1922 and 1931.',
        imagePath: 'images/maps_christ_redeemer.jpg',
        tooltipImagePath: 'images/maps-christ-the-redeemer.jpg'));

    _worldWonders.add(const _WonderDetails(
        place: 'Colosseum',
        state: 'Regio III Isis et Serapis',
        country: 'Rome',
        latitude: 41.8902,
        longitude: 12.4922,
        description:
        'Built between A.D. 70 and 80, it could accommodate 50,000 to 80,000 people in tiered seating. It is one of the most popular tourist attractions in Europe.',
        imagePath: 'images/maps_colosseum.jpg',
        tooltipImagePath: 'images/maps-colosseum.jpg'));

    _worldWonders.add(const _WonderDetails(
        place: 'Petra',
        state: "Ma'an Governorate",
        country: 'Jordan',
        latitude: 30.3285,
        longitude: 35.4444,
        description:
        'An ancient stone city located in southern Jordan. It became the capital city for the Nabataeans around the fourth century BC.',
        imagePath: 'images/maps_petra.jpg',
        tooltipImagePath: 'images/maps-petra.jpg'));

    _worldWonders.add(const _WonderDetails(
        place: 'Taj Mahal',
        state: 'Uttar Pradesh',
        country: 'India',
        latitude: 27.1751,
        longitude: 78.0421,
        description:
        'A white marble mausoleum in Agra, India. It was commissioned in A.D. 1632 by the Mughal emperor Shah Jahan to hold the remains of his favorite wife. It was completed in 1653.',
        imagePath: 'images/maps_taj_mahal.jpg',
        tooltipImagePath: 'images/maps-tajmahal.jpg'));

    _worldWonders.add(const _WonderDetails(
        place: 'Great Wall of China',
        state: 'Beijing',
        country: 'China',
        latitude: 40.4319,
        longitude: 116.5704,
        description:
        'A series of walls and fortifications built along the northern border of China to protect Chinese states from invaders. Counting all of its offshoots, its length is more than 13,000 miles.',
        imagePath: 'images/maps_great_wall_of_china.jpg',
        tooltipImagePath: 'images/maps-great-wall-of-china.png'));
*/
    _zoomPanBehavior = MapZoomPanBehavior(
      minZoomLevel: 3,
      maxZoomLevel: 10,
      focalLatLng: MapLatLng(40.4319, 116.5704),
      enableDoubleTapZooming: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    Telemetry telemetry =
        CalculationService.telemetry(logs: widget.logs, segment: segment);
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
              initialMarkersCount: 1,
              tooltipSettings: const MapTooltipSettings(
                color: Colors.transparent,
              ),
              markerTooltipBuilder: (BuildContext context, int index) {
                if (_isDesktop) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(
                                left: 10.0, top: 5.0, bottom: 5.0),
                            width: 150,
                            color: Colors.white,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    ' _worldWonders[index].place',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      '_worldWonders[index].state' +
                                          ', ' +
                                          '_worldWonders[index].country',
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.black),
                                    ),
                                  )
                                ]),
                          ),
                        ]),
                  );
                }

                return const SizedBox();
              },
              markerBuilder: (BuildContext context, int index) {
                final double markerSize =
                    _currentSelectedIndex == index ? 40 : 25;
                return MapMarker(
                  latitude: 40.4319,
                  longitude: 116.5704,
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      if (_currentSelectedIndex != index) {
                        _canUpdateFocalLatLng = false;
                        _tappedMarkerIndex = index;
                        /*_pageViewController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );*/
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: markerSize,
                      width: markerSize,
                      child: FittedBox(
                        child: Icon(Icons.location_on,
                            color: _currentSelectedIndex == index
                                ? Colors.blue
                                : Colors.red,
                            size: markerSize),
                      ),
                    ),
                  ),
                );
              },
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

  /*void _onMapCreated(GoogleMapController controllerParam) {
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
  }*/
}
