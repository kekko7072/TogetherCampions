import 'package:flutter/cupertino.dart';
import 'package:app/services/imports.dart';

class AddEditSession extends StatefulWidget {
  const AddEditSession({
    Key? key,
    required this.uid,
    required this.isEdit,
    this.session,
  }) : super(key: key);
  final String uid;
  final bool isEdit;
  final Session? session;

  @override
  State<AddEditSession> createState() => _AddEditSessionState();
}

class _AddEditSessionState extends State<AddEditSession> {
  final formKey = GlobalKey<FormState>();
  bool showLoading = false;

  TextEditingController name = TextEditingController();

  DateTime start = DateTime.now();
  DateTime end = DateTime.now();

  int durationInMinutes = 1;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.session != null) {
      name.text = widget.session!.name;
      start = widget.session!.start;
      end = widget.session!.end;
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
            '${widget.isEdit ? 'Modifica' : 'Avvia'} sessione',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (showLoading) ...[
            const CircularProgressIndicator()
          ] else ...[
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
                          icon: Icons.person, hintText: 'Enter title'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.isEdit) ...[
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
                  ] else ...[
                    const Text(
                      'Inserisci una durata approssimativa',
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CupertinoButton(
                            child: const Icon(CupertinoIcons.minus_circle),
                            onPressed: () =>
                                setState(() => --durationInMinutes),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Minuti: $durationInMinutes',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: CupertinoButton(
                            child: const Icon(CupertinoIcons.add_circled),
                            onPressed: () =>
                                setState(() => ++durationInMinutes),
                          ),
                        ),
                      ],
                    ),
                  ],
                  CupertinoButton.filled(
                    onPressed: () async {
                      setState(() => showLoading = true);
                      if (widget.isEdit) {
                        await DatabaseUser()
                            .sessionEdit(
                                uid: widget.uid,
                                oldSession: widget.session!,
                                newSession: Session(
                                    name: name.text, start: start, end: end))
                            .then((value) {
                          setState(() => showLoading = false);
                          Navigator.of(context).pop();
                        });
                      } else {
                        await DatabaseUser()
                            .sessionCreateRemove(
                                isCreate: true,
                                uid: widget.uid,
                                session: Session(
                                    name: name.text, start: start, end: end))
                            .then((value) {
                          setState(() => showLoading = false);
                          Navigator.of(context).pop();
                        });
                      }
                    },
                    child: Text(widget.isEdit ? 'Modifica' : 'Avvia'),
                  ),
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
