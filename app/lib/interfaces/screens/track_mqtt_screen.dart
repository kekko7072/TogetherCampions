import 'package:app/services/imports.dart';
import 'package:flutter/cupertino.dart';

class TrackMQTTScreen extends StatefulWidget {
  const TrackMQTTScreen({Key? key}) : super(key: key);

  @override
  State<TrackMQTTScreen> createState() => _TrackMQTTScreenState();
}

class _TrackMQTTScreenState extends State<TrackMQTTScreen> {
  final client = MqttServerClient('firringer362.cloud.shiftr.io', '');

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoButton(
            child: Text('CONNECT MQTT'),
            onPressed: () async {
              bool connected = await MQTTService(client).connect();
              print("CONNECTED SUCESSSFULLY: ${connected}");
              setState(() {});
              if (connected) {
                MQTTService(client).subscribeToTopic();
              }
            }),
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
            })
      ],
    );
  }
}
