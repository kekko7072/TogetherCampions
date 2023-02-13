import 'package:app/services/imports.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
    required this.userData,
  }) : super(key: key);
  final UserData userData;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UnitsSystem unitsSystem = UnitsSystem(
      speedUnits: SpeedUnits.kts,
      distanceUnits: DistanceUnits.km,
      temperatureUnits: TemperatureUnits.C);

  @override
  void initState() {
    super.initState();
    loadFromSettings();
  }

  void loadFromSettings() async {
    UnitsSystem val = await UnitsSystem.loadFromSettings();
    setState(() => unitsSystem = val);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Name: ${widget.userData.profile.name}',
                        ),
                        Text(
                          'Surname:  ${widget.userData.profile.surname}',
                        ),
                      ],
                    ),
                    Text(
                      'Email:  ${widget.userData.profile.email}',
                    ),
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Divider(),
                    ),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Temperature: '),
                        for (TemperatureUnits temp
                            in TemperatureUnits.values) ...[
                          FilterChip(
                            backgroundColor:
                                unitsSystem.temperatureUnits == temp
                                    ? AppStyle.primaryColor
                                    : Colors.white,
                            label: Text(
                              UnitsService.temperatureUnitsToString(temp),
                              style: TextStyle(
                                  fontWeight:
                                      unitsSystem.temperatureUnits == temp
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color: unitsSystem.temperatureUnits == temp
                                      ? Colors.white
                                      : AppStyle.primaryColor),
                            ),
                            onSelected: (value) async {
                              setState(
                                  () => unitsSystem.temperatureUnits = temp);
                              await UnitsSystem.saveToSettings(
                                  unitsSystem.toListString());
                            },
                          ),
                        ]
                      ],
                    ),
                    Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Speed: '),
                        for (SpeedUnits speed in SpeedUnits.values) ...[
                          FilterChip(
                            backgroundColor: unitsSystem.speedUnits == speed
                                ? AppStyle.primaryColor
                                : Colors.white,
                            label: Text(
                              UnitsService.speedUnitsToString(speed),
                              style: TextStyle(
                                  fontWeight: unitsSystem.speedUnits == speed
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: unitsSystem.speedUnits == speed
                                      ? Colors.white
                                      : AppStyle.primaryColor),
                            ),
                            onSelected: (value) async {
                              setState(() => unitsSystem.speedUnits = speed);
                              await UnitsSystem.saveToSettings(
                                  unitsSystem.toListString());
                            },
                          ),
                        ]
                      ],
                    ),
                    Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Distance: '),
                        for (DistanceUnits distance
                            in DistanceUnits.values) ...[
                          FilterChip(
                            backgroundColor:
                                unitsSystem.distanceUnits == distance
                                    ? AppStyle.primaryColor
                                    : Colors.white,
                            label: Text(
                              UnitsService.distanceUnitsToString(distance),
                              style: TextStyle(
                                  fontWeight:
                                      unitsSystem.distanceUnits == distance
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color: unitsSystem.distanceUnits == distance
                                      ? Colors.white
                                      : AppStyle.primaryColor),
                            ),
                            onSelected: (value) async {
                              setState(
                                  () => unitsSystem.distanceUnits = distance);
                              await UnitsSystem.saveToSettings(
                                  unitsSystem.toListString());
                            },
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
