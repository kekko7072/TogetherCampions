import 'package:flutter/cupertino.dart';
import 'package:app/services/imports.dart';

class EditSession extends StatefulWidget {
  const EditSession({
    Key? key,
    required this.deviceID,
    required this.session,
  }) : super(key: key);
  final String deviceID;
  final SessionInfo session;

  @override
  State<EditSession> createState() => _EditSessionState();
}

class _EditSessionState extends State<EditSession> {
  final formKey = GlobalKey<FormState>();

  TextEditingController name = TextEditingController(text: 'Nuova sessione');

  @override
  void initState() {
    super.initState();
    name.text = widget.session.name;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Edit  session',
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
                  child: TextFormField(
                    controller: name,
                    textAlign: TextAlign.center,
                    decoration: AppStyle().kTextFieldDecoration(
                        icon: Icons.label, hintText: 'Enter title'),
                  ),
                ),
                const SizedBox(height: 20),
                CupertinoButton.filled(
                  onPressed: () async {
                    try {
                      EasyLoading.show();

                      ///TODO USING JSON FILE EDIT
                      ///

                      EasyLoading.dismiss();
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
              ],
            ),
          )
        ],
      ),
    );
  }
}
