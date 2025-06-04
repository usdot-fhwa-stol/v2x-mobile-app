import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_device_user_type.dart';
import 'package:cv_mec/models/message_builders/message_builder.dart';
import 'package:cv_mec/services/asn_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class PsmMessageBuilder extends MessageBuilder {
  late C.PersonalSafetyMessage psm;

  final String psmTemplateString = "00201A0000020000000000000035A4E9006B49D1FF0000FFFF00000000";

  PsmMessageBuilder() {
    msgPtr = getNewTemplate();

    Pointer<C.MessageFrame> messageFrameValuePtr = msgPtr.value.cast<C.MessageFrame>();
    C.MessageFrame messageFrame = messageFrameValuePtr.ref;
    psm = messageFrame.value.choice.PersonalSafetyMessage;

    randomizeId();
  }

  @override
  Pointer<Pointer<Void>> getNewTemplate() {
    return asnService.decode(psmTemplateString);
  }

  @override
  void setTime(DateTime time) {
    psm.secMark = time.millisecond + time.second * 1000;
  }

  @override
  DateTime getTime(DateTime time) {
    int second = psm.secMark ~/ 1000;
    if (second > 50 && time.second < 10) {
      return DateTime(time.year, time.month, time.day, time.hour, time.minute, second, psm.secMark % 1000)
          .subtract(const Duration(minutes: 1));
    } else {
      return DateTime(time.year, time.month, time.day, time.hour, time.minute, second, psm.secMark % 1000);
    }
  }

  @override
  void setPosition(Position position) {
    psm.position.Long = (position.longitude * 1E7).toInt();
    psm.position.lat = (position.latitude * 1E7).toInt();
    psm.heading = (position.heading * 0.0125).toInt();

    psm.accuracy.semiMajor = (min(position.accuracy, 12.7) * 0.05).toInt();
    psm.accuracy.semiMinor = (min(position.accuracy, 12.7) * 0.05).toInt();

    if (position.headingAccuracy == 0) {
      psm.accuracy.orientation = 65535;
    } else {
      psm.accuracy.orientation = (position.headingAccuracy * 360.0 / 65535.0).toInt();
    }
  }

  @override
  LatLng getPosition() {
    return LatLng(psm.position.lat / 1E7.toInt(), psm.position.Long / 1E7.toInt());
  }

  @override
  void incrementMsgCnt() {
    int msgCnt = psm.msgCnt;
    msgCnt += 1;

    if (msgCnt > 127) {
      msgCnt = 0;
    }
    psm.msgCnt = msgCnt;
  }

  void randomizeId() {
    List<int> randomNumbers = List.generate(4, (_) => random.nextInt(255));
    Uint8List dataBuffer = psm.id.buf.asTypedList(randomNumbers.length);
    psm.id.size = 4;
    dataBuffer.setAll(0, randomNumbers);
  }

  String getPsmId() {
    final Uint8List byteList = psm.id.buf.asTypedList(psm.id.size);

    // Convert the byte list to a String (assuming UTF-8 encoding)
    return ASNService.bytesToHex(byteList);
  }

  void setPersonalDeviceUserType(PersonalDeviceUserType type) {
    psm.basicType = type.index;
  }

  PersonalDeviceUserType getPersonalDeviceUserType() {
    return PersonalDeviceUserType.values[psm.basicType];
  }

  void setPersonalDeviceUserTypeFromString(String type) {
    PersonalDeviceUserType deviceType = PersonalDeviceUserType.UNAVAILABLE;
    if (type == "Unavailable") {
      deviceType = PersonalDeviceUserType.UNAVAILABLE;
    } else if (type == "Pedestrian") {
      deviceType = PersonalDeviceUserType.APEDESTRIAN;
    } else if (type == "Cyclist") {
      deviceType = PersonalDeviceUserType.APEDALCYCLIST;
    } else if (type == "Public Safety Worker") {
      deviceType = PersonalDeviceUserType.APUBLICSAFETYWORKER;
    } else if (type == "Animal") {
      deviceType = PersonalDeviceUserType.ANANIMAL;
    }
    setPersonalDeviceUserType(deviceType);
  }
}
