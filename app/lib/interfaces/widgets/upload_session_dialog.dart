import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class UploadSessionDialog extends StatefulWidget {
  const UploadSessionDialog({
    Key? key,
    required this.deviceID,
    required this.devicePosition,
    required this.system,
    required this.gpsPosition,
    required this.gpsNavigation,
    required this.accelerometer,
    required this.gyroscope,
  }) : super(key: key);
  final String deviceID;
  final DevicePosition devicePosition;
  final List<System> system;
  final List<GpsPosition> gpsPosition;
  final List<GpsNavigation> gpsNavigation;
  final List<Accelerometer> accelerometer;
  final List<Gyroscope> gyroscope;

  @override
  State<UploadSessionDialog> createState() => _UploadSessionDialogState();
}

class _UploadSessionDialogState extends State<UploadSessionDialog> {
  bool showUploading = false;
  int progress = 0;
  int totalProgress = 0;
  @override
  void initState() {
    super.initState();
    totalProgress = widget.system.length +
        widget.gpsPosition.length +
        widget.gpsNavigation.length +
        widget.accelerometer.length +
        widget.gyroscope.length;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text(
        'Session ended',
      ),
      content: Column(
        children: [
          if (showUploading) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: CircularProgressIndicator(),
                ),
                Text("Progress: $progress/$totalProgress"),
              ],
            )
          ] else ...[
            Text('System log: ${widget.system.length}'),
            Text('Gps position log: ${widget.gpsPosition.length}'),
            Text('Gps navigation log: ${widget.gpsPosition.length}'),
            Text('Accelerometer log: ${widget.accelerometer.length}'),
            Text('Gyroscope log: ${widget.gyroscope.length}'),
          ]
        ],
      ),
      actions: [
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () async {
            setState(() => showUploading = true);

            String sessionID = const Uuid().v4();
            debugPrint('\n\n\n\n\n\n\n\n\n\n\n\n');
            try {
              setState(() => showUploading = true);

              ///1. Add System
              List<Map> systemListJSON = [];
              for (System sys in widget.system) {
                //setState(() => ++progress);
                systemListJSON.add(sys.toJson());
              }

              ///2. Add Gps
              List<Map> gpsPositionListJSON = [];
              for (GpsPosition gps in widget.gpsPosition) {
                //setState(() => ++progress);
                gpsPositionListJSON.add(gps.toJson());
              }
              List<Map> gpsNavigationListJSON = [];
              for (GpsNavigation gps in widget.gpsNavigation) {
                //setState(() => ++progress);
                gpsNavigationListJSON.add(gps.toJson());
              }

              ///3. Add Mpu
              List<Map> accelerometerListJSON = [];
              for (Accelerometer mpu in widget.accelerometer) {
                //setState(() => ++progress);
                accelerometerListJSON.add(mpu.toJson());
              }
              List<Map> gyroscopeListJSON = [];
              for (Gyroscope mpu in widget.gyroscope) {
                //setState(() => ++progress);
                gyroscopeListJSON.add(mpu.toJson());
              }

              Map<String, dynamic> content = {
                "deviceID": widget.deviceID.toString(),
                "sessionID": sessionID,
                "info": {
                  "name": DateFormat.yMd()
                      .add_Hms()
                      .format(DateTime.now())
                      .toString(),
                  "start": DateTime.now()
                      .subtract(
                          Duration(milliseconds: widget.system.last.timestamp))
                      .toIso8601String(),
                  "end": DateTime.now().toIso8601String()
                },
                "devicePosition": {
                  "x": widget.devicePosition.x,
                  "y": widget.devicePosition.y,
                  "z": widget.devicePosition.z
                },
                "system": systemListJSON,
                "gps_position": gpsPositionListJSON,
                "gps_navigation": gpsNavigationListJSON,
                "accelerometer": accelerometerListJSON,
                "gyroscope": gyroscopeListJSON,
              };

              final Directory directory =
                  await getApplicationDocumentsDirectory();
              final File file = File('${directory.path}/$sessionID.json');
              await file.writeAsString(jsonEncode(content));
            } catch (e) {
              debugPrint(
                  "\n\n\n\n\n\n\n\n\n\n\n\nERRRORRR: $e\n\n\n\n\n\n\n\n\n\n\n\n");
            }

            setState(() => showUploading = false);

            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child: const Text('Save locally'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () async {
            setState(() => showUploading = true);

            String sessionID = const Uuid().v4();

            try {
              setState(() => showUploading = true);

              bool success = await DatabaseSession(deviceID: widget.deviceID)
                  .uploadFile(
                      sessionFile: SessionFile(
                          deviceId: widget.deviceID,
                          sessionId: sessionID,
                          info: SessionInfo(
                              name: DateFormat('dd/MM/yyyy')
                                  .add_Hms()
                                  .format(DateTime.now())
                                  .toString(),
                              start: DateTime.now().subtract(Duration(
                                  milliseconds: widget.system.last.timestamp)),
                              end: DateTime.now()),
                          devicePosition: widget.devicePosition,
                          system: widget.system,
                          gpsPosition: widget.gpsPosition,
                          gpsNavigation: widget.gpsNavigation,
                          accelerometer: widget.accelerometer,
                          gyroscope: widget.gyroscope));

              debugPrint("SUCCESS: $success");
            } catch (e) {
              debugPrint(
                  "\n\n\n\n\n\n\n\n\n\n\n\nERRRORRR: $e\n\n\n\n\n\n\n\n\n\n\n\n");
            }

            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child: const Text('Upload cloud'),
        )
      ],
    );
  }
}
