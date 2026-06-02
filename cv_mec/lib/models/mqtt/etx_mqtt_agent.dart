import 'package:cv_mec/controllers/configuration_controller.dart';
import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/models/api_responses/mqtt_permission.dart';

import 'package:cv_mec/models/etx/full_registration.dart';
import 'package:cv_mec/models/etx/registration.dart';
import 'package:cv_mec/models/mqtt/mqtt_agent.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:cv_mec/models/utils.dart';
import 'package:cv_mec/services/api_service.dart';
import 'package:cv_mec/services/asn_service.dart';
import 'package:cv_mec/services/file_service.dart';
import 'package:cv_mec/services/param_controller.dart';
import 'package:cv_mec/services/timing.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:typed_data/typed_data.dart';
import 'package:cv_mec/models/protobuf_models/geo_routed_msg.pb.dart' as protobuf;
import 'dart:convert';

class EtxMqttAgent extends MqttAgent{

  ApiService apiService = Get.find<ApiService>();
  FileService fileService = Get.find<FileService>();
  ParamController paramController = Get.find<ParamController>();
  SettingsController settingsController = Get.find<SettingsController>();
  ConfigurationController configController = Get.find<ConfigurationController>();
  Timing timingService = Get.find<Timing>();
  ASNService asnService = Get.find<ASNService>();
  Map<String, bool> allowedTopicCache = {};

  MqttPermission? aclRules;
  
  FullRegistration? fullRegistration;

  EtxMqttAgent(Function(String?, String, List<int>, DateTime, DateTime?, String) processingFunction): super("ETX", processingFunction);

  @override
  Future<int> connect() async{

    Registration? registration;

    if (await fileService.checkIfRegistrationExists()) {
      logger.i("Loading Registration from Cache");
      registration = await fileService.getRegistration();
      fullRegistration = await apiService.checkRegistration(registration.deviceID);
    }

    if(registration == null || fullRegistration == null){
      logger.i("Loading Registration from Partner API");
      registration = await apiService.getRegistration(paramController.clientType.value, paramController.clientSubtype.value);
      if(registration != null){
        fullRegistration = await apiService.checkRegistration(registration!.deviceID);
      }else{
        logger.w( "Unable to retrieve registration information from partner API");
        return 1;
      }
      
    }
    
    if(fullRegistration != null){
      fileService.saveRegistration(registration);
    }else{
      logger.w("Unable to retrieve full registration information from partner API");
      return 2;
    }



    logger.i("Acquired Certificates for DeviceID: ${fullRegistration!.deviceID}");

    String vzString = paramController.networkType.value;

    if (settingsController.vzMode.value) {
      vzString = "VZ";
    } else {
      vzString = "non-VZ";
    }

    if(paramController.manualRegistrationMode.value || currentPosition == null){
      connectionUrl = await apiService.getConnection(fullRegistration!.deviceID,
        paramController.registrationLatitude.value, paramController.registrationLongitude.value, vzString);
    }else{
      connectionUrl = await apiService.getConnection(fullRegistration!.deviceID,
        currentPosition!.latitude, currentPosition!.longitude, vzString);
    }

    int result = await mqttService.connect(connectionUrl!, registration);
    if (result != 0) {
      return 3;
    }

    return 0;
  }

  @override
  Future<int> setupSubscribers() async{

    aclRules = await apiService.getAclRules();

    if(aclRules == null){
      logger.w("Unable to retrieve ACL Rules from Partner API. Using Default topic names");
      mqttService.subscribe("vzimp/1/Private/+/+/+/j2735/+/+", onRawAsnMessage); //MAP / TIM
      mqttService.subscribe("vzimp/1/Private/+/+/+/j2735_gr/+/+", onGeoRelevanceMessage);
      mqttService.subscribe("vzimp/1/GeoRelevance/+/+/Public/j2735/+/+", onRawAsnMessage); // SPaT
      mqttService.subscribe("vzimp/1/GeoRelevance/+/+/Public/j2735_gr/+/+", onGeoRelevanceMessage);
      return 1;
    }else{
      List<String> topics = getSubscriptions(aclRules!);
      for(String topic in topics){
        if(topic.contains("j2735_gr")){
          mqttService.subscribe(topic, onGeoRelevanceMessage);
        }else{
          mqttService.subscribe(topic, onRawAsnMessage);
        }
      }
      mqttService.subscribe("vzimp/1/ClientInfo", onClientInfo);
    }

    
    return 0;
  }

