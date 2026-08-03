import 'dart:math';

import 'package:cv_mec/models/msg_types.dart';
import 'package:cv_mec/services/logging_service.dart';
import 'package:cv_mec/services/mqtt_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttAgent{
  
  String agentName;
  MqttService mqttService = MqttService();
  LoggingService loggingService = Get.find<LoggingService>();
  Position? currentPosition;
  String? connectionUrl;
  Function(String?, String, List<int>, DateTime, DateTime?, String) processingFunction;
  int reconnectAttempts = 0;
  bool isReconnecting = false;
  
  

  MqttAgent(this.agentName, this.processingFunction){}

  // Template function to connect this agent to the specified broker. 
  Future<int> connect() async{
    throw UnimplementedError('connect method not implemented for mqtt agent $agentName');
  }

  // Template function for linking MQTT callback functions.
  Future<int> setupSubscribers(){
    throw UnimplementedError('setupSubscribers method not implemented for mqtt agent $agentName');
  }

  Future<int> updateSubscribers(){
    throw UnimplementedError('updateSubscribers method not implemented for mqtt agent $agentName');
  }

  String sendMessage(List<int> message, MsgType messageType, DateTime sendTime){
    throw UnimplementedError('sendMessage method not implemented for mqtt agent $agentName');
  }

  Future<void> reconnect() async {
    
    if(!isReconnecting){
      isReconnecting = true;
      loggingService.addToAppLog("MQTT Agent $agentName disconnected. Attempting to reconnect...");
      while(!isConnected()){
        loggingService.addToAppLog("Attempting to Reconnect MQTT Agent $agentName. Attempt number ${reconnectAttempts + 1}");
        await connect();
        reconnectAttempts++;
        
        if(!isConnected()){
          int delayMilliseconds = min(1000 * (1 << reconnectAttempts), 60000); // Exponential backoff: 2s, 4s, 8s, 16s, max 60s
          loggingService.addToAppLog("Reconnection attempt $reconnectAttempts failed. Waiting ${delayMilliseconds}ms before retry...");
          await Future.delayed(Duration(milliseconds: delayMilliseconds));
        }
      }

      if(isConnected()){
        loggingService.addToAppLog("Successfully reconnected MQTT Agent $agentName after $reconnectAttempts attempts");
        reconnectAttempts = 0;
        isReconnecting = false;
      } else {
        loggingService.showWarning("Failed to reconnect MQTT Agent $agentName after 5 attempts");
        isReconnecting = false;
      }
    }
  }

  void callback(MqttReceivedMessage<MqttMessage?> message, DateTime recTime){
    final recMess = message.payload as MqttPublishMessage;
    processingFunction(connectionUrl, message.topic, recMess.payload.message, recTime, null, agentName);
  }

  bool isConnected() {
    return mqttService.client != null && mqttService.client!.connectionStatus!.state == MqttConnectionState.connected;
  }

  void setPosition(Position? position){
    currentPosition = position;
  }

  
}