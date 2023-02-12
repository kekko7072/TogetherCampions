import 'app_director.dart';
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
      ),
      home: StreamProvider<CurrentUser?>.value(
          value: AuthService().user,
          initialData: CurrentUser(),
          catchError: (_, __) => null,
          child: const AppDirector()),
      builder: EasyLoading.init(),
    );
  }
}
