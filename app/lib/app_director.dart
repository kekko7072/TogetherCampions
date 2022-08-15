import 'interfaces/screens/authenticate.dart';
import 'menu.dart';
import 'services/imports.dart';

class AppDirector extends StatelessWidget {
  const AppDirector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CurrentUser?>(context);

    return user?.uid == null
        ? const Authenticate()
        : MultiProvider(
            providers: [
              StreamProvider<UserData?>.value(
                value: DatabaseUser().userData(uid: user!.uid!),
                initialData: null,
              ),
            ],
            child: const Menu(),
          );
  }
}
