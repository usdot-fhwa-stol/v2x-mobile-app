import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/personal_safety_message/animal_propelled_type.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/human_propelled_type.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/motorzied_propelled_type.dart';

class PropelledInformation {
  HumanPropelledType? human;
  AnimalPropelledType? animal;
  MotorizedPropelledType? motor;

  PropelledInformation.fromC(C.PropelledInformation c_propelledInformation) {
    if (c_propelledInformation.present == 0) {
      human = HumanPropelledType.values[c_propelledInformation.choice.human];
    } else if (c_propelledInformation.present == 1) {
      animal = AnimalPropelledType.values[c_propelledInformation.choice.animal];
    } else if (c_propelledInformation.present == 2) {
      motor = MotorizedPropelledType.values[c_propelledInformation.choice.motor];
    }
  }
}
