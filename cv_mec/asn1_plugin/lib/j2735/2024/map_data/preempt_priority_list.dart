import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/map_data/signal_control_zone.dart';

class PreemptPriorityList {
  late List<SignalControlZone> preemptPriorityList;

  PreemptPriorityList.fromC(C.PreemptPriorityList c_preemptPriorityList) {
    preemptPriorityList = [];
  }
}
