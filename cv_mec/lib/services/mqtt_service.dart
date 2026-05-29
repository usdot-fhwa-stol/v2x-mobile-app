import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cv_mec/models/etx/registration.dart';
import 'package:cv_mec/services/timing.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:typed_data/typed_data.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class MqttService extends GetxService {
  MqttServerClient? client;
  Map<String, Function(MqttReceivedMessage<MqttMessage?>, DateTime)> subscriberList = {};
  var pongCount = 0; // Pong counter
  Timing timingService = Get.find<Timing>();
  final Logger _logger = Logger();

  static const String etxTag = "ETX";
  static const String pc5Tag = "PC5";

  Future<int> connect(String connectionURL, Registration? registration) async {
    try {
      String clientId = 'cv-mec-${const Uuid().v4().substring(0, 16)}';
      if (registration != null) {
        clientId = registration.deviceID;
      }
      final uri = Uri.tryParse(connectionURL);
      if (uri == null || uri.scheme != 'mqtt') {
        throw const FormatException('Invalid MQTT URL');
      }
      final host = uri.host;
      final port = uri.hasPort ? uri.port : 1883; // Default MQTT port

      // Create New Client
      client = MqttServerClient.withPort(host, clientId, port);

      // Configure Client
      client!.secure = false;
      client!.logging(on: false);
      client!.setProtocolV311(); // Will print out version 4
      client!.keepAlivePeriod = 20;
      client!.connectTimeoutPeriod = 5000; // milliseconds
      client!.onDisconnected = onDisconnected;
      client!.onConnected = onConnected;
      client!.onSubscribed = onSubscribed;
      client!.autoReconnect = true;
      client!.autoReconnect = false;

      if (registration != null) {
        final context = SecurityContext.defaultContext;
        context.setClientAuthoritiesBytes(Uint8List.fromList(utf8.encode(registration.certificates.ca)));
        context.setTrustedCertificatesBytes(Uint8List.fromList(utf8.encode(registration.certificates.ca)));
        context.useCertificateChainBytes(Uint8List.fromList(utf8.encode(registration.certificates.cert)));
        context.usePrivateKeyBytes(Uint8List.fromList(utf8.encode(registration.certificates.key)));
        client!.secure = true;
        client!.securityContext = context;
      }

      final connMess = MqttConnectMessage().withClientIdentifier(clientId).startClean();
      client!.connectionMessage = connMess;

      client!.pongCallback = pong;
    } catch (e) {
      _logger.e('CV_MEC::Certificate Error - $e');
      return -1;
    }

    try {
      var status = await client!.connect();
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      _logger.e('CV_MEC::client exception - $e');
    } on SocketException catch (e) {
      // Raised by the socket layer
      _logger.e('CV_MEC::socket exception - $e');
    }

    /// Check we are connected
    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      _logger.i('CV_MEC::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      _logger
          .e('CV_MEC::ERROR Mosquitto client connection failed - disconnecting, status is ${client!.connectionStatus}');
      client!.disconnect();
      return -1;
    }

    // Setup Universal Subscriber. This will get parsed to individual subscribers as they are registered
    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? receivedMessages) {
      DateTime recTime = timingService.getTime();
      for (MqttReceivedMessage<MqttMessage?> message in receivedMessages!) {
        for (String key in subscriberList.keys) {
          if (matchTopic(message.topic, key)) {
            subscriberList[key]!(message, recTime);
          }
        }
      }
    });

    _logger.i("Completed MQTT Connection to $connectionURL");

    return 0;
  }

  bool matchTopic(String topic, String matchTopic) {
    List<String> topicParts = topic.split('/');
    List<String> matchTopicParts = matchTopic.split('/');

    if (topicParts.length != matchTopicParts.length) {
      return false;
    }

    for (int i = 0; i < topicParts.length; i++) {
      if (topicParts[i] != matchTopicParts[i] && matchTopicParts[i] != '+' && matchTopicParts[i] != "#") {
        return false;
      }
    }

    return true;
  }

  void onSubscribed(String topic) {
  }

  void onDisconnected() {
    _logger.w('CV_MEC::OnDisconnected client callback - Client disconnection');
    if (client!.connectionStatus!.disconnectionOrigin == MqttDisconnectionOrigin.solicited) {
      _logger.i('CV_MEC::OnDisconnected callback is solicited, this is correct');
    } else {
      _logger.w('CV_MEC::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
    }
    if (pongCount == 3) {
      _logger.i('CV_MEC:: Pong count is correct');
    } else {
      _logger.w('CV_MEC:: Pong count is incorrect, expected 3. actual $pongCount');
    }
  }

  void onConnected() {
    _logger.i('CV_MEC::OnConnected client callback - Client connection was successful');
  }

  void pong() {
    _logger.i('CV_MEC::Ping response client callback invoked');
    pongCount++;
  }

  void subscribe(String topicName, Function(MqttReceivedMessage<MqttMessage?>, DateTime) callback) async {

    int retryCount = 0;

    if (client != null) {
      while (client!.connectionStatus!.state != MqttConnectionState.connected) {
        await MqttUtilities.asyncSleep(1);
        retryCount += 1;
        if (retryCount > 3) {
          _logger.e('CV_MEC::Unable to Subscribe to Topic. Client is not Connected to Broker');
          return;
        }
      }

      client!.subscribe(topicName, MqttQos.atMostOnce);
      subscriberList[topicName] = callback;
    } else {
      _logger.w("Unable to subscribe to $topicName. Client is null");
    }
  }

  void unsubscribe(String topicName) {
    if (client != null && subscriberList.containsKey(topicName)) {
      client!.unsubscribe(topicName);
      subscriberList.remove(topicName);
    } else {
      _logger.w('Tried to unsubscribe from $topicName, but no active subscription exists.');
    }
  }

  int publish(String message, String topicName) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    if (client != null && client!.connectionStatus!.state == MqttConnectionState.connected) {
      return client!.publishMessage(topicName, MqttQos.atMostOnce, builder.payload!);
    } else {
      _logger.e('CV_MEC::Unable to Send Message. Client is not connected');
      return -1;
    }
  }

  int publishBytes(Uint8Buffer message, String topicName) {
    final builder = MqttClientPayloadBuilder();
    builder.addBuffer(message);
    if (client != null && client!.connectionStatus!.state == MqttConnectionState.connected) {
      return client!.publishMessage(topicName, MqttQos.atMostOnce, builder.payload!);
    } else {
      _logger.e('CV_MEC::Unable to Send Message. Client is not connected');
      return -1;
    }
  }

  void disconnect() {
    if (client != null && client!.connectionStatus!.state == MqttConnectionState.connected) {
      _logger.i('CV_MEC::Disconnecting from MQTT Broker');
      client!.disconnect();
      subscriberList.clear();
      _logger.i('CV_MEC::Disconnection Complete');
    } else {
      _logger.w('CV_MEC::Cannot Disconnect. MQTT Client Already Disconnected');
    }
  }
}
