import 'package:flutter/cupertino.dart';

import '../../services/imports.dart';
import '../screens/loading_screen.dart';

class Registration extends StatefulWidget {
  final bool isEdit;
  final UserData? userData;
  const Registration({Key? key, required this.isEdit, this.userData})
      : super(key: key);

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();

  TextEditingController name = TextEditingController();
  TextEditingController surname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  bool showPassword = true;
  bool showConfirmPassword = true;

  bool showLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.userData != null) {
      //All mandatory
      name.text = widget.userData!.profile.name;
      surname.text = widget.userData!.profile.surname;

      email.text = widget.userData!.profile.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return showLoading
        ? const LoadingScreen()
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.isEdit ? 'Modifica' : 'Crea'} un account',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width < 500
                        ? MediaQuery.of(context).size.width
                        : 500,
                    child: Form(
                      key: _formKey,
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
                                  icon: Icons.person,
                                  hintText: 'Enter your name'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 20),
                            child: TextFormField(
                              controller: surname,
                              textAlign: TextAlign.center,
                              decoration: AppStyle().kTextFieldDecoration(
                                  icon: Icons.person,
                                  hintText: 'Enter your surname'),
                            ),
                          ),
                          if (!widget.isEdit) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 20),
                              child: TextFormField(
                                controller: email,
                                keyboardType: TextInputType.emailAddress,
                                textAlign: TextAlign.center,
                                decoration: AppStyle().kTextFieldDecoration(
                                    icon: Icons.email, hintText: 'Enter email'),
                                validator: (value) {
                                  String pattern = r'\w+@\w+\.\w+';
                                  RegExp regex = RegExp(pattern);
                                  if (value == null || value.isEmpty) {
                                    return 'Enter your email';
                                  } else {
                                    if (!regex.hasMatch(email.text)) {
                                      return 'Invalid Email Address format';
                                    }
                                    return null;
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 20),
                              child: TextFormField(
                                controller: password,
                                obscureText: showPassword,
                                textAlign: TextAlign.center,
                                decoration: AppStyle()
                                    .kTextFieldDecoration(
                                        icon: Icons.lock,
                                        hintText: 'Enter password')
                                    .copyWith(
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showPassword = !showPassword;
                                          });
                                        },
                                        icon: Icon(!showPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off),
                                      ),
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 20),
                              child: TextFormField(
                                controller: confirmPassword,
                                obscureText: showConfirmPassword,
                                textAlign: TextAlign.center,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirm your password';
                                  } else if (confirmPassword.text !=
                                      password.text) {
                                    return 'Password do not match';
                                  }
                                  return null;
                                },
                                decoration: AppStyle()
                                    .kTextFieldDecoration(
                                        icon: Icons.lock,
                                        hintText: 'Confirm password')
                                    .copyWith(
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showConfirmPassword =
                                                !showConfirmPassword;
                                          });
                                        },
                                        icon: Icon(!showConfirmPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off),
                                      ),
                                    ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          CupertinoButton.filled(
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              setState(() => showLoading = true);
                              if (widget.isEdit) {
                                await DatabaseUser.createEdit(
                                    isEdit: widget.isEdit,
                                    userData: UserData(
                                      uid: widget.userData!.uid,
                                      profile: Profile(
                                        name: name.text,
                                        surname: surname.text,
                                        email: email.text,
                                      ),
                                      devices: widget.userData!.devices,
                                    )).then((message) {
                                  setState(() => showLoading = false);

                                  Navigator.of(context).pop();
                                });
                              } else {
                                await _auth
                                    .registerWithEmailAndPassword(
                                  name: name.text,
                                  surname: surname.text,
                                  email: email.text,
                                  password: password.text,
                                )
                                    .then((message) {
                                  setState(() => showLoading = false);
                                  if (message == null) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        content: Text(_auth.error),
                                        actions: [
                                          TextButton(
                                            child: const Text('Chiudi'),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          )
                                        ],
                                      ),
                                    );
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                });
                              }
                            },
                            child: Text(widget.isEdit ? 'Modifica' : 'Crea'),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
