import 'package:flutter/cupertino.dart';
import 'package:app/services/imports.dart';

class AddSession extends StatefulWidget {
  const AddSession({
    Key? key,
    required this.userData,
    this.session,
  }) : super(key: key);
  final UserData userData;
  final Session? session;

  @override
  State<AddSession> createState() => _AddSessionState();
}

class _AddSessionState extends State<AddSession> {
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

  int totalProgress = 0;

  bool showUploading = false;

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
              'Upload session',
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
                  /*  Wrap(
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
                  const SizedBox(height: 20),*/
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

                                SessionFile sessionFile = SessionFile.fromJson(
                                    file!.path!,
                                    json.decode(String.fromCharCodes(
                                        await File(file!.path!)
                                            .readAsBytes())));
/*
                                bool success = await DatabaseSession(
                                        deviceID: sessionFile.deviceId)
                                    .uploadFile(sessionFile: sessionFile);

                                EasyLoading.dismiss();

                                if (success) {
                                  EasyLoading.showSuccess(
                                      "Session uploaded to server!");
                                  Navigator.of(context).pop();
                                }*/
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
                  ]
                ],
              ),
            )
          ],
        ],
      ),
    );
  }
/*
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
  }*/
}
