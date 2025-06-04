import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cv_mec/models/imp/registration.dart';
import 'package:cv_mec/services/timing.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'package:typed_data/typed_data.dart';

class MqttService extends GetxService {
  MqttServerClient? client;
  Map<String, Function(MqttReceivedMessage<MqttMessage?>, DateTime)> subscriberList = {};
  var pongCount = 0; // Pong counter
  Timing timingService = Get.find<Timing>();

  Future<int> connect(String connectionURL, Registration registration) async {
    try {
      String clientId = registration.deviceID;

      // Trim The MQTT Connection String to work with Dart
      String headerPrefix = "mqtt://";
      String portSuffix = ":8883";
      String trimmedString = connectionURL.substring(
          connectionURL.indexOf("headerPrefix") + headerPrefix.length + 1, connectionURL.indexOf(portSuffix));

      // Create New Client
      client = MqttServerClient.withPort(trimmedString, clientId, 8883);
      final context = SecurityContext.defaultContext;
      context.setClientAuthoritiesBytes(Uint8List.fromList(utf8.encode(registration.certificates.ca)));
      context.setTrustedCertificatesBytes(Uint8List.fromList(utf8.encode(registration.certificates.ca)));
      context.useCertificateChainBytes(Uint8List.fromList(utf8.encode(registration.certificates.cert)));
      context.usePrivateKeyBytes(Uint8List.fromList(utf8.encode(registration.certificates.key)));

      // Configure Client
      client!.secure = true;
      client!.logging(on: true);
      client!.setProtocolV311(); // Will print out version 4
      client!.keepAlivePeriod = 20;
      client!.connectTimeoutPeriod = 5000; // milliseconds
      client!.onDisconnected = onDisconnected;
      client!.onConnected = onConnected;
      client!.onSubscribed = onSubscribed;
      client!.autoReconnect = true;
      client!.securityContext = context;
      client!.autoReconnect = false;

      final connMess = MqttConnectMessage().withClientIdentifier(clientId).startClean();
      client!.connectionMessage = connMess;

      client!.pongCallback = pong;
    } catch (e) {
      print('CV_MEC::Certificate Error - $e');
      return -1;
    }

    try {
      await client!.connect();
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('CV_MEC::client exception - $e');
      // client!.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      print('CV_MEC::socket exception - $e');
      // client!.disconnect();
    }

    /// Check we are connected
    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      print('CV_MEC::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print('CV_MEC::ERROR Mosquitto client connection failed - disconnecting, status is ${client!.connectionStatus}');
      client!.disconnect();
      return -1;
    }

    // Setup Universal Subscriber. This will get parsed to individual subscribers as they are registered
    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? receivedMessages) {
      DateTime recTime = timingService.getKronosTime();
      for (MqttReceivedMessage<MqttMessage?> message in receivedMessages!) {
        for (String key in subscriberList.keys) {
          if (matchTopic(message.topic, key)) {
            subscriberList[key]!(message, recTime);
          }
        }
      }
    });

    return 0;
  }

  bool matchTopic(String topic, String matchTopic) {
    List<String> topicParts = topic.split('/');
    List<String> matchTopicParts = matchTopic.split('/');

    if (topicParts.length != matchTopicParts.length) {
      return false;
    }

    for (int i = 0; i < topicParts.length; i++) {
      if (topicParts[i] != matchTopicParts[i] && matchTopicParts[i] != '+') {
        return false;
      }
    }

    return true;
  }

  void onSubscribed(String topic) {
    print('CV_MEC::Subscription confirmed for topic $topic');
  }

  void onDisconnected() {
    print('CV_MEC::OnDisconnected client callback - Client disconnection');
    if (client!.connectionStatus!.disconnectionOrigin == MqttDisconnectionOrigin.solicited) {
      print('CV_MEC::OnDisconnected callback is solicited, this is correct');
    } else {
      print('CV_MEC::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
    }
    if (pongCount == 3) {
      print('CV_MEC:: Pong count is correct');
    } else {
      print('CV_MEC:: Pong count is incorrect, expected 3. actual $pongCount');
    }
  }

  void onConnected() {
    print('CV_MEC::OnConnected client callback - Client connection was successful');
  }

  void pong() {
    print('CV_MEC::Ping response client callback invoked');
    pongCount++;
  }

  void subscribe(String topicName, Function(MqttReceivedMessage<MqttMessage?>, DateTime) callback) async {
    print('CV_MEC::Subscribing to the $topicName topic');

    int retryCount = 0;
    while (client!.connectionStatus!.state != MqttConnectionState.connected) {
      await MqttUtilities.asyncSleep(1);
      retryCount += 1;
      if (retryCount > 3) {
        print('CV_MEC::Unable to Subscribe to Topic. Client is not Connected to Broker');
        return;
      }
    }

    client!.subscribe(topicName, MqttQos.atMostOnce);
    subscriberList[topicName] = callback;
  }

  void unsubsubscribe(String topicName) {
    print('CV_MEC::Unsubscribing');
    if (client != null) {
      client!.unsubscribe(topicName);
    }
    subscriberList.remove(topicName);
  }

  int publish(String message, String topicName) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    if (client != null && client!.connectionStatus!.state == MqttConnectionState.connected) {
      // print('EXAMPLE::Publishing $message to topic $topicName');
      return client!.publishMessage(topicName, MqttQos.atMostOnce, builder.payload!);
    } else {
      print('CV_MEC::Unable to Send Message. Client is not connected');
      return -1;
    }
  }

  int publishBytes(Uint8Buffer message, String topicName) {
    final builder = MqttClientPayloadBuilder();
    builder.addBuffer(message);
    if (client != null && client!.connectionStatus!.state == MqttConnectionState.connected) {
      // print('EXAMPLE::Publishing $message to topic $topicName');
      return client!.publishMessage(topicName, MqttQos.atMostOnce, builder.payload!);
    } else {
      print('CV_MEC::Unable to Send Message. Client is not connected');
      return -1;
    }
  }

  void disconnect() {
    if (client != null && client!.connectionStatus!.state == MqttConnectionState.connected) {
      print('CV_MEC::Disconnecting from MQTT Broker');
      client!.disconnect();
      subscriberList.clear();
      print('CV_MEC::Disconnection Complete');
    } else {
      print('CV_MEC::Cannot Disconnect. MQTT Client Already Disconnected');
    }
  }
}
