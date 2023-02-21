import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

class TrackMQTTScreen extends StatefulWidget {
  const TrackMQTTScreen(
      {Key? key,
      required this.unitsSystem,
      required this.client,
      required this.mqttService})
      : super(key: key);

  final UnitsSystem unitsSystem;
  final MqttServerClient client;
  final MQTTService mqttService;

  @override
  State<TrackMQTTScreen> createState() => _TrackMQTTScreenState();
}

class _TrackMQTTScreenState extends State<TrackMQTTScreen> {
  ///RUN
  List<System> system = [];
  bool gpsPositionAvailable = false;
  List<GpsPosition> gpsPosition = [];
  bool gpsNavigationAvailable = false;
  List<GpsNavigation> gpsNavigation = [];
  List<Accelerometer> accelerometer = [];
  List<Gyroscope> gyroscope = [];

  @override
  void dispose() {
    widget.mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
            'CONNECTED: ${widget.client.connectionStatus!.state == MqttConnectionState.connected}'),
        Text(
            'MESSAGES: ${widget.client.connectionStatus!.state == MqttConnectionState.connected}'),
        StreamBuilder<MqttPublishMessage?>(
            stream: widget.client.published,
            builder: (context, snapshot) {
              MqttPublishMessage? message = snapshot.data;

              String messageTopic = message?.variableHeader?.topicName ?? '';

              print(message?.variableHeader?.topicName);

              ///PARSING INFO
              if (messageTopic == widget.mqttService.topicsDevice[0]) {
                debugPrint(widget.mqttService.topicsDevice[0]);
                print(String.fromCharCodes(snapshot.data!.payload.message));
              } else if (messageTopic == widget.mqttService.topicsDevice[1]) {
                debugPrint(widget.mqttService.topicsDevice[1]);
                print(String.fromCharCodes(snapshot.data!.payload.message));
              } else if (messageTopic == widget.mqttService.topicsDevice[2]) {
                debugPrint(widget.mqttService.topicsDevice[2]);
                print(String.fromCharCodes(snapshot.data!.payload.message));
              } else if (messageTopic == widget.mqttService.topicsDevice[3]) {
                debugPrint(widget.mqttService.topicsDevice[3]);
                print(String.fromCharCodes(snapshot.data!.payload.message));
              } else if (messageTopic == widget.mqttService.topicsDevice[4]) {
                debugPrint(widget.mqttService.topicsDevice[4]);
                print(String.fromCharCodes(snapshot.data!.payload.message));
              } else {
                debugPrint("NOT FOUND MATCHING!");
              }

              return Column(
                children: [
                  Text(
                      'Topic: ${snapshot.data?.variableHeader?.topicName}\nMessage: ${snapshot.data?.payload.message != null ? String.fromCharCodes(snapshot.data!.payload.message) : 'ND'}\n'),
                  /* Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => showCupertinoDialog(
                            context: context,
                            builder: (_) => const Card(),
                            barrierDismissible: true),
                        child: Text(
                          '${system.isNotEmpty ? UnitsService.temperatureUnitsFromCELSIUS(widget.unitsSystem.temperatureUnits, system.last.temperature).toStringAsFixed(2) : 'Loading...'} ${UnitsService.temperatureUnitsToString(widget.unitsSystem.temperatureUnits)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        CalculationService.timestamp(
                            system.last.timestamp - system.first.timestamp),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => showCupertinoDialog(
                            context: context,
                            builder: (_) => const Card(),
                            barrierDismissible: true),
                        child: Row(
                          children: [
                            BatteryIndicator(
                              batteryFromPhone: false,
                              batteryLevel: system.last.battery,
                              style: BatteryIndicatorStyle.skeumorphism,
                              colorful: true,
                              showPercentNum: false,
                              size: 25,
                              ratio: 1.5,
                              showPercentSlide: true,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "${system.last.battery} %",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),*/
                ],
              );
            }),
        CupertinoButton(
            child: const Text('DISCONNECT FROM MQTT'),
            onPressed: () async {
              widget.mqttService.unsubscribeToAllTopic();

              widget.mqttService.disconnect();

              Navigator.of(context).pop();
            }),
      ],
    );
  }
}
