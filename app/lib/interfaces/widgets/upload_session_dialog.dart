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

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text(
        'Session ended',
      ),
      content: Column(
        children: [
          if (showUploading) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              child: CircularProgressIndicator(),
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
          child: const Text('Don\'t save'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('Save'),
          onPressed: () async {
            setState(() => showUploading = true);

            String sessionID = const Uuid().v4();

            try {
              setState(() => showUploading = true);
              List<Map<String, dynamic>> data = [];

              ///1. Add System
              if (widget.system.isNotEmpty) {
                for (System sys in widget.system) {
                  data.add({"system": sys.toJson()});
                }
              }

              ///2. Add Gps
              if (widget.gpsPosition.isNotEmpty) {
                for (GpsPosition gps in widget.gpsPosition) {
                  data.add({"gps_position": gps.toJson()});
                }
              }
              if (widget.gpsNavigation.isNotEmpty) {
                for (GpsNavigation gps in widget.gpsNavigation) {
                  data.add({"gps_navigation": gps.toJson()});
                }
              }

              ///3. Add Mpu
              if (widget.accelerometer.isNotEmpty) {
                for (Accelerometer mpu in widget.accelerometer) {
                  data.add({"accelerometer": mpu.toJson()});
                }
              }
              if (widget.gyroscope.isNotEmpty) {
                for (Gyroscope mpu in widget.gyroscope) {
                  data.add({"gyroscope": mpu.toJson()});
                }
              }

              Map<int, Map<String, dynamic>> groupedData = {};
              for (Map<String, dynamic> item in data) {
                int timestamp = item.values.first["timestamp"];

                if (groupedData.containsKey(timestamp)) {
                  groupedData[timestamp]?.addAll(item);
                } else {
                  groupedData[timestamp] = item;
                }
              }

              debugPrint("VALUES: ${groupedData.values.toList()}");

              Map<String, dynamic> content = {
                "device_id": widget.deviceID.toString(),
                "session_id": sessionID,
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
                "device_position": {
                  "x": widget.devicePosition.x,
                  "y": widget.devicePosition.y,
                  "z": widget.devicePosition.z
                },
                "timestamp": groupedData.values.toList(),
              };

              final Directory directory =
                  await getApplicationDocumentsDirectory();
              final File file = File('${directory.path}/$sessionID.json');
              await file.writeAsString(jsonEncode(content));
            } catch (e) {
              debugPrint(
                  "\n\n\n\n\n\n\n\n\n\n\n\nERROR: $e\n\n\n\n\n\n\n\n\n\n\n\n");
            }

            setState(() => showUploading = false);

            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
