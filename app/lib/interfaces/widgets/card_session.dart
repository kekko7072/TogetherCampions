import 'package:app/services/imports.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

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
  late GoogleMapController controller;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};

  late Log start;
  late Log end;

  List<LatLng> segment = [];

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
                child: GoogleMap(
                  polylines: _polyline,
                  markers: _markers,
                  onMapCreated: _onMapCreated,
                  scrollGesturesEnabled: false,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: false,
                  mapType: MapType.satellite,
                  initialCameraPosition:
                      CalculationService.initialCameraPosition(
                          list: segment, isPreview: true),
                ),
              ),
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
          snippet:
              'Started ${DateFormat('dd/MM/yyyy').format(start.timestamp)} at ${DateFormat('kk:mm').format(start.timestamp)}',
        ),
      ));
      _markers.add(Marker(
        markerId: const MarkerId('end'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        position: end.gps.latLng,
        infoWindow: InfoWindow(
          title: 'End',
          snippet:
              'Ended ${DateFormat('dd/MM/yyyy').format(end.timestamp)} at ${DateFormat('kk:mm').format(end.timestamp)}',
        ),
      ));

      //ADD LINES
      _polyline.add(Polyline(
        polylineId: const PolylineId('line'),
        visible: true,
        points: segment,
        width: 6,
        color: AppStyle.primaryColor,
        geodesic: true,
        jointType: JointType.round,
      ));
    });
  }
}
