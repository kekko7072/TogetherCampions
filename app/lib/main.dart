import 'package:flutter/cupertino.dart';
import 'services/imports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: AppStyle.primaryMaterialColor,
        primaryColor: AppStyle.primaryColor,
      ),
      home: StreamProvider<UserData?>.value(
          value: DatabaseUser().userData(uid: kDefaultUid),
          initialData: null,
          builder: (context, snapshot) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Tracker app'),
                actions: [
                  IconButton(
                      onPressed: () => showModalBottomSheet(
                            context: context,
                            shape: AppStyle.kModalBottomStyle,
                            isScrollControlled: true,
                            isDismissible: true,
                            builder: (context) => Dismissible(
                                key: UniqueKey(),
                                child: const AddEditProfile()),
                          ),
                      icon: const Icon(CupertinoIcons.person_alt_circle))
                ],
              ),
              body: const Home(),
            );
          }),
    );
  }
}
