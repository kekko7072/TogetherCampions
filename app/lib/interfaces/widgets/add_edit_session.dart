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

  FilePickerResult? result;
  PlatformFile? file;
  List<String> value = [];
  int progress = 0;
  String deviceId = '';

  @override
  void initState() {
    super.initState();
    deviceId = widget.userData.devices.first;

    if (widget.isEdit && widget.session != null) {
      name.text = widget.session!.name;
      start = widget.session!.start;
      end = widget.session!.end;
      deviceId = widget.session!.deviceID;
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
                  for (String deviceID in widget.userData.devices) ...[
                    Wrap(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: FilterChip(
                              backgroundColor: deviceId == deviceID
                                  ? AppStyle.primaryColor
                                  : Colors.black12,
                              label: Text(
                                deviceID,
                                style: TextStyle(
                                    fontWeight: deviceId == deviceID
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Colors.white),
                              ),
                              onSelected: (value) =>
                                  setState(() => deviceId = deviceID)),
                        ),
                      ],
                    ),
                  ],
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
                          await DatabaseUser.sessionEdit(
                                  uid: widget.userData.uid,
                                  oldSession: widget.session!,
                                  newSession: Session(
                                      name: name.text,
                                      start: start,
                                      end: end,
                                      deviceID: deviceId))
                              .then((value) {
                            setState(() => showLoading = false);
                            Navigator.of(context).pop();
                          });
                        } else {
                          await DatabaseUser.sessionCreateRemove(
                                  isCreate: true,
                                  uid: widget.userData.uid,
                                  session: Session(
                                      name: name.text,
                                      start: start,
                                      end: end,
                                      deviceID: deviceId))
                              .then((value) {
                            setState(() => showLoading = false);
                            Navigator.of(context).pop();
                          });
                        }
                      },
                      child: Text(widget.isEdit ? 'Modifica' : 'Avvia'),
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
                              "NAME: ${file!.name}\nEXTENSION: ${file!.extension}\nSIZE: ${file!.size}\nBYTES AVAILABLE: ${file!.bytes != null}");
                          if (file!.bytes != null) {
                            String convertedValue =
                                String.fromCharCodes(file!.bytes!);
                            setState(() => value = convertedValue.split(","));
                            debugPrint("LOGS: ${value.length}");
                          }
                          EasyLoading.dismiss();
                        } else {
                          debugPrint("User cancelled");
                        }
                      },
                      child: const Text('Carica file'),
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
                              {'serialNumber': deviceId});
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

                        await DatabaseUser.sessionCreateRemove(
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
                                    deviceID: deviceId))
                            .then((value) {
                          setState(() => showLoading = false);
                          Navigator.of(context).pop();
                        });
                      },
                      child: Text(
                        widget.isEdit ? 'Modifica' : 'Avvia',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
