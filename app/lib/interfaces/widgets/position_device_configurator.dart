import 'package:flutter/cupertino.dart';
import 'package:app/services/imports.dart';

enum PositionDeviceConfiguratorModes { automatic, manual }

class PositionDeviceConfigurator extends StatefulWidget {
  const PositionDeviceConfigurator(
      {Key? key, required this.onChangePosition, this.initialPosition})
      : super(key: key);
  final Function(int x, int y, int z) onChangePosition;
  final DevicePosition? initialPosition;

  @override
  State<PositionDeviceConfigurator> createState() =>
      _PositionDeviceConfiguratorState();
}

class _PositionDeviceConfiguratorState
    extends State<PositionDeviceConfigurator> {
  PositionDeviceConfiguratorModes modes =
      PositionDeviceConfiguratorModes.automatic;

  //TODO create conversion form grades to int values for accelerometer  (ex. aZ - 16384.0 compensate g on horizontal device (0°))

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      ///TODO
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          Center(
            child: Wrap(
              spacing: 10,
              children: [
                FilterChip(
                    backgroundColor:
                        modes == PositionDeviceConfiguratorModes.automatic
                            ? AppStyle.primaryColor
                            : Colors.white,
                    label: Text(
                      'Automatic',
                      style: TextStyle(
                          fontWeight:
                              modes == PositionDeviceConfiguratorModes.automatic
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          color:
                              modes == PositionDeviceConfiguratorModes.automatic
                                  ? Colors.white
                                  : AppStyle.primaryColor),
                    ),
                    onSelected: (value) => setState(() =>
                        modes = PositionDeviceConfiguratorModes.automatic)),
                FilterChip(
                    backgroundColor:
                        modes == PositionDeviceConfiguratorModes.manual
                            ? AppStyle.primaryColor
                            : Colors.white,
                    label: Text(
                      'Manual',
                      style: TextStyle(
                          fontWeight:
                              modes == PositionDeviceConfiguratorModes.manual
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          color: modes == PositionDeviceConfiguratorModes.manual
                              ? Colors.white
                              : AppStyle.primaryColor),
                    ),
                    onSelected: (value) => setState(
                        () => modes = PositionDeviceConfiguratorModes.manual)),
              ],
            ),
          ),
          if (modes == PositionDeviceConfiguratorModes.automatic) ...[
            CupertinoButton.filled(
                child: const Text('Configure position'),
                onPressed: () => showCupertinoModalPopup(
                    context: context,
                    builder: (_) =>
                        const DevicePositionConfigurationAutomatic())),
          ] else if (modes == PositionDeviceConfiguratorModes.manual) ...[
            const DevicePositionConfigurationManual()
          ]
        ],
      ),
    );
  }
}

class DevicePositionConfigurationAutomatic extends StatefulWidget {
  const DevicePositionConfigurationAutomatic({Key? key}) : super(key: key);

  @override
  State<DevicePositionConfigurationAutomatic> createState() =>
      _DevicePositionConfigurationAutomaticState();
}

class _DevicePositionConfigurationAutomaticState
    extends State<DevicePositionConfigurationAutomatic> {
  bool showConfigurePage = false;

  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  @override
  Widget build(BuildContext context) {
    final accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();
    final magnetometer =
        _magnetometerValues?.map((double v) => v.toStringAsFixed(1)).toList();

    return !showConfigurePage
        ? CupertinoOnboarding(
            onPressedOnLastPage: () => setState(() => showConfigurePage = true),
            pages: const [
              CupertinoOnboardingPage(
                title: Text('Put phone where device will be'),
                body: Icon(
                  CupertinoIcons.square_stack_3d_down_right,
                  size: 200,
                ),
              ),
            ],
          )
        : Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  const Expanded(
                    child: RotationTransition(
                      turns: AlwaysStoppedAnimation(0.25),
                      child: Image(
                        image: AssetImage(
                          'assets/TKR1A1_90.png',
                        ),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  Wrap(
                    direction: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text('Acceleration: $accelerometer'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text('Gyroscope: $gyroscope'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text('Compensation: $gyroscope'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CupertinoButton.filled(
                      child: const Text('Save'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      magnetometerEvents.listen(
        (MagnetometerEvent event) {
          setState(() {
            _magnetometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
  }
}

class DevicePositionConfigurationManual extends StatefulWidget {
  const DevicePositionConfigurationManual({Key? key}) : super(key: key);

  @override
  State<DevicePositionConfigurationManual> createState() =>
      _DevicePositionConfigurationManualState();
}

class _DevicePositionConfigurationManualState
    extends State<DevicePositionConfigurationManual> {
  double devicePositionZ = 0.00;
  int positionIndexX = 1;
  List<int> positionsX = [0, 90, 180, 270, 360];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              CupertinoButton(
                  onPressed: devicePositionZ == -0.5
                      ? null
                      : () => setState(
                          () => devicePositionZ = devicePositionZ - 0.25),
                  child: const Icon(CupertinoIcons.arrow_left_square_fill)),
              Text('${(devicePositionZ * 360).toStringAsFixed(2)} °'),
              CupertinoButton(
                  onPressed: devicePositionZ == 0.5
                      ? null
                      : () => setState(
                          () => devicePositionZ = devicePositionZ + 0.25),
                  child: const Icon(CupertinoIcons.arrow_right_square_fill))
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(CupertinoIcons.arrow_down),
                  Text('gravity')
                ],
              ),
              RotationTransition(
                turns: AlwaysStoppedAnimation((devicePositionZ).toDouble()),
                child: Image(
                  image: AssetImage(
                    'assets/TKR1A1_${positionsX[positionIndexX]}.png',
                  ),
                  fit: BoxFit.fitHeight,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              CupertinoButton(
                  onPressed: positionIndexX < positionsX.length - 1
                      ? () => setState(() => ++positionIndexX)
                      : null,
                  child: const Icon(CupertinoIcons.arrow_up_square_fill)),
              Text('${positionsX[positionIndexX]} °'),
              CupertinoButton(
                onPressed: positionIndexX > 0
                    ? () => setState(() => --positionIndexX)
                    : null,
                child: const Icon(CupertinoIcons.arrow_down_square_fill),
              )
            ],
          ),
        )
      ],
    );
  }
}
