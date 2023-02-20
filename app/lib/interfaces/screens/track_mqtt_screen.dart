import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

class TrackMQTTScreen extends StatefulWidget {
  const TrackMQTTScreen({Key? key}) : super(key: key);

  @override
  State<TrackMQTTScreen> createState() => _TrackMQTTScreenState();
}

class _TrackMQTTScreenState extends State<TrackMQTTScreen> {
  TextEditingController serverController =
      TextEditingController(text: "firringer362.cloud.shiftr.io");

  TextEditingController serverUserController =
      TextEditingController(text: "firringer362");

  TextEditingController serverPasswordController =
      TextEditingController(text: "tw8hqY2Cx0v65tjp");

  TextEditingController deviceIdController =
      TextEditingController(text: "AAAA0000AAAA");

  var client = MqttServerClient('', '');

  late MQTTService mqttService = MQTTService(client, deviceIdController.text);

  bool connected = false;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return connected
        ? Column(
            children: [
              Text(
                  'CONNECTED: ${client.connectionStatus!.state == MqttConnectionState.connected}'),
              Text(
                  'MESSAGES: ${client.connectionStatus!.state == MqttConnectionState.connected}'),
              StreamBuilder<MqttPublishMessage>(
                  stream: client.published,
                  builder: (context, snapshot) {
                    return Column(
                      children: [
                        Text(
                            'Topic: ${snapshot.data?.variableHeader?.topicName}\nMessage: ${snapshot.data?.payload.message != null ? String.fromCharCodes(snapshot.data!.payload.message) : 'ND'}\n')
                      ],
                    );
                  }),
              CupertinoButton(
                  child: const Text('DISCONNECT FROM MQTT'),
                  onPressed: () async {
                    if (connected) {
                      mqttService.unsubscribeToAllTopic();
                    }

                    mqttService.disconnect();

                    setState(() {
                      connected = false;
                    });
                  }),
            ],
          )
        : Column(
            children: [
              const SizedBox(height: 20),
              Text('Server address',
                  style: Theme.of(context).textTheme.titleMedium),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
                child: TextFormField(
                  controller: serverController,
                  textAlign: TextAlign.center,
                  decoration: AppStyle().kTextFieldDecoration(
                      icon: Icons.device_hub, hintText: 'Server address'),
                ),
              ),
              const SizedBox(height: 10),
              Text('User', style: Theme.of(context).textTheme.titleMedium),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
                child: TextFormField(
                  controller: serverUserController,
                  textAlign: TextAlign.center,
                  decoration: AppStyle().kTextFieldDecoration(
                      icon: Icons.person, hintText: 'Server address'),
                ),
              ),
              const SizedBox(height: 10),
              Text('Password', style: Theme.of(context).textTheme.titleMedium),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
                child: TextFormField(
                  controller: serverPasswordController,
                  textAlign: TextAlign.center,
                  decoration: AppStyle().kTextFieldDecoration(
                      icon: Icons.lock, hintText: 'Server address'),
                ),
              ),
              const SizedBox(height: 10),
              Text('Device id', style: Theme.of(context).textTheme.titleMedium),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
                child: TextFormField(
                  controller: deviceIdController,
                  textAlign: TextAlign.center,
                  decoration: AppStyle().kTextFieldDecoration(
                      icon: Icons.devices, hintText: 'Server address'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: CupertinoButton.filled(
                    child: const Text('CONNECT TO MQTT'),
                    onPressed: () async {
                      client = MqttServerClient(serverController.text, '');
                      mqttService =
                          MQTTService(client, deviceIdController.text);

                      String clientIdentifier = await mqttService.deviceInfo();

                      connected = await mqttService.connect(
                          user: serverUserController.text,
                          password: serverPasswordController.text,
                          clientIdentifier: clientIdentifier);
                      debugPrint("CONNECTED SUCESSSFULLY: $connected");
                      setState(() {});
                      if (connected) {
                        mqttService.subscribeToAllTopic();
                      }
                    }),
              ),
            ],
          );
  }
}
