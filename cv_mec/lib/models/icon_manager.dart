import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_device_user_type.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/public_safety_event_responder_worker_type.dart';
import 'package:asn1_plugin/j2735/2024/sensor_data_sharing_message/object_type.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:cv_mec/models/received_messages/received_msg.dart';
import 'package:cv_mec/models/received_messages/received_bsm.dart';
import 'package:cv_mec/models/received_messages/received_psm.dart';
import 'package:cv_mec/models/received_messages/received_sdsm.dart';
import 'package:cv_mec/models/vehicle.dart';
import 'package:flutter/material.dart';

class IconManager {
  static const IconData pedestrian = Icons.directions_walk;
  static const IconData bike = Icons.pedal_bike;
  static const IconData animal = Icons.pets;

  static const IconData publicSafetyWorker = Icons.construction;
  static const IconData fireWorker = Icons.fire_extinguisher;
  static const IconData hazmatWorker = Icons.dangerous_outlined;
  static const IconData securityWorker = Icons.security;
  static const IconData towWorker = Icons.phishing;
  static const IconData person = Icons.person;

  static const IconData error = Icons.bug_report;
  static const IconData unknown = Icons.question_mark_sharp;

  static const IconData car = Icons.directions_car;
  static const IconData truck = Icons.local_shipping;
  static const IconData motorcycle = Icons.two_wheeler;
  static const IconData bus = Icons.directions_bus;
  static const IconData fire = Icons.local_fire_department;
  static const IconData ambulance = Icons.local_hospital;
  static const IconData police = Icons.local_police;
  static const IconData tractor = Icons.agriculture;
  static const IconData icecream = Icons.icecream;

  static IconData getReceivedMessageIcon(ReceivedMsg msg) {
    if (msg.type == MsgType.BSM) {
      return getIconForBSM(VehicleType.fromVehicleClass((msg as ReceivedBsm).vehicleClass));
    } else if (msg.type == MsgType.SDSM) {
      return getIconForSDSM((msg as ReceivedSdsm).objectType);
    } else if (msg.type == MsgType.PSM) {
      ReceivedPsm psm = (msg as ReceivedPsm);
      return getIconForPSM(psm.deviceType, psm.workerType);
    }
    return unknown;
  }

  static IconData getIconForBSM(VehicleType type) {
    if (type == VehicleType.PASSENGER_VEHICLE) {
      return car;
    } else if (type == VehicleType.LIGHT_TRUCK) {
      return truck;
    } else if (type == VehicleType.TRUCK) {
      return truck;
    } else if (type == VehicleType.MOTORCYCLE) {
      return motorcycle;
    } else if (type == VehicleType.BUS) {
      return bus;
    } else if (type == VehicleType.FIRE) {
      return fire;
    } else if (type == VehicleType.AMBULANCE) {
      return ambulance;
    } else if (type == VehicleType.POLICE) {
      return police;
    } else if (type == VehicleType.ICE_CREAM_TRUCK) {
      return icecream;
    } else if (type == VehicleType.OTHER) {
      return tractor;
    } else {
      return car;
    }
  }

  static IconData getIconForSDSM(ObjectType type) {
    if (type == ObjectType.unknown) {
      return unknown;
    } else if (type == ObjectType.vehicle) {
      return car;
    } else if (type == ObjectType.vru) {
      return pedestrian;
    } else if (type == ObjectType.animal) {
      return animal;
    } else {
      return unknown;
    }
  }

  static IconData getIconForPSM(
      PersonalDeviceUserType userType, PublicSafetyEventResponderWorkerType? publicSafetyWorkerType) {
    if (userType == PersonalDeviceUserType.APEDESTRIAN) {
      return pedestrian;
    } else if (userType == PersonalDeviceUserType.APEDALCYCLIST) {
      return bike;
    } else if (userType == PersonalDeviceUserType.APUBLICSAFETYWORKER && publicSafetyWorkerType != null) {
      if (publicSafetyWorkerType == PublicSafetyEventResponderWorkerType.ADOTWORKER) {
        return publicSafetyWorker;
      } else if (publicSafetyWorkerType == PublicSafetyEventResponderWorkerType.ANIMALCONTROLERWORKER) {
        return animal;
      } else if (publicSafetyWorkerType == PublicSafetyEventResponderWorkerType.FIREANDEMSWORKER) {
        return fireWorker;
      } else if (publicSafetyWorkerType == PublicSafetyEventResponderWorkerType.HAZMATRESPONDER) {
        return hazmatWorker;
      } else if (publicSafetyWorkerType == PublicSafetyEventResponderWorkerType.LAWENFORCEMENT) {
        return securityWorker;
      } else if (publicSafetyWorkerType == PublicSafetyEventResponderWorkerType.TOWOPERATOR) {
        return towWorker;
      } else if (publicSafetyWorkerType == PublicSafetyEventResponderWorkerType.OTHERPERSONNEL) {
        return person;
      }
    } else if (userType == PersonalDeviceUserType.ANANIMAL) {
      return animal;
    }
    return person;
  }
}
