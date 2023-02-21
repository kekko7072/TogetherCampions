import 'imports.dart';

class MQTTService {
  final MqttServerClient client;
  final String deviceId;
  MQTTService(this.client, this.deviceId);

  ///TOPICS
  List<String> get topicsDevice => [
        '$deviceId/SYSTEM',
        '$deviceId/GPS_POSITION',
        '$deviceId/GPS_NAVIGATION',
        '$deviceId/MPU_ACCELERATION',
        '$deviceId/MPU_GYROSCOPE'
      ];

  String topicsPath(String topic) => '$deviceId/$topic';

  Future<bool> connect(
      {required String user,
      required String password,
      required String clientIdentifier}) async {
    debugPrint("PORT: ${client.port}");

    /// Set the correct MQTT protocol for mosquito
    client.setProtocolV311();
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;

    final connMess = MqttConnectMessage()
        .authenticateAs(user, password)
        .withClientIdentifier(clientIdentifier)
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);

    debugPrint('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
      return true;
    } on Exception catch (e) {
      debugPrint('EXAMPLE::client exception - $e');
      client.disconnect();
      return false;
    }
  }

  void subscribeToAllTopic() {
    /// Lets try our subscriptions
    debugPrint('EXAMPLE:: <<<< SUBSCRIBE TO TOPICS >>>>');

    for (String topic in topicsDevice) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    }

    //client.subscribe(topic2, MqttQos.atLeastOnce);

    client.updates!.listen((messageList) {
      final recMess = messageList[0];
      if (recMess is! MqttReceivedMessage<MqttPublishMessage>) return;
      final pubMess = recMess.payload;
      final pt =
          MqttPublishPayload.bytesToStringAsString(pubMess.payload.message);
      debugPrint(
          'EXAMPLE::Change notification:: topic is <${recMess.topic}>, payload is <-- $pt -->');
      debugPrint('');
    });
  }

  void unsubscribeToAllTopic() {
    debugPrint('EXAMPLE:: <<<< UNSUBSCRIBE TO TOPICS >>>>');
    for (String topic in topicsDevice) {
      client.unsubscribe(topic);
    }
  }

  void publish(String topicDevice, String message) {
    debugPrint('EXAMPLE:: <<<< PUBLISH TO: $topicsDevice >>>>');

    final builder1 = MqttClientPayloadBuilder();
    builder1.addString(message);

    client.publishMessage(
        topicsPath(topicDevice), MqttQos.atLeastOnce, builder1.payload!);

    /*final builder2 = MqttClientPayloadBuilder();
    builder2.addString('Hello from mqtt_client topic 2');
    print('EXAMPLE:: <<<< PUBLISH 2 >>>>');
    client.publishMessage(topic2, MqttQos.atLeastOnce, builder2.payload!);

    final builder3 = MqttClientPayloadBuilder();
    builder3.addString('Hello from mqtt_client topic 3');
    print('EXAMPLE:: <<<< PUBLISH 3 - NO SUBSCRIPTION >>>>');
    client.publishMessage(topic3, MqttQos.atLeastOnce, builder3.payload!);*/
  }

  void listen() {
    client.published!.listen((MqttPublishMessage message) {
      debugPrint(
          '\nTopic: ${message.variableHeader!.topicName}\nMessage: ${String.fromCharCodes(message.payload.message)}\n');

      /*if (message.variableHeader!.topicName == topic3) {
        print('EXAMPLE:: Non subscribed topic received.');
      }*/
    });
  }

  void disconnect() {
    debugPrint('EXAMPLE::Disconnecting');
    client.disconnect();
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    debugPrint('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    debugPrint(
        'EXAMPLE::OnDisconnected client callback - Client disconnection');
  }

  Future<String> deviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String value = 'UNKNOWN_PLATFORM';
    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      value = webBrowserInfo.userAgent ?? 'NOT_FOUND_WEB';
    } else {
      if (Platform.isAndroid) {
        AndroidDeviceInfo info = await deviceInfo.androidInfo;
        value = info.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo info = await deviceInfo.iosInfo;
        value = '${info.utsname.machine}';
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo info = await deviceInfo.macOsInfo;
        value = info.model;
      } else if (Platform.isWindows) {
        //WindowsDeviceInfo info = await deviceInfo.windowsInfo;
        value = 'Windows';
      } else if (Platform.isLinux) {
        LinuxDeviceInfo info = await deviceInfo.linuxInfo;
        value = info.name;
      }
    }

    return ("${value.replaceAll(" ", "+")}+${const Uuid().v1()}")
        .substring(0, 23);
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
