import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

class TrackMQTTScreen extends StatefulWidget {
  const TrackMQTTScreen({Key? key}) : super(key: key);

  @override
  State<TrackMQTTScreen> createState() => _TrackMQTTScreenState();
}

class _TrackMQTTScreenState extends State<TrackMQTTScreen> {
  TextEditingController server =
      TextEditingController(text: "firringer362.cloud.shiftr.io");

  TextEditingController serverUser =
      TextEditingController(text: "firringer362");

  TextEditingController serverPassword =
      TextEditingController(text: "tw8hqY2Cx0v65tjp");

  TextEditingController deviceId = TextEditingController(text: "AAAA0000AAAA");

  var client = MqttServerClient('', '');

  late MQTTService mqttService = MQTTService(client, deviceId.text);

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text('Server address',
                  style: Theme.of(context).textTheme.titleMedium),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                child: CupertinoTextField(
                  controller: server,
                ),
              ),
              const SizedBox(height: 10),
              Text('User', style: Theme.of(context).textTheme.titleMedium),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                child: CupertinoTextField(
                  controller: serverUser,
                ),
              ),
              const SizedBox(height: 10),
              Text('Password', style: Theme.of(context).textTheme.titleMedium),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                child: CupertinoTextField(
                  controller: serverPassword,
                ),
              ),
              const SizedBox(height: 10),
              Text('Device id', style: Theme.of(context).textTheme.titleMedium),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                child: CupertinoTextField(
                  controller: deviceId,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: CupertinoButton.filled(
                    child: const Text('CONNECT TO MQTT'),
                    onPressed: () async {
                      client = MqttServerClient(server.text, '');
                      mqttService = MQTTService(client, deviceId.text);

                      String clientIdentifier = await mqttService.deviceInfo();

                      connected = await mqttService.connect(
                          user: serverUser.text,
                          password: serverPassword.text,
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
