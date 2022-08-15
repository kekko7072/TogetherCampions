import 'package:flutter/cupertino.dart';
import 'package:app/services/imports.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  int currentPage = 0;
  List<Widget> pages = const [
    Sessions(),
    Devices(),
  ];

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    return userData != null
        ? Scaffold(
            body: MediaQuery.of(context).size.width >= 500
                ? Row(children: [
                    NavigationRail(
                      minWidth: 170,
                      selectedIndex: currentPage,
                      onDestinationSelected: (index) =>
                          setState(() => currentPage = index),
                      leading: Text(
                        'Together Champions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      trailing: const Text('© 2022 Francesco Vezzani.'),
                      labelType: NavigationRailLabelType.all,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(CupertinoIcons.square_grid_2x2),
                          label: Text('Sessioni'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(CupertinoIcons.app_badge),
                          label: Text('Dispositivi'),
                        ),
                      ],
                    ),
                    const VerticalDivider(thickness: 0.5, width: 1),
                    Expanded(
                      child: IndexedStack(
                        index: currentPage,
                        children: pages,
                      ),
                    ),
                  ])
                : pages[currentPage],
            bottomNavigationBar: MediaQuery.of(context).size.width >= 500
                ? const SizedBox()
                : NavigationBarTheme(
                    data: const NavigationBarThemeData(),
                    child: NavigationBar(
                        selectedIndex: currentPage,
                        onDestinationSelected: (index) =>
                            setState(() => currentPage = index),
                        destinations: const [
                          NavigationDestination(
                              icon: Icon(CupertinoIcons.square_grid_2x2),
                              label: 'Sessioni'),
                          NavigationDestination(
                              icon: Icon(CupertinoIcons.app_badge),
                              label: 'Dispositivi'),
                        ]),
                  ),
          )
        : const Scaffold(
            body: Center(
              child: Text('No user data found'),
            ),
          );
  }
}
