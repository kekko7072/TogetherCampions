import 'imports.dart';

enum TopicDevice {
  SYSTEM,
  GPS_POSITION,
  GPS_NAVIGATION,
  MPU_ACCELERATION,
  MPU_GYROSCOPE
}

class MQTTService {
  final MqttServerClient client;
  final String deviceId;
  MQTTService(this.client, this.deviceId);

  ///TOPICS
  late List<String> topicsDevice = [
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
      print(
          'EXAMPLE::Change notification:: topic is <${recMess.topic}>, payload is <-- $pt -->');
      print('');
    });
  }

  void unsubscribeToAllTopic() {
    print('EXAMPLE:: <<<< UNSUBSCRIBE TO TOPICS >>>>');
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
    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      String value = webBrowserInfo.userAgent ??
          'NOT_FOUND_WEB'; // e.g. "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:61.0) Gecko/20100101 Firefox/61.0"
      return value.replaceAll(" ", "_");
    } else {
      if (Platform.isAndroid) {
        AndroidDeviceInfo info = await deviceInfo.androidInfo;
        String value =
            'MOBILE:ANDROID_MODEL:${info.model}_OS:${info.version}_NAME:${info.product}';
        return value.replaceAll(" ", "+");
      } else if (Platform.isIOS) {
        IosDeviceInfo info = await deviceInfo.iosInfo;
        String value =
            'MOBILE:IOS_MODEL:${info.utsname}_OS:${info.systemVersion}';
        return value.replaceAll(" ", "+");
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo info = await deviceInfo.macOsInfo;
        String value =
            'DESKTOP:MACOS_MODEL:${info.model}_OS:${info.osRelease}_NAME:${info.computerName}';
        return value.replaceAll(" ", "+");
      } else if (Platform.isWindows) {
        WindowsDeviceInfo info = await deviceInfo.windowsInfo;
        String value =
            'DESKTOP:WINDOWS_OS:${info.majorVersion}.${info.minorVersion}${info.buildNumber}_NAME:${info.computerName}_';
        return value.replaceAll(" ", "+");
      } else if (Platform.isLinux) {
        LinuxDeviceInfo info = await deviceInfo.linuxInfo;
        String value =
            'DESKTOP:LINUX_OS:${info.name}+${info.version}.${info.buildId}_NAME:${info.machineId}';
        return value.replaceAll(" ", "+");
      } else {
        return 'NOT_FOUND_PLATFORM';
      }
    }

    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"

    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    print('Running on ${iosInfo.utsname.machine}'); // e.g. "iPod7,1"

    WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
    print(
        'Running on ${webBrowserInfo.userAgent}'); // e.g. "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:61.0) Gecko/20100101 Firefox/61.0"
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
