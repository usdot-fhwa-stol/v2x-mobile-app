import 'dart:ffi';

import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/basic_safety_message/bsm_core_data.dart';
import 'package:asn1_plugin/j2735/2024/basic_safety_message/bsmpart_iiextension.dart';
import 'package:asn1_plugin/j2735/2024/basic_safety_message/partii_id.dart';
import 'package:asn1_plugin/j2735/2024/basic_safety_message/special_vehicle_extensions.dart';
import 'package:asn1_plugin/j2735/2024/basic_safety_message/supplemental_vehicle_extensions.dart';
import 'package:asn1_plugin/j2735/2024/basic_safety_message/vehicle_safety_extensions.dart';
import 'package:ffi/ffi.dart';

class BasicSafetyMessage {
  late BSMcoreData coreData;
  List<BSMpartIIExtension>? partII;

  BasicSafetyMessage.fromC(C.BasicSafetyMessage basicSafetyMessage) {
    coreData = BSMcoreData.fromC(basicSafetyMessage.coreData);
    if (basicSafetyMessage.partII.address != 0) {
      partII = [];
      for (int i = 0; i < basicSafetyMessage.partII.ref.list.count; i++) {
        if (basicSafetyMessage.partII.ref.list.array[i].address != 0) {
          if (basicSafetyMessage.partII.ref.list.array[i].ref.partII_Id == PartII_Id.vehicle_safety_extension.index) {
            this.partII!.add(VehicleSafetyExtensions.fromC(
                basicSafetyMessage.partII.ref.list.array[i].ref.partII_Value.choice.VehicleSafetyExtensions));
          } else if (basicSafetyMessage.partII.ref.list.array[i].ref.partII_Id == PartII_Id.special_vehicle_ext.index) {
            this.partII!.add(SpecialVehicleExtensions.fromC(
                basicSafetyMessage.partII.ref.list.array[i].ref.partII_Value.choice.SpecialVehicleExtensions));
          } else if (basicSafetyMessage.partII.ref.list.array[i].ref.partII_Id ==
              PartII_Id.supplemental_vehicle_ext.index) {
            this.partII!.add(SupplementalVehicleExtensions.fromC(
                basicSafetyMessage.partII.ref.list.array[i].ref.partII_Value.choice.SupplementalVehicleExtensions));
          }
        }
      }
    }
  }
}
