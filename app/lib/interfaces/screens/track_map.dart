import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

class TrackMap extends StatefulWidget {
  const TrackMap(
      {Key? key, required this.id, required this.session, required this.logs})
      : super(key: key);
  final String id;
  final Session session;
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

  Telemetry? telemetry;

  @override
  void initState() {
    super.initState();
    start = widget.logs.first;
    end = widget.logs.last;

    for (Log log in widget.logs) {
      segment.add(log.gps.latLng);
    }

    telemetry =
        CalculationService.telemetry(logs: widget.logs, segment: segment);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Stack(
        children: [
          GoogleMap(
            polylines: _polyline,
            markers: _markers,
            onMapCreated: _onMapCreated,
            mapType: MapType.satellite,
            initialCameraPosition: CalculationService.initialCameraPosition(
                list: segment, isPreview: false),
          ),
          if (telemetry != null) ...[
            SafeArea(
              child: CardTelemetry(
                id: widget.id,
                telemetry: telemetry!,
                session: widget.session,
              ),
            ),
            SafeArea(
              child: CardInfo(
                session: widget.session,
                battery: telemetry!.battery.consumption,
              ),
            ),
          ],
          SafeArea(
            child: Align(
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
          )
        ],
      ),
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
              date: start.timestamp, seconds: true),
        ),
      ));
      _markers.add(Marker(
        markerId: const MarkerId('end'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        position: end.gps.latLng,
        infoWindow: InfoWindow(
          title: 'End',
          snippet:
              CalculationService.formatDate(date: end.timestamp, seconds: true),
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
