import 'package:flutter/cupertino.dart';
import 'package:app/services/imports.dart';
import 'package:badges/badges.dart' as badge;

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
  void initState() {
    super.initState();
    FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 4));
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    return FutureProvider<UnitsSystem>.value(
        value: UnitsSystem.loadFromSettings(),
        initialData: UnitsSystem(
            speedUnits: SpeedUnits.kmH,
            distanceUnits: DistanceUnits.km,
            temperatureUnits: TemperatureUnits.C),
        builder: (context, snapshot) {
          return userData != null
              ? FutureBuilder<LocationPermission>(
                  future: Geolocator.checkPermission(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const LoadingScreen();
                    }
                    LocationPermission? locationPermission = snapshot.data;
                    if (locationPermission == LocationPermission.denied ||
                        locationPermission ==
                            LocationPermission.deniedForever) {
                      return GeolocationPermission(
                        onChange: (permission) =>
                            setState(() => locationPermission = permission),
                      );
                    }

                    return StreamBuilder<List<ScanResult>>(
                        stream: FlutterBluePlus.instance.scanResults,
                        initialData: const [],
                        builder: (c, snapshot) => Scaffold(
                              backgroundColor: Colors.white,
                              appBar: AppBar(
                                title: Text(
                                  pageName(currentPage),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: MediaQuery.of(context)
                                                      .size
                                                      .width >=
                                                  500
                                              ? Colors.white
                                              : AppStyle.primaryColor,
                                          fontSize: 30),
                                ),
                                backgroundColor:
                                    MediaQuery.of(context).size.width >= 500
                                        ? AppStyle.backgroundColor
                                        : Colors.white,
                                surfaceTintColor: Colors.white,
                                actions: [
                                  GestureDetector(
                                    onTap: () => showModalBottomSheet(
                                      context: context,
                                      shape: AppStyle.kModalBottomStyle,
                                      isScrollControlled: true,
                                      isDismissible: true,
                                      builder: (context) => Dismissible(
                                          key: UniqueKey(),
                                          child: ProfilePage(
                                            userData: userData,
                                          )),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: CircleAvatar(
                                        radius: 25,
                                        backgroundColor:
                                            MediaQuery.of(context).size.width >=
                                                    500
                                                ? AppStyle.primaryColor
                                                : AppStyle.backgroundColor,
                                        child: const CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.amber,
                                          /* backgroundImage: Image.network(
                                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQcKtNs7ZY5ryppExfbYwxOe-iB1BURlKwkbLWmmec&s',
                                      fit: BoxFit.cover,
                                    ).image,*/
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                              body: MediaQuery.of(context).size.width >= 500
                                  ? Row(children: [
                                      NavigationRail(
                                        minWidth: 170,
                                        selectedIndex: currentPage,
                                        backgroundColor:
                                            AppStyle.backgroundColor,
                                        onDestinationSelected: (index) =>
                                            setState(() => currentPage = index),
                                        labelType: NavigationRailLabelType.all,
                                        destinations: [
                                          const NavigationRailDestination(
                                            icon: Icon(
                                              CupertinoIcons.square_grid_2x2,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              'Sessions',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          NavigationRailDestination(
                                            icon: badge.Badge(
                                              badgeContent: Text(
                                                '${snapshot.data!.where((element) => element.device.name == kDeviceModelTKR1A1).length}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              badgeStyle: badge.BadgeStyle(
                                                shape: badge.BadgeShape.circle,
                                                //toAnimate: false,
                                                badgeColor: currentPage == 1
                                                    ? AppStyle.backgroundColor
                                                    : AppStyle.primaryColor,
                                              ),
                                              position:
                                                  badge.BadgePosition.topEnd(),
                                              showBadge: snapshot.data!
                                                  .where((element) =>
                                                      element.device.name ==
                                                      kDeviceModelTKR1A1)
                                                  .isNotEmpty,
                                              child: const Icon(
                                                FontAwesomeIcons.chartSimple,
                                                color: Colors.white,
                                              ),
                                            ),
                                            label: const Text(
                                              'Track',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          const NavigationRailDestination(
                                            icon: Icon(
                                              CupertinoIcons.app_badge,
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
                                      const VerticalDivider(
                                          thickness: 0.5, width: 1),
                                      Expanded(
                                        child: IndexedStack(
                                          index: currentPage,
                                          children: pages(userData: userData),
                                        ),
                                      ),
                                    ])
                                  : pages(userData: userData)[currentPage],
                              bottomNavigationBar: MediaQuery.of(context)
                                          .size
                                          .width >=
                                      500
                                  ? const SizedBox()
                                  : NavigationBarTheme(
                                      data: NavigationBarThemeData(
                                          labelTextStyle:
                                              const MaterialStatePropertyAll(
                                                  TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                          backgroundColor:
                                              AppStyle.backgroundColor),
                                      child: NavigationBar(
                                          selectedIndex: currentPage,
                                          onDestinationSelected: (index) =>
                                              setState(
                                                  () => currentPage = index),
                                          destinations: [
                                            const NavigationDestination(
                                                icon: Icon(
                                                  CupertinoIcons
                                                      .square_grid_2x2,
                                                  color: Colors.white,
                                                ),
                                                label: 'Sessions'),
                                            NavigationDestination(
                                                icon: badge.Badge(
                                                  badgeContent: Text(
                                                    '${snapshot.data!.where((element) => element.device.name == kDeviceModelTKR1A1).length}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  ),
                                                  badgeStyle: badge.BadgeStyle(
                                                    shape:
                                                        badge.BadgeShape.circle,
                                                    //toAnimate: false,
                                                    badgeColor: currentPage == 1
                                                        ? AppStyle
                                                            .backgroundColor
                                                        : AppStyle.primaryColor,
                                                  ),
                                                  position: badge.BadgePosition
                                                      .topEnd(),
                                                  showBadge: snapshot.data!
                                                      .where((element) =>
                                                          element.device.name ==
                                                          kDeviceModelTKR1A1)
                                                      .isNotEmpty,
                                                  child: const Icon(
                                                    FontAwesomeIcons
                                                        .chartSimple,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                label: 'Track'),
                                            const NavigationDestination(
                                                icon: Icon(
                                                  CupertinoIcons.app_badge,
                                                  color: Colors.white,
                                                ),
                                                label: 'Devices'),
                                          ]),
                                    ),
                            ));
                  })
              : const Scaffold(
                  body: Center(
                    child: Text('No user data found'),
                  ),
                );
        });
  }
}
