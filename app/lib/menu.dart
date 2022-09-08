import 'package:flutter/cupertino.dart';
import 'package:app/services/imports.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  int currentPage = 0;
  List<Widget> pages({required UserData userData}) => [
        Sessions(userData: userData),
        const Track(),
        const Devices(),
      ];
  String pageName(int index) {
    if (index == 0) {
      return 'Sessions';
    } else if (index == 1) {
      return 'Track';
    } else if (index == 2) {
      return 'Devices';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    return userData != null
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                pageName(currentPage),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppStyle.primaryColor,
                    fontSize: 30),
              ),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: GestureDetector(
                    onTap: () => showModalBottomSheet(
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
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: AppStyle.backgroundColor,
                      child: const CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage(
                          'assets/tracker_image.png',
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            body: MediaQuery.of(context).size.width >= 500
                ? Row(children: [
                    NavigationRail(
                      minWidth: 170,
                      selectedIndex: currentPage,
                      backgroundColor: AppStyle.backgroundColor,
                      onDestinationSelected: (index) =>
                          setState(() => currentPage = index),
                      labelType: NavigationRailLabelType.all,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(
                            CupertinoIcons.square_grid_2x2,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Session',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(
                            CupertinoIcons.app_badge,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Track',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(
                            CupertinoIcons.settings,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Devices',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const VerticalDivider(thickness: 0.5, width: 1),
                    Expanded(
                      child: IndexedStack(
                        index: currentPage,
                        children: pages(userData: userData),
                      ),
                    ),
                  ])
                : pages(userData: userData)[currentPage],
            bottomNavigationBar: MediaQuery.of(context).size.width >= 500
                ? const SizedBox()
                : NavigationBarTheme(
                    data: NavigationBarThemeData(
                        labelTextStyle: const MaterialStatePropertyAll(
                            TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        backgroundColor: AppStyle.backgroundColor),
                    child: NavigationBar(
                        selectedIndex: currentPage,
                        onDestinationSelected: (index) =>
                            setState(() => currentPage = index),
                        destinations: const [
                          NavigationDestination(
                              icon: Icon(
                                CupertinoIcons.square_grid_2x2,
                                color: Colors.white,
                              ),
                              label: 'Sessions'),
                          NavigationDestination(
                              icon: Icon(
                                CupertinoIcons.app_badge,
                                color: Colors.white,
                              ),
                              label: 'Track'),
                          NavigationDestination(
                              icon: Icon(
                                CupertinoIcons.settings,
                                color: Colors.white,
                              ),
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
