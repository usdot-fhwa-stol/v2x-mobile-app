import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/models/mqtt/mqtt_agent.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:get/get.dart';
import 'package:iss_scms/models/dsrc_msg_id.dart';
import 'package:typed_data/typed_data.dart';
import 'package:dart_geohash/dart_geohash.dart';

class IssMqttAgent extends MqttAgent{

  IssMqttAgent(Function(String?, String, List<int>, DateTime, DateTime?, String) processingFunction): super("ISS", processingFunction);
  GeoHasher geohasher = GeoHasher();
  String currentGeohash = "";
  List<String> surroundingGeohashes = [];

  final List<int> subscribedPSIDs = [
    DsrcMsgId.basicSafetyMessage.code,
    DsrcMsgId.personalSafetyMessage.code,
    DsrcMsgId.signalPhaseAndTimingMessage.code,
    DsrcMsgId.mapData.code,
    DsrcMsgId.travelerInformation.code,
    DsrcMsgId.signalStatusMessage.code,
    DsrcMsgId.signalRequestMessage.code
  ];

  final int bsmPSID = DsrcMsgId.basicSafetyMessage.code;
  final int psmPSID = DsrcMsgId.personalSafetyMessage.code;
  SettingsController settingsController = Get.find<SettingsController>();

  @override
  Future<int> connect() async{
    String connectionUrl = settingsController.issMqttBrokerUrl.value;
    logger.i("Connecting MQTT Agent $agentName to $connectionUrl");

    int result = await mqttService.connect(connectionUrl, null);
    if (result != 0) {
      logger.e("${agentName} unable to connect to MQTT Broker $connectionUrl");
      return 1;
    }

    return 0;
  }

  @override
  Future<int> setupSubscribers() async{
    currentGeohash = geohashInBaseThirtyTwo(currentPosition?.latitude ?? 0.0, currentPosition?.longitude ?? 0.0);
    surroundingGeohashes = getGeohashAndNeighbors(currentGeohash);
    if (currentGeohash.length < 7) {
      logger.e("Geohash is too short: $currentGeohash");
      return 1;
    }
    for(String neighbor in surroundingGeohashes){
      if(neighbor.length >= 7){
        for (int psid in subscribedPSIDs){
          mqttService.subscribe("v1/g32/${neighbor[0]}/${neighbor[1]}/${neighbor[2]}/${neighbor[3]}/${neighbor[4]}/${neighbor[5]}/${neighbor[6]}/$psid",callback);
        }
      }
    }
    return 0;
  }

  @override
  Future<int> updateSubscribers() async{
    if (isConnected()) {
      String newGeohash = geohashInBaseThirtyTwo(currentPosition?.latitude ?? 0.0, currentPosition?.longitude ?? 0.0);
      if(newGeohash != currentGeohash){
        currentGeohash = newGeohash;
        List<String> newGeohashes = getGeohashAndNeighbors(newGeohash);
        for(int i = surroundingGeohashes.length - 1; i >= 0; i--){
          String neighbor = surroundingGeohashes[i];
          if(neighbor.length >= 7 && !newGeohashes.contains(neighbor)){
            for (int psid in subscribedPSIDs){
              mqttService.unsubscribe("v1/g32/${neighbor[0]}/${neighbor[1]}/${neighbor[2]}/${neighbor[3]}/${neighbor[4]}/${neighbor[5]}/${neighbor[6]}/$psid");
            }
            surroundingGeohashes.removeWhere((value) => value == neighbor);
          } else if (neighbor.length >= 7){
            newGeohashes.removeWhere((value) => value == neighbor);
          } else {
            logger.e( "Geohash is too short: $neighbor");
            return 1;
          }
        }
        for(String neighbor in newGeohashes){
          if(neighbor.length >= 7){
            surroundingGeohashes.add(neighbor);
            for (int psid in subscribedPSIDs){
              mqttService.subscribe("v1/g32/${neighbor[0]}/${neighbor[1]}/${neighbor[2]}/${neighbor[3]}/${neighbor[4]}/${neighbor[5]}/${neighbor[6]}/$psid",callback);
            }
          }
        }
      }
    }
    return 0;
  }

  @override 
  String sendMessage(List<int> message, MsgType messageType, DateTime sendTime){
    Uint8Buffer buffer = Uint8Buffer();
    buffer.addAll(message);

    String topic = "";
    switch (messageType) {
      case MsgType.BSM:
        topic = "v1/g32/${currentGeohash[0]}/${currentGeohash[1]}/${currentGeohash[2]}/${currentGeohash[3]}/${currentGeohash[4]}/${currentGeohash[5]}/${currentGeohash[6]}/$bsmPSID";
        break;
      case MsgType.PSM:
        topic = "v1/g32/${currentGeohash[0]}/${currentGeohash[1]}/${currentGeohash[2]}/${currentGeohash[3]}/${currentGeohash[4]}/${currentGeohash[5]}/${currentGeohash[6]}/$psmPSID";
        break;
      default:
        logger.e('$agentName does not support sending ${messageType.name} messages');
        break;
    }

    mqttService.publishBytes(buffer, topic);
    return topic;
  }

  String geohashInBaseThirtyTwo(double latitude, double longitude) {
    String hash = geohasher.encode(longitude, latitude, precision: 7);
    return hash;
  }

  List<String> getGeohashAndNeighbors(String geohash) {
    List<String> neighbors = geohasher.neighbors(geohash).values.toList();
    currentGeohash = geohash;
    return neighbors;
  }
}