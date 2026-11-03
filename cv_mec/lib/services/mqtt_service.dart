import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cv_mec/models/etx/registration.dart';
import 'package:cv_mec/services/logging_service.dart';
import 'package:cv_mec/services/timing.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:typed_data/typed_data.dart';
import 'package:uuid/uuid.dart';

class MqttService extends GetxService {
  MqttServerClient? client;
  Map<String, Function(MqttReceivedMessage<MqttMessage?>, DateTime)> subscriberList = {};
  var pongCount = 0; // Pong counter
  Timing timingService = Get.find<Timing>();
  LoggingService loggingService = Get.find<LoggingService>();

  static const String etxTag = "ETX";
  static const String pc5Tag = "PC5";

  Future<int> connect(String connectionURL, Registration? registration) async {
    loggingService.addToAppLog("MQTT Service::Connecting to $connectionURL");
    pongCount=0;
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
      client!.disconnectOnNoResponsePeriod = 5;
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
      loggingService.showError('MQTT Service::Failed to Configure MQTT COnnection Client with error: $e');
      return -1;
    }

    try {
      loggingService.addToAppLog("MQTT Service::Attempting to connect to $connectionURL");
      MqttClientConnectionStatus? status = await client!.connect();
      loggingService.addToAppLog("MQTT Service::Connection attempt complete with status: $status");
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      loggingService.showError('MQTT Service::Failed to connect client exception - $e');
    } on SocketException catch (e) {
      // Raised by the socket layer
      loggingService.showError('MQTT Service::Connection failed with socket exception - $e');
    }

    /// Check we are connected
    if ((client!.connectionStatus?.state ?? MqttConnectionState.disconnected) == MqttConnectionState.connected) {
      loggingService.addToAppLog('MQTT Service::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      loggingService.showError('MQTT Service::ERROR Mosquitto client connection failed - disconnecting, status is ${client!.connectionStatus}');
      client!.disconnect();
      return -1;
    }

    if(client!.updates != null){
       // Setup Universal Subscriber. This will get parsed to individual subscribers as they are registered
      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? receivedMessages) {
        DateTime recTime = timingService.getTime();
        if(receivedMessages != null){
          loggingService.addToAppLog("MQTT Service::Received ${receivedMessages.length} messages from broker at $recTime");
            for (MqttReceivedMessage<MqttMessage?> message in receivedMessages) {
              for (String key in subscriberList.keys) {
                if (matchTopic(message.topic, key)) {
                  subscriberList[key]!(message, recTime);
                }
              }
            }
        }else{
          loggingService.showWarning("MQTT Service::Received Null Message List from Broker at $recTime");
        }
      });
    }else{
      loggingService.showWarning("MQTT Service::Client Updates Stream is Null. No Messages will be received");
    }

   

    loggingService.addToAppLog("Completed MQTT Connection to $connectionURL");

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

    final status = client?.connectionStatus;
    final origin = status?.disconnectionOrigin;

    loggingService.showWarning(
      'MQTT Service::Disconnected. '
      'Origin: $origin, '
      'State: ${status?.state}'
    );

    switch (origin) {
      case MqttDisconnectionOrigin.solicited:
        loggingService.addToAppLog(
          'MQTT Service::Client initiated the disconnection - This is normal if the app was closed, or the user switched away from the map page in the app.'
        );
        break;

      case MqttDisconnectionOrigin.unsolicited:
        loggingService.showWarning(
          'MQTT Service::Unexpected disconnection. - This may indicate a network issue or broker problem.'
        );
        break;

      case MqttDisconnectionOrigin.none:
        loggingService.showWarning(
          'MQTT Service::Disconnection origin is None. - This should not happen, and may indicate that the client was never connected properly to the broker.'
        );
        break;
      case null:
        loggingService.showWarning(
          'MQTT Service::Disconnection origin is Null.'
        );
        break;
    }

    if (pongCount == 3) {
      loggingService.addToAppLog(
        'MQTT Service::Pong count is correct'
      );
    } else {
      loggingService.showWarning(
        'MQTT Service::Pong count is $pongCount'
      );
    }
   
  }

  void onConnected() {
    loggingService.addToAppLog('MQTT Service::OnConnected client callback - Client connection was successful');
  }

  void pong() {
    pongCount++;
    loggingService.addToAppLog('MQTT Service::Ping response client callback invoked Keep Alive Count: $pongCount ${timingService.getTime()} Current number of Subscriptions: ${subscriberList.keys.length}');
  }

  void subscribe(String topicName, Function(MqttReceivedMessage<MqttMessage?>, DateTime) callback) async {
    loggingService.addToAppLog("MQTT Service::Subscribing to Topic: $topicName");
    int retryCount = 0;

    if (client != null) {
      while (client!.connectionStatus!.state != MqttConnectionState.connected) {
        await MqttUtilities.asyncSleep(1);
        retryCount += 1;
        if (retryCount > 3) {
          loggingService.showError('MQTT Service::Unable to Subscribe to Topic. Client is not Connected to Broker');
          return;
        }
      }

      client!.subscribe(topicName, MqttQos.atMostOnce);
      subscriberList[topicName] = callback;
    } else {
      loggingService.showWarning("Unable to subscribe to $topicName. Client is null");
    }
  }

  void unsubscribe(String topicName) {
    if (client != null && subscriberList.containsKey(topicName)) {
      loggingService.addToAppLog("MQTT Service::Unsubscribing from Topic: $topicName");
      client!.unsubscribe(topicName);
      subscriberList.remove(topicName);
    } else {
      loggingService.showWarning('MQTT Service::Tried to unsubscribe from $topicName, but no active subscription exists.');
    }
  }

  int publish(String message, String topicName) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    if (client != null && client!.connectionStatus!.state == MqttConnectionState.connected) {
      return client!.publishMessage(topicName, MqttQos.atMostOnce, builder.payload!);
    } else {
      loggingService.showError('MQTT Service::Unable to Send Message. Client is not connected');
      return -1;
    }
  }

  int publishBytes(Uint8Buffer message, String topicName) {
    final builder = MqttClientPayloadBuilder();
    builder.addBuffer(message);
    if (client != null && client!.connectionStatus!.state == MqttConnectionState.connected) {
      return client!.publishMessage(topicName, MqttQos.atMostOnce, builder.payload!);
    } else {
      loggingService.showError('MQTT Service::Unable to Send Message. Client is not connected');
      return -1;
    }
  }

  void disconnect() {
    loggingService.addToAppLog("Attempting to Disconnect MQTT Client");
    if (client != null && client!.connectionStatus!.state == MqttConnectionState.connected) {
      loggingService.addToAppLog('MQTT Service::Disconnecting from MQTT Broker');
      client!.disconnect();
      subscriberList.clear();
      loggingService.addToAppLog('MQTT Service::Disconnection Complete');
    } else {
      loggingService.showWarning('MQTT Service::Cannot Disconnect. MQTT Client Already Disconnected');
    }
  }
}
