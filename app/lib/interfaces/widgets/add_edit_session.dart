import 'package:flutter/cupertino.dart';
import 'package:app/services/imports.dart';

class AddEditSession extends StatefulWidget {
  const AddEditSession({
    Key? key,
    required this.userData,
    required this.isEdit,
    this.session,
  }) : super(key: key);
  final UserData userData;
  final bool isEdit;
  final Session? session;

  @override
  State<AddEditSession> createState() => _AddEditSessionState();
}

class _AddEditSessionState extends State<AddEditSession> {
  final formKey = GlobalKey<FormState>();

  bool showLoading = false;
  bool isOnline = true;

  TextEditingController name = TextEditingController(text: 'Nuova sessione');

  DateTime start = DateTime.now();
  DateTime end = DateTime.now();

  int x = 0;
  int y = 0;
  int z = 0;
  FilePickerResult? result;
  PlatformFile? file;
  List<String> value = [];
  int progress = 0;
  String deviceID = '';

  @override
  void initState() {
    super.initState();
    deviceID = widget.userData.devices.first;

    if (widget.isEdit && widget.session != null) {
      name.text = widget.session!.info.name;
      start = widget.session!.info.start;
      end = widget.session!.info.end;
      x = widget.session!.devicePosition.x;
      y = widget.session!.devicePosition.y;
      z = widget.session!.devicePosition.z;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLoading) ...[
            Text(
              'Caricamento dati',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: CircularProgressIndicator(),
                ),
                if (!isOnline) Text("Progress: $progress/${value.length}"),
              ],
            )
          ] else ...[
            Text(
              '${widget.isEdit ? 'Modifica' : 'Avvia'} sessione',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 20),
                    child: TextFormField(
                      controller: name,
                      textAlign: TextAlign.center,
                      decoration: AppStyle().kTextFieldDecoration(
                          icon: Icons.label, hintText: 'Enter title'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (!widget.isEdit) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilterChip(
                            backgroundColor: isOnline
                                ? AppStyle.primaryColor
                                : Colors.black12,
                            label: Text(
                              'CLOUD',
                              style: TextStyle(
                                  fontWeight: isOnline
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Colors.white),
                            ),
                            onSelected: (value) =>
                                setState(() => isOnline = true)),
                        const SizedBox(width: 20),
                        FilterChip(
                            backgroundColor: !isOnline
                                ? AppStyle.primaryColor
                                : Colors.black12,
                            label: Text(
                              'SD CARD',
                              style: TextStyle(
                                  fontWeight: !isOnline
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Colors.white),
                            ),
                            onSelected: (value) =>
                                setState(() => isOnline = false)),
                      ],
                    ),
                  ],
                  Wrap(
                    alignment: WrapAlignment.start,
                    direction: Axis.horizontal,
                    spacing: 5,
                    children: [
                      for (String deviceID in widget.userData.devices) ...[
                        FilterChip(
                            backgroundColor: deviceID == deviceID
                                ? AppStyle.primaryColor
                                : Colors.black12,
                            label: StreamBuilder<Device>(
                                stream: DatabaseDevice().device(id: deviceID),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data?.name ?? '',
                                    style: TextStyle(
                                        fontWeight: deviceID == deviceID
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Colors.white),
                                  );
                                }),
                            onSelected: (value) =>
                                setState(() => deviceID = deviceID)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Posizione: ',
                  ),
                  PositionDeviceConfigurator(
                    onChangePosition: (newX, newY, newZ) => setState(() {
                      x = newX;
                      y = newY;
                      z = newZ;
                    }),
                    initialPosition:
                        widget.isEdit ? DevicePosition(x: x, y: y, z: z) : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Inizio sessione: ',
                        ),
                        CupertinoButton(
                          child: Text(
                              '${start.hour}:${start.minute}   ${start.day}/${start.month}/${start.year}'),
                          onPressed: () async {
                            DateTime value = await _selectDateTime(
                                context: context, input: start);
                            setState(() {
                              start = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (isOnline) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Fine sessione: ',
                          ),
                          CupertinoButton(
                            child: Text(
                                '${end.hour}:${end.minute}   ${end.day}/${end.month}/${end.year}'),
                            onPressed: () async {
                              DateTime value = await _selectDateTime(
                                  context: context, input: end);
                              setState(() {
                                end = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton.filled(
                      onPressed: () async {
                        setState(() => showLoading = true);
                        if (widget.isEdit) {
                          await DatabaseSession(deviceID: deviceID)
                              .edit(
                                  session: Session(
                                      id: const Uuid().v4(),
                                      info: SessionInfo(
                                          name: name.text,
                                          start: start,
                                          end: end),
                                      devicePosition: DevicePosition(
                                        x: x,
                                        y: y,
                                        z: z,
                                      )))
                              .then((value) {
                            setState(() => showLoading = false);
                            Navigator.of(context).pop();
                          });
                        } else {
                          await DatabaseSession(deviceID: deviceID)
                              .add(
                                  session: Session(
                                      id: const Uuid().v4(),
                                      info: SessionInfo(
                                          name: name.text,
                                          start: start,
                                          end: end),
                                      devicePosition: DevicePosition(
                                        x: x,
                                        y: y,
                                        z: z,
                                      )))
                              .then((value) {
                            setState(() => showLoading = false);
                            Navigator.of(context).pop();
                          });
                        }
                      },
                      child: Text(
                        widget.isEdit ? 'Modifica' : 'Avvia',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 10),
                    CupertinoButton.filled(
                      onPressed: () async {
                        //TODO macos not working permission requied
                        result = await FilePicker.platform.pickFiles(
                          dialogTitle:
                              'Seleziona il file datalog.txt dalla sd card',
                          type: FileType.custom,
                          allowedExtensions: ["txt"], //tkrlg
                        );

                        if (result != null) {
                          EasyLoading.show();
                          file = result!.files.first;
                          debugPrint(
                              "PATH: ${file!.path}\nNAME: ${file!.name}\nEXTENSION: ${file!.extension}\nSIZE: ${file!.size}\nBYTES AVAILABLE: ${file!.bytes != null}");
                          if (file!.bytes != null) {
                            String convertedValue =
                                String.fromCharCodes(file!.bytes!);
                            setState(() => value = convertedValue.split(","));
                          } else {
                            String convertedValue = String.fromCharCodes(
                                await File(file!.path!).readAsBytes());
                            setState(() => value = convertedValue.split(","));
                          }

                          debugPrint("LOGS: ${value.length}");
                          EasyLoading.dismiss();
                        } else {
                          debugPrint("User cancelled");
                        }
                      },
                      child: const Text('Select file'),
                    ),
                    const SizedBox(height: 10),
                    Text('N° Log: ${value.length}'),
                    const SizedBox(height: 10),
                    CupertinoButton.filled(
                      onPressed: () async {
                        setState(() => showLoading = true);

                        for (progress = 0;
                            progress < value.length;
                            progress++) {
                          String body =
                              CalculationService.formatOutputWithNewTimestamp(
                                  input: value[progress], start: start);
                          Uri url = Uri.https(kServerAddress, 'post',
                              {'serialNumber': deviceID});
                          var response = await post(
                            url,
                            headers: {
                              "Content-Type":
                                  "application/x-www-form-urlencoded"
                            }, //CLOCK AND FREQUENCY ARE NOW SAVED DIRECTLY ON SD CARD, before clock=6&frequency=10
                            body: body,
                          );
                          debugPrint(
                              'RESPONSE\nStatus: ${response.statusCode}\nBody: ${response.body}');
                          if (response.statusCode == 200) {
                            //OK GO ON
                            setState(() => ++progress);
                          } else {
                            //RETRY WITH SAME LOG
                            setState(() => --progress);
                          }
                        }

                        //TODO DECIDE HOW FORMAT DATA FROM SD CARD AND UPLOAD SESSION AND OOTHER TELEMETRY ETCC..
                        /* await DatabaseUser.sessionCreateRemove(
                                isCreate: true,
                                uid: widget.userData.uid,
                                session: Session(
                                    name: name.text,
                                    start: start,
                                    end: CalculationService.getLastNewTimestamp(
                                        lastInput: value
                                            .where((element) =>
                                                element.contains("timestamp="))
                                            .last,
                                        start: start),
                                    deviceID: deviceID))
                            .then((value) {
                          setState(() => showLoading = false);
                          Navigator.of(context).pop();
                        });*/
                      },
                      child: Text(
                        widget.isEdit ? 'Modifica' : 'Carica',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]
                ],
              ),
            )
          ],
        ],
      ),
    );
  }

  Future<DateTime> _selectDate(
      {required BuildContext context, required DateTime placeholder}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: placeholder,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != placeholder) {
      setState(() {
        placeholder = selected;
      });
    }
    return placeholder;
  }

  Future<TimeOfDay> _selectTime(
      {required BuildContext context, required TimeOfDay placeholder}) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: placeholder,
    );
    if (selected != null && selected != placeholder) {
      setState(() {
        placeholder = selected;
      });
    }
    return placeholder;
  }

  Future<DateTime> _selectDateTime(
      {required BuildContext context, required DateTime input}) async {
    final date = await _selectDate(context: context, placeholder: input);

    final time = await _selectTime(
        context: context,
        placeholder: TimeOfDay(hour: input.hour, minute: input.minute));
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}
