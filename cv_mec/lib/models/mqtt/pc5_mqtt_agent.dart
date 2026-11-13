import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/models/mqtt/mqtt_agent.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:get/get.dart';

class Pc5MqttAgent extends MqttAgent{

  SettingsController settingsController = Get.find<SettingsController>();
  Pc5MqttAgent(Function(String?, String, List<int>, DateTime, DateTime?, String) processingFunction): super("PC5", processingFunction);

  /// Connects this PC5 MQTT agent.
  ///
  /// Returns:
  /// - `0`: Connected successfully.
  /// - `non-zero`: the result code from the [MqttService.connect] method indicating the connect failure type
  @override
  Future<int> connect() async{
    connectionUrl = settingsController.pc5BrokerUrl.value;
    int result = await mqttService.connect(settingsController.pc5BrokerUrl.value, null);
    return result;
  }

  /// Sets up the subscribers for this PC5 MQTT agent.
  /// Returns:
  /// - `0`: Subscribers set up successfully.
  @override
  Future<int> setupSubscribers() async{
    print("Subscribing to PC5 Topics");
    mqttService.subscribe("Ettifos/V2X/ind/J2735/#", callback);
    return 0;
  }

  /// Sends a message using this PC5 MQTT agent. This method is currently not implemented for the PC5 MQTT Agent since 
  /// it is not intended to send messages over the PC5 interface yet. 
  ///
  /// Parameters:
  /// - `message`: The message payload as a list of bytes.
  /// - `messageType`: The type of the message.
  /// - `sendTime`: The time the message is sent.
  ///
  /// Returns:
  /// - An empty string since sending messages is not implemented for the PC5 MQTT Agent.
  @override 
  String sendMessage(List<int> message, MsgType messageType, DateTime sendTime){
    return "";
  }

  /// Updates the subscribers for this PC5 MQTT agent. This method is not required for the PC5 interface as it does not dynamically change subscriptions.
  /// Returns:
  /// - `0`: Subscribers updated successfully.
  @override
  Future<int> updateSubscribers() async{
    return 0;
  }
}