  @override 
  String sendMessage(List<int> message, MsgType messageType, DateTime sendTime){

    protobuf.GeoRoutedMsg msg = protobuf.GeoRoutedMsg();
    protobuf.Position pos = protobuf.Position();

    if(currentPosition != null){
      pos.latitude = currentPosition!.latitude;
      pos.longitude = currentPosition!.longitude;
    }else{
      return "Failure to Send Message - No Position";
    }

    msg.position = pos;

    Uint8Buffer buffer = Uint8Buffer();

    if(settingsController.enableIssScmsSigning.value){
      String? trimmedMessage;
      if(messageType == MsgType.BSM){
        trimmedMessage = asnService.trimMessageHeaders(ASNService.bytesToHex(message), asnService.BSM_START_FLAG);
      }else if(messageType == MsgType.PSM){
        trimmedMessage = asnService.trimMessageHeaders(ASNService.bytesToHex(message), asnService.BSM_START_FLAG);
      }
      
      if(trimmedMessage != null){
        message = ASNService.hexToBytes(trimmedMessage);
      }
    }
    

    msg.msgBytes = message;
    msg.time = Utils.dateTimeToTimestamp(sendTime);
      
    buffer.addAll(msg.writeToBuffer());

    String clientType = paramController.clientType.value;
    String clientSubtype = paramController.clientSubtype.value;
    if(fullRegistration != null){
      clientType = fullRegistration!.clientType;
      clientSubtype = fullRegistration!.clientSubtype;
    }

    String topic = "";
    switch (messageType) {
      case MsgType.BSM:
        topic = "vzimp/1/GeoRelevance/$clientType/$clientSubtype/Public/${paramController.messageFormat}/BSM";
        break;
      case MsgType.PSM:
        topic = "vzimp/1/GeoRelevance/$clientType/$clientSubtype/Public/${paramController.messageFormat}/PSM";
        break;
      case MsgType.TUM:
        topic = "vzimp/1/GeoRelevance/$clientType/$clientSubtype/Public/${paramController.messageFormat}/TUM";
        break;
      default:
        logger.e('$agentName does not support sending ${messageType.name} messages');
        break;
    }

    if(aclRules != null){
      bool isAllowed = false;
      if(allowedTopicCache.containsKey(topic)){
        isAllowed = allowedTopicCache[topic]!;
      }else{
        isAllowed = isTopicAllowed(topic, aclRules!);
        allowedTopicCache[topic] = isAllowed;
      }

      if(isAllowed){
        mqttService.publishBytes(buffer, topic);
      }else{
        logger.w("Topic $topic is not allowed by ACL Rules. Message not sent.");
      }
        
    }else{
      mqttService.publishBytes(buffer, topic);
    }
    return topic;
  }

  bool isTopicAllowed(String topic, MqttPermission aclRules){
    List<String> topicParts = topic.split('/');
    for(String allowedTopic in aclRules.publish){
      List<String> allowedParts = allowedTopic.split('/');
      if(doTopicsMatch(topicParts, allowedParts)){
        return true;
      } 
    }
    return false;
  }

  bool doTopicsMatch(List<String> topicParts, List<String> allowedParts){
    if (topicParts.length != allowedParts.length){
      return false;
    }
    for(int i =0; i< topicParts.length; i++){
      if(allowedParts[i] == '*'){
        continue;
      }else if (allowedParts[i][0] == '\$'){
        continue;
      }else if(allowedParts[i].contains('|')){
        List<String> options = allowedParts[i].split('|');
        if(!options.contains(topicParts[i])){
          return false;
        }
      }else if(allowedParts[i] != topicParts[i]){
        return false;
      }
    }
    return true;

  }



