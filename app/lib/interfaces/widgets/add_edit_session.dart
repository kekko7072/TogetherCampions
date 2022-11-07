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
  bool isLocal = true;

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

  int totalProgress = 0;

  bool showUploading = false;

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
                if (!isLocal) Text("Progress: $progress/${value.length}"),
              ],
            )
          ] else ...[
            Text(
              '${widget.isEdit ? 'Edit' : 'Upload'} session',
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
                  const SizedBox(height: 10),
                  if (!widget.isEdit) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilterChip(
                            backgroundColor: isLocal
                                ? AppStyle.primaryColor
                                : Colors.black12,
                            label: Text(
                              'LOCAL FILE',
                              style: TextStyle(
                                  fontWeight: isLocal
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Colors.white),
                            ),
                            onSelected: (value) =>
                                setState(() => isLocal = true)),
                        const SizedBox(width: 20),
                        FilterChip(
                            backgroundColor: !isLocal
                                ? AppStyle.primaryColor
                                : Colors.black12,
                            label: Text(
                              'SD CARD',
                              style: TextStyle(
                                  fontWeight: !isLocal
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Colors.white),
                            ),
                            onSelected: (value) =>
                                setState(() => isLocal = false)),
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
                  if (isLocal) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoButton(
                          onPressed: () async {
                            EasyLoading.show();

                            try {
                              result = await FilePicker.platform.pickFiles(
                                dialogTitle: 'Seleziona il file sessionId.json',
                                type: FileType.custom,
                                allowedExtensions: ["json"], //tkrlg
                              );

                              if (result != null) {
                                setState(() {
                                  file = result!.files.first;
                                  debugPrint(
                                      "PATH: ${file!.path}\nNAME: ${file!.name}\nEXTENSION: ${file!.extension}\nSIZE: ${file!.size}\nBYTES AVAILABLE: ${file!.bytes != null}");
                                });
                              } else {
                                debugPrint("User cancelled");
                              }
                            } catch (e) {
                              debugPrint(
                                  "\n\n\n\n\n\n\n\n\n\n\n\nERRRORRR: $e\n\n\n\n\n\n\n\n\n\n\n\n");
                            }
                            EasyLoading.dismiss();
                          },
                          child: const Text(
                            'Select file',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (file != null) ...[
                          const SizedBox(width: 20),
                          const Icon(
                            CupertinoIcons.check_mark_circled_solid,
                            color: CupertinoColors.activeGreen,
                            size: 30,
                          )
                        ]
                      ],
                    ),
                    const SizedBox(height: 10),
                    CupertinoButton.filled(
                      onPressed: file == null
                          ? null
                          : () async {
                              try {
                                EasyLoading.show();
                                var body = json.decode(String.fromCharCodes(
                                    await File(file!.path!).readAsBytes()));
                                var url = Uri.http(
                                    "together-champions.ew.r.appspot.com",
                                    '/upload');
                                var response = await post(url,
                                    headers: {
                                      "Content-Type": "application/json",
                                      // "Authorization": "Bearer iasUSnalspwoid@asw",
                                      "Access-Control-Allow-Origin": "*",
                                    },
                                    body: json.encode(json.decode(
                                        String.fromCharCodes(
                                            await File(file!.path!)
                                                .readAsBytes()))));
                                EasyLoading.dismiss();
                                debugPrint("RESPONSE: ${response.body}");
                                if (response.statusCode == 200) {
                                  EasyLoading.showSuccess(
                                      "Session uploaded to server!It will take some time processing...");
                                  Navigator.of(context).pop();
                                }
                              } catch (e) {
                                EasyLoading.showError("ERROR: $e");
                                print(e);
                              }
                            },
                      child: const Text(
                        'Upload',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ] else ...[
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
                    const SizedBox(height: 10),
                    CupertinoButton.filled(
                      onPressed: () async {
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
