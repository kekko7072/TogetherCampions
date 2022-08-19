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
    Track(),
    Devices(),
  ];

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    return userData != null
        ? Scaffold(
            appBar: AppBar(
              title: Text(
                'Together Champions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              actions: [
                IconButton(
                    onPressed: () => showModalBottomSheet(
                          context: context,
                          shape: AppStyle.kModalBottomStyle,
                          isScrollControlled: true,
                          isDismissible: true,
                          builder: (context) => Dismissible(
                              key: UniqueKey(),
                              child: AddEditProfile(
                                userData: userData,
                              )),
                        ),
                    icon: const Icon(CupertinoIcons.person_alt_circle))
              ],
            ),
            body: MediaQuery.of(context).size.width >= 500
                ? Row(children: [
                    NavigationRail(
                      minWidth: 170,
                      selectedIndex: currentPage,
                      onDestinationSelected: (index) =>
                          setState(() => currentPage = index),
                      labelType: NavigationRailLabelType.all,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(CupertinoIcons.square_grid_2x2),
                          label: Text('Session'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(CupertinoIcons.app_badge),
                          label: Text('Track'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(CupertinoIcons.settings),
                          label: Text('Devices'),
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
                              label: 'Sessions'),
                          NavigationDestination(
                              icon: Icon(CupertinoIcons.app_badge),
                              label: 'Track'),
                          NavigationDestination(
                              icon: Icon(CupertinoIcons.settings),
                              label: 'Devices'),
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
