import 'package:flutter/cupertino.dart';
import 'package:app/services/imports.dart';

class AddSession extends StatefulWidget {
  const AddSession({
    Key? key,
    this.session,
  }) : super(key: key);
  final Session? session;

  @override
  State<AddSession> createState() => _AddSessionState();
}

class _AddSessionState extends State<AddSession> {
  bool fromCSVFile = true;

  final formKey = GlobalKey<FormState>();

  bool showLoading = false;
  bool isLocal = true;

  TextEditingController nameController =
      TextEditingController(text: 'Nuova sessione');

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
                  Wrap(
                    alignment: WrapAlignment.start,
                    direction: Axis.horizontal,
                    spacing: 5,
                    children: [
                      FilterChip(
                          backgroundColor: fromCSVFile
                              ? AppStyle.primaryColor
                              : Colors.black12,
                          label: Text(
                            'CSV File',
                            style: TextStyle(
                                fontWeight: fromCSVFile
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: Colors.white),
                          ),
                          onSelected: (value) =>
                              setState(() => fromCSVFile = true)),
                      FilterChip(
                          backgroundColor: !fromCSVFile
                              ? AppStyle.primaryColor
                              : Colors.black12,
                          label: Text(
                            'JSON File',
                            style: TextStyle(
                                fontWeight: !fromCSVFile
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: Colors.white),
                          ),
                          onSelected: (value) =>
                              setState(() => fromCSVFile = false)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (fromCSVFile) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 20),
                      child: TextFormField(
                        controller: nameController,
                        textAlign: TextAlign.center,
                        decoration: AppStyle().kTextFieldDecoration(
                            icon: Icons.edit, hintText: 'Enter device name'),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoButton(
                          onPressed: () async {
                            try {
                              result = await FilePicker.platform.pickFiles(
                                dialogTitle: 'Select file session TXT',
                                type: FileType.custom,
                                allowedExtensions: ["TXT", "txt"],
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
                                  "\n\nERROR ON EDITING UPLOAD SESSION: $e\n");
                            }
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

                                ///Convert file
                                String dataFromCSV = String.fromCharCodes(
                                    await File(file!.path!).readAsBytes());

                                List<String> dataList = dataFromCSV.split(",");

                                List<List<String>> data = [];

                                /// Scrive i dati nel file CSV
                                for (String line in dataList) {
                                  List<String> lineData = line.split(";");
                                  data.add(lineData);
                                  print(lineData);
                                }

                                /// Crea un dizionario per contenere tutti i dati del file CSV
                                List<Map<String, dynamic>> jsonTimestampList =
                                    [];
                                int lastTimestamp = 0;

                                /// Loop through each row of data
                                for (List<String> row in data) {
                                  if (row[0] == "SYSTEM") {
                                    jsonTimestampList.add({
                                      "system": {
                                        "timestamp":
                                            int.parse(row[1].toString()),
                                        "battery": int.parse(row[2].toString()),
                                        "temperature":
                                            (int.parse(row[3].toString()) /
                                                    340.00) +
                                                36.53
                                      }
                                    });
                                  } else if (row[0] == "GPS_POSITION") {
                                    jsonTimestampList.add({
                                      "gps_position": {
                                        "timestamp":
                                            int.parse(row[1].toString()),
                                        "available": row[2] == "true",
                                        "latitude":
                                            double.parse(row[3].toString()),
                                        "longitude":
                                            double.parse(row[4].toString()),
                                        "speed": double.parse(row[5].toString())
                                      }
                                    });
                                  } else if (row[0] == "GPS_NAVIGATION") {
                                    jsonTimestampList.add({
                                      "gps_navigation": {
                                        "timestamp":
                                            int.parse(row[1].toString()),
                                        "available": row[2] == "true",
                                        "altitude":
                                            double.parse(row[3].toString()),
                                        "course":
                                            double.parse(row[4].toString()),
                                        "variation":
                                            double.parse(row[5].toString())
                                      }
                                    });
                                  } else if (row[0] == "MPU_ACCELERATION") {
                                    jsonTimestampList.add({
                                      "accelerometer": {
                                        "timestamp":
                                            int.parse(row[1].toString()),
                                        "aX": int.parse(row[2].toString()),
                                        "aY": int.parse(row[3].toString()),
                                        "aZ": int.parse(row[4].toString())
                                      }
                                    });
                                  } else if (row[0] == "MPU_GYROSCOPE") {
                                    lastTimestamp =
                                        int.parse(row[1].toString());
                                    jsonTimestampList.add({
                                      "gyroscope": {
                                        "timestamp":
                                            int.parse(row[1].toString()),
                                        "gX": int.parse(row[2].toString()),
                                        "gY": int.parse(row[3].toString()),
                                        "gZ": int.parse(row[4].toString())
                                      }
                                    });
                                  }
                                }

                                /// Create session file
                                Map<String, dynamic> jsonFile = {
                                  "device_id": "device_id", //TODO ID DEVICE
                                  "session_id": const Uuid().v1(),
                                  "info": {
                                    "name": nameController.text,
                                    "start": DateTime.now().toIso8601String(),
                                    "end": DateTime.now()
                                        .add(Duration(
                                            milliseconds: lastTimestamp))
                                        .toIso8601String()
                                  },
                                  "device_position": {"x": 0, "y": 0, "z": 0},
                                  "timestamp": jsonTimestampList
                                };

                                ///Save file
                                final Directory directory =
                                    await getApplicationDocumentsDirectory();

                                final File localFile = File(
                                    '${directory.path}/${const Uuid().v1()}.json');
                                await localFile
                                    .writeAsString(jsonEncode(jsonFile));

                                EasyLoading.showSuccess("Session uploaded!")
                                    .then(
                                        (value) => Navigator.of(context).pop());
                              } catch (e) {
                                EasyLoading.showError("ERROR: $e");
                                debugPrint("ERROR: $e");
                              }
                            },
                      child: const Text(
                        'Upload',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoButton(
                          onPressed: () async {
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
                                  "\n\nERROR ON EDITING UPLOAD SESSION: $e\n");
                            }
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

                                final Directory directory =
                                    await getApplicationDocumentsDirectory();

                                final File localFile = File(
                                    '${directory.path}/${const Uuid().v1()}.json');
                                await localFile.writeAsString(
                                    String.fromCharCodes(
                                        await File(file!.path!).readAsBytes()));

                                EasyLoading.showSuccess("Session uploaded!")
                                    .then(
                                        (value) => Navigator.of(context).pop());
                              } catch (e) {
                                EasyLoading.showError("ERROR: $e");
                                debugPrint("ERROR: $e");
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
