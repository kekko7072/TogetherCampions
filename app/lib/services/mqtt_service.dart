import 'package:mqtt_client/mqtt_client.dart';

import 'imports.dart';

class MQTTService {
  final MqttServerClient client;
  MQTTService(this.client);

  final String topic1 = 'AAA000AAA/timestamp'; // Not a wildcard topic
  final String topic2 = 'AAA000AAA/latitude'; // Not a wildcard topic
  final String topic3 = 'AAA000AAA/longitude';

  Future<bool> connect() async {
    print(client.port);

    /// Set the correct MQTT protocol for mosquito
    client.setProtocolV311();
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    final connMess = MqttConnectMessage()
        .authenticateAs("firringer362", "tw8hqY2Cx0v65tjp")
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
      return true;
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      client.disconnect();
      return false;
    }
  }

  void subscribeToTopic() {
    /// Lets try our subscriptions
    print('EXAMPLE:: <<<< SUBSCRIBE >>>>');

    client.subscribe(topic1, MqttQos.atLeastOnce);

    client.subscribe(topic2, MqttQos.atLeastOnce);

    client.updates!.listen((messageList) {
      final recMess = messageList[0];
      if (recMess is! MqttReceivedMessage<MqttPublishMessage>) return;
      final pubMess = recMess.payload;
      final pt =
          MqttPublishPayload.bytesToStringAsString(pubMess.payload.message);
      print(
          'EXAMPLE::Change notification:: topic is <${recMess.topic}>, payload is <-- $pt -->');
      print('');
    });
  }

  void unsubscribeToTopic() {
    print('EXAMPLE::Unsubscribing');
    client.unsubscribe(topic1);
    client.unsubscribe(topic2);
  }

  void publish() {
    final builder1 = MqttClientPayloadBuilder();
    builder1.addString('Hello from mqtt_client topic 1');
    print('EXAMPLE:: <<<< PUBLISH 1 >>>>');
    client.publishMessage(topic1, MqttQos.atLeastOnce, builder1.payload!);

    final builder2 = MqttClientPayloadBuilder();
    builder2.addString('Hello from mqtt_client topic 2');
    print('EXAMPLE:: <<<< PUBLISH 2 >>>>');
    client.publishMessage(topic2, MqttQos.atLeastOnce, builder2.payload!);

    final builder3 = MqttClientPayloadBuilder();
    builder3.addString('Hello from mqtt_client topic 3');
    print('EXAMPLE:: <<<< PUBLISH 3 - NO SUBSCRIPTION >>>>');
    client.publishMessage(topic3, MqttQos.atLeastOnce, builder3.payload!);
  }

  void listen() {
    client.published!.listen((MqttPublishMessage message) {
      print(
          '\nTopic: ${message.variableHeader!.topicName}\nMessage: ${String.fromCharCodes(message.payload.message)}\n');

      if (message.variableHeader!.topicName == topic3) {
        print('EXAMPLE:: Non subscribed topic received.');
      }
    });
  }

  void disconnect() {
    print('EXAMPLE::Disconnecting');
    client.disconnect();
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
  }
}
/*
    /// If needed you can listen for published messages that have completed the publishing
    /// handshake which is Qos dependant. Any message received on this stream has completed its
    /// publishing handshake with the broker.
    client.published!.listen((MqttPublishMessage message) {
      print(
          '\nTopic: ${message.variableHeader!.topicName}\nMessage: ${String.fromCharCodes(message.payload.message)}\n');

      if (message.variableHeader!.topicName == topic3) {
        print('EXAMPLE:: Non subscribed topic received.');
      }
    });*/

/*print('EXAMPLE::Sleeping....');
    await MqttUtilities.asyncSleep(60);
    await MqttUtilities.asyncSleep(10);
   */
