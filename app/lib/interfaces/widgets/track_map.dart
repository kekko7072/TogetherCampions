import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

class TrackMap extends StatefulWidget {
  const TrackMap(
      {Key? key, required this.unitsSystem, required this.gpsPosition})
      : super(key: key);
  final UnitsSystem unitsSystem;
  final List<GpsPosition> gpsPosition;

  @override
  State<TrackMap> createState() => TrackMapState();
}

class TrackMapState extends State<TrackMap> {
  List<MapLatLng> polylinePoints = [];
  TelemetryViewLive telemetryViewRange = TelemetryViewLive.speed;
  bool showSpeedChart = false;
  late MapTileLayerController _mapController;
  late MapZoomPanBehavior _zoomPanBehavior;
  late Timer movePosition;

  @override
  void initState() {
    _mapController = MapTileLayerController();
    _zoomPanBehavior = MapZoomPanBehavior(
      zoomLevel: 12,
      minZoomLevel: 1,
      maxZoomLevel: 30,
      enableMouseWheelZooming: true,
      enableDoubleTapZooming: true,
      focalLatLng: widget.gpsPosition.last.latLng,
      showToolbar: true,
      toolbarSettings: const MapToolbarSettings(
          direction: Axis.horizontal,
          position: MapToolbarPosition.topRight,
          iconColor: Colors.black),
    );
    movePosition = Timer.periodic(const Duration(seconds: 3), (timer) {
      _zoomPanBehavior
        ..focalLatLng = widget.gpsPosition.last.latLng
        ..zoomLevel = 18;
    });
    super.initState();
  }

  void updateLines() {
    polylinePoints.add(widget.gpsPosition.last.latLng);
  }

  Timer timer() =>
      movePosition = Timer.periodic(const Duration(seconds: 5), (timer) {
        _zoomPanBehavior
          ..focalLatLng = widget.gpsPosition.last.latLng
          ..zoomLevel = 17;
      });

  @override
  void dispose() {
    movePosition.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    updateLines();
    TelemetryPosition telemetry = CalculationService.telemetryPosition(
        gpsPosition: widget.gpsPosition, segment: polylinePoints);

    return Column(
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
              initialFocalLatLng: widget.gpsPosition.last.latLng,
              initialMarkersCount: widget.gpsPosition.length,
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
                                  : index == widget.gpsPosition.length - 1
                                      ? 'End'
                                      : 'Speed: ${UnitsService.speedUnitsConvertFromKTS(widget.unitsSystem.speedUnits, widget.gpsPosition[index].speed).roundToDouble()} ${UnitsService.speedUnitsToString(widget.unitsSystem.speedUnits)}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ]),
                    ),
                  ]),
                );
              },
              markerBuilder: (BuildContext context, int index) {
                return MapMarker(
                  latitude: widget.gpsPosition[index].latLng.latitude,
                  longitude: widget.gpsPosition[index].latLng.longitude,
                  alignment: Alignment.bottomCenter,
                  child: FittedBox(
                    child: Icon(Icons.location_on,
                        color:
                            index == 0 || index == widget.gpsPosition.length - 1
                                ? Colors.blue
                                : AppStyle.primaryColor,
                        size:
                            index == 0 || index == widget.gpsPosition.length - 1
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
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterChip(
                    backgroundColor:
                        telemetryViewRange == TelemetryViewLive.speed
                            ? AppStyle.primaryColor
                            : Colors.black12,
                    label: Text(
                      'Speed',
                      style: TextStyle(
                          fontWeight:
                              telemetryViewRange == TelemetryViewLive.speed
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          color: telemetryViewRange == TelemetryViewLive.speed
                              ? Colors.white
                              : Colors.black),
                    ),
                    onSelected: (value) => setState(
                        () => telemetryViewRange = TelemetryViewLive.speed)),
                FilterChip(
                    backgroundColor:
                        telemetryViewRange == TelemetryViewLive.distance
                            ? AppStyle.primaryColor
                            : Colors.black12,
                    label: Text(
                      'Distance',
                      style: TextStyle(
                          fontWeight:
                              telemetryViewRange == TelemetryViewLive.distance
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          color:
                              telemetryViewRange == TelemetryViewLive.distance
                                  ? Colors.white
                                  : Colors.black),
                    ),
                    onSelected: (value) => setState(
                        () => telemetryViewRange = TelemetryViewLive.distance)),
              ],
            ),
            if (telemetryViewRange == TelemetryViewLive.speed) ...[
              if (showSpeedChart) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 4,
                    width: MediaQuery.of(context).size.width,
                    //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

                    child: Chart(
                      data: widget.gpsPosition,
                      variables: {
                        'timestamp': Variable(
                          accessor: (GpsPosition gps) => gps.timestamp,
                          scale: LinearScale(
                              formatter: (number) =>
                                  CalculationService.timestamp(number.toInt())),
                        ),
                        'speed': Variable(
                            accessor: (GpsPosition gps) => gps.speed,
                            scale: LinearScale(
                                title: 'Speed',
                                formatter: (number) =>
                                    '${UnitsService.speedUnitsConvertFromKTS(widget.unitsSystem.speedUnits, double.parse('$number')).roundToDouble()} ${UnitsService.speedUnitsToString(widget.unitsSystem.speedUnits)}')),
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
                ),
              ] else ...[
                SizedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Medium: ${UnitsService.speedUnitsConvertFromKTS(widget.unitsSystem.speedUnits, telemetry.speed.medium).roundToDouble()} ${UnitsService.speedUnitsToString(widget.unitsSystem.speedUnits)}'),
                      Text(
                          'Max: ${UnitsService.speedUnitsConvertFromKTS(widget.unitsSystem.speedUnits, telemetry.speed.max).roundToDouble()} ${UnitsService.speedUnitsToString(widget.unitsSystem.speedUnits)}'),
                      Text(
                          'Min: ${UnitsService.speedUnitsConvertFromKTS(widget.unitsSystem.speedUnits, telemetry.speed.min).roundToDouble()} ${UnitsService.speedUnitsToString(widget.unitsSystem.speedUnits)}'),
                    ],
                  ),
                ),
              ],
              CupertinoButton(
                  child: Icon(
                    showSpeedChart
                        ? CupertinoIcons.chart_bar_square_fill
                        : CupertinoIcons.chart_bar_square,
                    size: 40,
                  ),
                  onPressed: () => setState(() {
                        showSpeedChart = !showSpeedChart;
                      }))
            ] else if (telemetryViewRange == TelemetryViewLive.distance) ...[
              SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        'Total: ${UnitsService.distanceUnitsConvertFromMETER(widget.unitsSystem.distanceUnits, telemetry.distance)} ${UnitsService.distanceUnitsToString(widget.unitsSystem.distanceUnits)}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
