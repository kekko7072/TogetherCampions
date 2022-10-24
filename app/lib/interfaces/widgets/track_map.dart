import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

class TrackMap extends StatefulWidget {
  const TrackMap({Key? key, required this.gpsPosition}) : super(key: key);
  final List<GpsPosition> gpsPosition;

  @override
  State<TrackMap> createState() => TrackMapState();
}

class TrackMapState extends State<TrackMap> {
  late GpsPosition start;
  late GpsPosition end;
  List<MapLatLng> polylinePoints = [];
  TelemetryViewLive telemetryViewRange = TelemetryViewLive.speed;
  TelemetryViewLive telemetryViewCharts = TelemetryViewLive.speed;
  late MapTileLayerController _mapController;
  late MapZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    start = widget.gpsPosition.first;
    end = widget.gpsPosition.last;

    for (GpsPosition log in widget.gpsPosition) {
      polylinePoints.add(log.latLng);
    }

    _mapController = MapTileLayerController();

    _zoomPanBehavior = MapService.initialCameraPosition(
        list: polylinePoints, isPreview: false);
  }

  @override
  Widget build(BuildContext context) {
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
                                      : 'Speed: ${widget.gpsPosition[index].speed.roundToDouble()} km/h',
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
        /*   GoogleMap(
          polylines: _polyline,
          markers: _markers,
          onMapCreated: _onMapCreated,
          zoomControlsEnabled: false,
          mapType: MapType.satellite,
          initialCameraPosition: CalculationService.initialCameraPosition(
              list: segment, isPreview: false),
        ),*/
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Medium: ${telemetry.speed.medium} m'),
                    Text('Max: ${telemetry.speed.max} m'),
                    Text('Min: ${telemetry.speed.min} m'),
                  ],
                ),
              ),
            ] else if (telemetryViewRange == TelemetryViewLive.distance) ...[
              SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Medium: ${telemetry.distance} m'),
                  ],
                ),
              ),
            ],
            CupertinoButton(
              child: const Icon(CupertinoIcons.chart_bar_square),
              onPressed: () => showCupertinoDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                        content: SafeArea(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Wrap(
                                      spacing: 10,
                                      children: [
                                        FilterChip(
                                            backgroundColor:
                                                telemetryViewCharts ==
                                                        TelemetryViewLive.speed
                                                    ? AppStyle.primaryColor
                                                    : Colors.black12,
                                            label: Text(
                                              'Speed',
                                              style: TextStyle(
                                                  fontWeight:
                                                      telemetryViewCharts ==
                                                              TelemetryViewLive
                                                                  .speed
                                                          ? FontWeight.bold
                                                          : FontWeight.normal),
                                            ),
                                            onSelected: (value) => setState(
                                                () => telemetryViewCharts =
                                                    TelemetryViewLive.speed)),
                                      ],
                                    ),
                                    if (telemetryViewCharts ==
                                        TelemetryViewLive.speed) ...[
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        //https://medium.com/analytics-vidhya/the-versatility-of-the-grammar-of-graphics-d1366760424d

                                        child: Chart(
                                          data: widget.gpsPosition,
                                          variables: {
                                            'timestamp': Variable(
                                              accessor: (GpsPosition log) =>
                                                  log.timestamp,
                                              scale: LinearScale(
                                                  formatter: (number) =>
                                                      CalculationService
                                                          .timestamp(
                                                              number.toInt())),
                                            ),
                                            'speed': Variable(
                                                accessor: (GpsPosition gps) =>
                                                    gps.speed,
                                                scale: LinearScale(
                                                    title: 'Speed',
                                                    formatter: (number) =>
                                                        '$number km/h')),
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
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
            )
          ],
        ),
      ],
    );
  }
}