  void onGeoRelevanceMessage(MqttReceivedMessage<MqttMessage?> message, DateTime recTime) async {
    final recMess = message.payload as MqttPublishMessage;
    try{
      protobuf.GeoRoutedMsg decodedMessage = protobuf.GeoRoutedMsg.fromBuffer(recMess.payload.message);
      DateTime msgTime = Utils.timeStampToDateTime(decodedMessage.time);
      processingFunction(connectionUrl, message.topic, decodedMessage.msgBytes, recTime, msgTime, "ETX");
    }catch(e){
      logger.e("Failed to decode GeoRelevance Message: $e ${ASNService.bytesToHex(recMess.payload.message)}");
    }
    
  }

  void onRawAsnMessage(MqttReceivedMessage<MqttMessage?> message, DateTime recTime) async {
    final recMess = message.payload as MqttPublishMessage;
    processingFunction(connectionUrl, message.topic, recMess.payload.message, recTime, null, "ETX");
  }

  void onClientInfo(MqttReceivedMessage<MqttMessage?> message, DateTime recTime){
    final recMess = message.payload as MqttPublishMessage;
    logger.i("On Client Info Decoded ${ascii.decode(recMess.payload.message)}");
  }


  List<String> getSubscriptions(MqttPermission aclRules){

    Set<String> subscribeTopics = {};
    for(String sub in aclRules.subscribe){
      if(sub.contains("Small") || sub.contains("RegionalStatic") || sub.contains("Regional")){
        // Skip Small Vehicle Subscriptions since we will always use the large versions
        // Skip JSON format since there is not currently a standard encoding for JSON j2735 messages
        continue;
      }
      List<String> components = sub.split('/');
      List<String> topics = extractSubscriptions(components);

      subscribeTopics.addAll(topics);
    }
    return subscribeTopics.toList(); 
  }

  List<String> extractSubscriptions(List<String> components){
    if(components.isEmpty){
      return [""];
    }
    if(components[0] == '*'){
      List<String> results = extractSubscriptions(components.sublist(1));

      for(int i =0; i< results.length; i++){
        if(results[i] == ""){
          results[i] = "+";
        }else{
          results[i] = "+/${results[i]}";
        }
        
      }
      return results;
    }
    else if(components[0].contains('|')){
      List<String> parts = components[0].split('|');
      List<String> results = [];
      for(int i =0; i< parts.length; i++){
        if(parts[i] != 'JSON' && parts[i] != 'VzTrafficDensity'&& parts[i] != 'VzMapManager'){
          // Skip JSON format since there is not currently a standard encoding for JSON j2735 messages
          List<String> part_results = extractSubscriptions(components.sublist(1));
          for(int j =0; j< part_results.length; j++){
            if(part_results[j] == ""){
              results.add(parts[i]);
            }else{
              results.add("${parts[i]}/${part_results[j]}");
            }

          } 
        }
      }
      
      return results;
    }else{
      List<String> results = extractSubscriptions(components.sublist(1));
      for(int i =0; i< results.length; i++){
        if(results[i] == ""){
          results[i] = components[0];
        }else{
          results[i] = "${components[0]}/${results[i]}";
        }
        
      }
      return results;
    }
  }


  List<String> getSupportedMessageTypes(String topic){
    List<String> messageTypes = [];
    if(topic.contains('BSM')){
      messageTypes.add(MsgType.BSM.name);
    }
    if(topic.contains('PSM')){
      messageTypes.add(MsgType.PSM.name);
    }
    if(topic.contains('SPaT')){
      messageTypes.add(MsgType.SPAT.name);
    }
    if(topic.contains('MAP')){
      messageTypes.add(MsgType.MAP.name);
    }
    if(topic.contains('TIM')){
      messageTypes.add(MsgType.TIM.name);
    }
    return messageTypes;
  }

  @override
  Future<int> updateSubscribers() async{
    return 0;
  }

}

