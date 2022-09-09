import 'package:app/interfaces/widgets/registration.dart';
import 'package:flutter/cupertino.dart';

import '../../services/imports.dart';
import 'loading_screen.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);
  static const routeName = 'Authenticate';

  @override
  AuthenticateState createState() => AuthenticateState();
}

class AuthenticateState extends State<Authenticate> {
  final _formKey = GlobalKey<FormState>();

  bool showLoading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController password = TextEditingController();

  bool showPassword = true;

  String email = '';

  @override
  Widget build(BuildContext context) {
    return showLoading
        ? const LoadingScreen()
        : Scaffold(
            backgroundColor: AppStyle.primaryColor,
            body: SafeArea(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 300,
                        width: 300,
                        child: Image(
                            image: AssetImage(
                          'assets/logo.png',
                        )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          'Stone App',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: AppStyle.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width < 500
                              ? MediaQuery.of(context).size.width
                              : 500,
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                  validator: (value) {
                                    String pattern = r'\w+@\w+\.\w+';
                                    RegExp regex = RegExp(pattern);
                                    if (value == null || value.isEmpty) {
                                      return 'Enter your email';
                                    } else {
                                      if (!regex
                                          .hasMatch(emailController.text)) {
                                        return 'Invalid Email Address format';
                                      }
                                      return null;
                                    }
                                  },
                                  onChanged: (val) {
                                    setState(() => email = val);
                                  },
                                  decoration: AppStyle().kTextFieldDecoration(
                                    icon: Icons.email,
                                    hintText: 'Enter Your email',
                                  )),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: password,
                                obscureText: showPassword,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                                decoration: AppStyle()
                                    .kTextFieldDecoration(
                                        icon: Icons.lock,
                                        hintText: 'Enter Your Password')
                                    .copyWith(
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showPassword = !showPassword;
                                          });
                                        },
                                        icon: Icon(
                                          !showPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: AppStyle.primaryColor,
                                        ),
                                      ),
                                    ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter your password';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                              CupertinoButton.filled(
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  setState(() => showLoading = true);
                                  await AuthService()
                                      .loginWithEmailAndPassword(
                                          email: email, password: password.text)
                                      .then((state) {
                                    setState(() => showLoading = false);
                                    if (state == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Not authenticated, please check email and password'),
                                        ),
                                      );
                                    }
                                  });
                                },
                                child: const Text('Accedi'),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => showModalBottomSheet(
                                    context: context,
                                    shape: AppStyle.kModalBottomStyle,
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    builder: (context) => const Registration(
                                          isEdit: false,
                                        )),
                                child: const Text(
                                  'Non hai un account? Crealo qui.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                    //color: Colors.black,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
