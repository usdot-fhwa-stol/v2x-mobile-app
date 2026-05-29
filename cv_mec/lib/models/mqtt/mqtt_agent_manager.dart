import 'package:cv_mec/models/data_queue.dart';
import 'package:cv_mec/models/mqtt/mqtt_agent.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:cv_mec/services/asn_service.dart';
import 'package:logger/logger.dart';
import 'package:geolocator/geolocator.dart';

class MqttAgentManager{
  List<MqttAgent> agents = [];
  Logger logger = Logger();
  MqttAgentManager(){}

  Future<int> connectAll() async{
    for(MqttAgent agent in List<MqttAgent>.from(agents)){ //looping this way to avoid concurrent modification errors
      logger.i("Connecting Agent ${agent.agentName}");
      final success = await agent.connect();
      if(success != 0){
        logger.w("Unable to Connect Agent ${agent.agentName}");
      }
    }
    return 0;
  }

  Future<int> subscribeAll() async{
    for(MqttAgent agent in agents){
      logger.i("Subscribing Agent ${agent.agentName}");
      final success = await agent.setupSubscribers();
      if(success != 0){
        logger.w("Unable to Subscribe Agent ${agent.agentName}");
      }
    }
    return 0;
  }

  void addAgent(MqttAgent agent){
    agents.add(agent);
  }

  void clearAgents(){
    agents.clear();
  }

  void disconnectAll(){
    for(MqttAgent agent in agents){
      agent.mqttService.disconnect();
    }
  }

  void sendMessage(List<int> message, MsgType messageType, DateTime sendTime, DataQueue sendQueue, bool signed){
    String hex = ASNService.bytesToHex(message);
    for(MqttAgent agent in agents){
      if(agent.isConnected()){
        var topic = agent.sendMessage(message, messageType, sendTime);
        sendQueue.addItem("$topic,${sendTime.millisecondsSinceEpoch},${agent.currentPosition?.longitude},${agent.currentPosition?.latitude},Unavailable,${agent.connectionUrl},$hex,$signed\n");
      }
    }
  }

  void setPosition(Position? pos){
    for(MqttAgent agent in agents){
      agent.setPosition(pos);
      agent.updateSubscribers();
    }
  }

  int getConnectionCount(){
    int count = 0;
    for(MqttAgent agent in agents){
      if(agent.isConnected()){
        count += 1;
      }else{
        agent.reconnect();
      }
    }
    return count;
  }
}