import 'package:flutter/cupertino.dart';
import 'package:app/services/imports.dart';

class AddEditDevice extends StatefulWidget {
  const AddEditDevice({
    Key? key,
    required this.uid,
    required this.isEdit,
    this.device,
  }) : super(key: key);
  final String uid;
  final bool isEdit;
  final Device? device;

  @override
  State<AddEditDevice> createState() => _AddEditDeviceState();
}

class _AddEditDeviceState extends State<AddEditDevice> {
  final formKey = GlobalKey<FormState>();
  bool showLoading = false;

  TextEditingController id = TextEditingController();
  TextEditingController model = TextEditingController();
  TextEditingController name = TextEditingController();
  int clock = 6;
  int frequency = 10;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.device != null) {
      id.text = widget.device!.serialNumber;
      name.text = widget.device!.name;
      clock = widget.device!.clock;
      frequency = widget.device!.frequency;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${widget.isEdit ? 'Modifica' : 'Aggiungi'} dispositivo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (showLoading) ...[
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            )
          ] else ...[
            const SizedBox(height: 10),
            Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!widget.isEdit) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 20),
                      child: TextFormField(
                        controller: model,
                        textAlign: TextAlign.center,
                        decoration: AppStyle().kTextFieldDecoration(
                            icon: Icons.settings,
                            hintText: 'Enter device model number'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 20),
                      child: TextFormField(
                        controller: id,
                        textAlign: TextAlign.center,
                        decoration: AppStyle().kTextFieldDecoration(
                            icon: Icons.settings,
                            hintText: 'Enter device serial number'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 20),
                    child: TextFormField(
                      controller: name,
                      textAlign: TextAlign.center,
                      decoration: AppStyle().kTextFieldDecoration(
                          icon: Icons.person, hintText: 'Enter device name'),
                    ),
                  ),
                  if (!widget.isEdit) ...[
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CupertinoButton(
                            onPressed: clock == kClockMin
                                ? null
                                : () => setState(() => --clock),
                            child: const Icon(CupertinoIcons.minus_circle),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Clock: $clock',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: CupertinoButton(
                            onPressed: clock == kClockMax
                                ? null
                                : () => setState(() => ++clock),
                            child: const Icon(CupertinoIcons.add_circled),
                          ),
                        ),
                      ],
                    ),
                  ],
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: CupertinoButton(
                          onPressed: clock == kFrequencyMin
                              ? null
                              : () => setState(() => --frequency),
                          child: const Icon(CupertinoIcons.minus_circle),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Frequenza: $frequency',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: CupertinoButton(
                          onPressed: clock == kFrequencyMax
                              ? null
                              : () => setState(() => ++frequency),
                          child: const Icon(CupertinoIcons.add_circled),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Durata sincronizzazione dati:',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${clock * frequency} s',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  CupertinoButton.filled(
                    onPressed: () async {
                      setState(() => showLoading = true);

                      await DatabaseDevice()
                          .create(
                              isEdit: widget.isEdit,
                              device: Device(
                                  serialNumber: id.text,
                                  modelNumber: model.text,
                                  uid: widget.uid,
                                  name: name.text,
                                  clock: clock,
                                  frequency: frequency,
                                  software: Software(name: '', version: '')))
                          .then((value) {
                        setState(() => showLoading = false);
                        Navigator.of(context).pop();
                      });
                    },
                    child: Text(widget.isEdit ? 'Modifica' : 'Crea'),
                  ),
                  if (widget.isEdit) ...[
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'NOTA: Una volta salvate le modifiche via app riavvia il dispositivo per finalizzare le modifiche.',
                        textAlign: TextAlign.center,
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
}
