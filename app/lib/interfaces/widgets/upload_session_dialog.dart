import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class UploadSessionDialog extends StatefulWidget {
  const UploadSessionDialog(
      {Key? key,
      required this.device,
      required this.devicePosition,
      required this.system,
      required this.gps,
      required this.mpu})
      : super(key: key);
  final BluetoothDevice device;
  final DevicePosition devicePosition;
  final List<System> system;
  final List<Gps> gps;
  final List<Mpu> mpu;

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
    totalProgress =
        widget.system.length + widget.gps.length + widget.mpu.length;
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
            Text('Gps log: ${widget.gps.length}'),
            Text('Mpu log: ${widget.mpu.length}'),
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

              ///0.Stop notifying
              await widget.device.disconnect();

              ///1. Create Session
              await DatabaseSession(deviceID: widget.device.id.id).add(
                  session: Session(
                      id: sessionID,
                      info: SessionInfo(
                          name: DateFormat.yMd()
                              .add_Hms()
                              .format(DateTime.now())
                              .toString(),
                          start: DateTime.now().subtract(Duration(
                              milliseconds: widget.system.last.timestamp)),
                          end: DateTime.now()),
                      devicePosition: widget.devicePosition));

              ///1. Add System
              List<Map> systemListJSON = [];
              for (System sys in widget.system) {
                setState(() => ++progress);
                print('\n\n${sys.toJson()}\n\n');
                //TODO CONVERT JSON TO CORRECT STRING
                systemListJSON.add(sys.toJson());
              }

              ///2. Add Gps
              List<Map> gpsListJSON = [];
              for (Gps gps in widget.gps) {
                setState(() => ++progress);
                print('\n\n${gps.toJson()}\n\n');
                //TODO CONVERT JSON TO CORRECT STRING
                gpsListJSON.add(gps.toJson());
              }

              ///3. Add Mpu
              List<Map> mpuListJSON = [];
              for (Mpu mpu in widget.mpu) {
                setState(() => ++progress);
                print('\n\n${mpu.toJson()}\n\n');
                //TODO CONVERT JSON TO CORRECT STRING
                gpsListJSON.add(mpu.toJson());
              }
              Map<String, dynamic> content = {};

              var content1 = {
                "deviceID": widget.device.id.toString(),
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
                "gps": gpsListJSON,
                "mpu": mpuListJSON,
              };
              content.addAll(content1);
              print(content);
              final Directory directory =
                  await getApplicationDocumentsDirectory();
              final File file = File('${directory.path}/$sessionID.json');
              await file.writeAsString(content.toString());
            } catch (e) {
              print(
                  "\n\n\n\n\n\n\n\n\n\n\n\nERRRORRR: $e\n\n\n\n\n\n\n\n\n\n\n\n");
            }

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
            debugPrint('\n\n\n\n\n\n\n\n\n\n\n\n');
            try {
              setState(() => showUploading = true);

              ///0.Stop notifying
              await widget.device.disconnect();

              ///1. Create Session
              await DatabaseSession(deviceID: widget.device.id.id).add(
                  session: Session(
                      id: sessionID,
                      info: SessionInfo(
                          name: DateFormat.yMd()
                              .add_Hms()
                              .format(DateTime.now())
                              .toString(),
                          start: DateTime.now().subtract(Duration(
                              milliseconds: widget.system.last.timestamp)),
                          end: DateTime.now()),
                      devicePosition: widget.devicePosition));

              ///1. Add System
              for (System sys in widget.system) {
                setState(() => ++progress);
                await DatabaseSystem(
                        deviceID: widget.device.id.toString(),
                        sessionID: sessionID)
                    .add(sys);
                print('\n\n${sys.toJson()}\n\n');
              }

              ///2. Add Gps
              for (Gps gps in widget.gps) {
                setState(() => ++progress);
                await DatabaseGps(
                        deviceID: widget.device.id.toString(),
                        sessionID: sessionID)
                    .add(gps);
                print('\n\n${gps.toJson()}\n\n');
              }

              ///3. Add Mpu
              for (Mpu mpu in widget.mpu) {
                setState(() => ++progress);
                await DatabaseMpu(
                        deviceID: widget.device.id.toString(),
                        sessionID: sessionID)
                    .add(mpu);
                print('\n\n${mpu.toJson()}\n\n');
              }
            } catch (e) {
              print(
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
