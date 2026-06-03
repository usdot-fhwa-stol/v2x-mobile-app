import 'dart:typed_data';
import 'package:asn1_plugin/generated_bindings.dart' as C;
import 'package:asn1_plugin/asn1.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_safety_message.dart';
import 'package:asn1_plugin/j2735/2024/sensor_data_sharing_message/sensor_data_sharing_message.dart';
import 'package:asn1_plugin/j2735/2024/spat/spat.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_information.dart';
import 'package:asn1_plugin/j2735/2024/basic_safety_message/basic_safety_message.dart';
import 'package:asn1_plugin/j2735/2024/map_data/map_data.dart';
import 'package:asn1_plugin/j3217/2022/toll_advertisement_message/toll_advertisement_message.dart';
import 'package:asn1_plugin/j3217/2022/toll_usage_message/toll_usage_message.dart';
import 'package:asn1_plugin/j3217/2022/toll_usage_message/tum_data.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:cv_mec/services/logging_service.dart';
import 'package:get/get.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:math';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:asn1_plugin/j3217/2022/toll_usage_ack_message/toll_usage_ack_message.dart';

class ASNService extends GetxController {
  late C.NativeBindings _bindings;

  final String timTemplate =
      "001F8090701431EB7AF1627185E2EDEE8A0F775D9B0301C263D16BD9677A37DFFFF93F422AD3001EA007F96937E1CF5AD1BDFA54EADF62C17316CB99385CE1AC000000004C7A2D7B2CEF46FB271186000422C1D5AEE008397FB1606A3D428A95ADF610590FCFC581E03208917849C3E58AD5DE10C054E6F04042AF59835016A3043480BFDF229E83A714334001002009EEEBB36000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

  //final int encodeBufferSize = 1024;
  final int encodeBufferSize = 65536;

  final String MAP_START_FLAG = "0012";
  final String SPAT_START_FLAG = "0013";
  final String TIM_START_FLAG = "001F";
  final String BSM_START_FLAG = "0014";
  final String SSM_START_FLAG = "001E";
  final String PSM_START_FLAG = "0020";
  final String SRM_START_FLAG = "001D";
  final String SDSM_START_FLAG = "0029";
  final String TAM_START_FLAG = "0025";  
  final String TUM_START_FLAG = "0026";
  final String TUMACK_START_FLAG = "0027";

  late final List<String> checkStartFlags;
  late final Map<String, MsgType> messageTypeMap;
  Random random = Random();

  LoggingService loggingService = Get.find<LoggingService>();
  ASNService() {
    if (Platform.isLinux) {
      DynamicLibrary dylib;
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      final soPath = p.join(exeDir, 'lib', 'libasn1parser.so');
      dylib = DynamicLibrary.open(soPath);
      _bindings = C.NativeBindings(dylib);
    } else {
      _bindings = Asn1.getBindings();
    }

    checkStartFlags = [
      TIM_START_FLAG,
      BSM_START_FLAG,
      MAP_START_FLAG,
      SPAT_START_FLAG,
      PSM_START_FLAG,
      SDSM_START_FLAG,
      TAM_START_FLAG, 
      TUM_START_FLAG,
      TUMACK_START_FLAG,
    ];

    messageTypeMap = {
      MAP_START_FLAG: MsgType.MAP,
      SPAT_START_FLAG: MsgType.SPAT,
      TIM_START_FLAG: MsgType.TIM,
      BSM_START_FLAG: MsgType.BSM,
      SSM_START_FLAG: MsgType.SSM,
      PSM_START_FLAG: MsgType.PSM,
      SRM_START_FLAG: MsgType.SRM,
      SDSM_START_FLAG: MsgType.SDSM,
      TAM_START_FLAG: MsgType.TAM,  
      TUM_START_FLAG: MsgType.TUM,
      TUMACK_START_FLAG: MsgType.TUMACK,
    };
  }

  Pointer<Pointer<Void>> getTemplateTIM() {
    return decode(timTemplate);
  }

  MsgType determineHexMessageType(String hex) {
    String hexUpper = hex.toUpperCase();
    int lowestIndex = -1;
    MsgType messageType = MsgType.UNKNOWN;
    for (int i = 0; i < checkStartFlags.length; i++) {
      int checkIndex = findValidStartFlagLocation(hexUpper, checkStartFlags[i]);
      if (checkIndex >= 0 && (checkIndex < lowestIndex || lowestIndex == -1)) {
        lowestIndex = checkIndex;
        messageType = messageTypeMap[checkStartFlags[i]] ?? MsgType.UNKNOWN;
      }
    }
    return messageType;
  }

  String? trimMessageHeaders(String hex, String startFlag) {
    String hexUpper = hex.toUpperCase();
    int startFlagLocation = findValidStartFlagLocation(hexUpper, startFlag);
    if (startFlagLocation == -1) {
      return null;
    } else {
      return hexUpper.substring(startFlagLocation);
    }
  }

  // Returns the first valid location of a given start flag within the hex string
  int findValidStartFlagLocation(String hex, String startFlag) {
    int index = hex.indexOf(startFlag);
    if (index != 0) {
      index = hex.indexOf(startFlag, 10);
    }

    while (index != -1 && index % 2 != 0) {
      index = hex.indexOf(startFlag, index + 1);
    }
    return index;
  }

  BasicSafetyMessage parseBSM(Pointer<Pointer<Void>> message) {
    Pointer<C.MessageFrame> messageFrameValuePtr = message.value.cast<C.MessageFrame>();
    C.MessageFrame messageFrame = messageFrameValuePtr.ref;
    C.BasicSafetyMessage cBsm = messageFrame.value.choice.BasicSafetyMessage;

    BasicSafetyMessage bsm = BasicSafetyMessage.fromC(cBsm);

    return bsm;
  }

  MapData parseMap(Pointer<Pointer<Void>> message) {
    Pointer<C.MessageFrame> messageFrameValuePtr = message.value.cast<C.MessageFrame>();
    C.MessageFrame messageFrame = messageFrameValuePtr.ref;
    C.MapData cMap = messageFrame.value.choice.MapData;

    MapData map = MapData.fromC(cMap);

    return map;
  }

  Spat parseSpat(Pointer<Pointer<Void>> message) {
    Pointer<C.MessageFrame> messageFrameValuePtr = message.value.cast<C.MessageFrame>();
    C.MessageFrame messageFrame = messageFrameValuePtr.ref;
    C.SPAT cSpat = messageFrame.value.choice.SPAT;

    Spat spat = Spat.fromC(cSpat);

    return spat;
  }

  TravelerInformation parseTim(Pointer<Pointer<Void>> message) {
    Pointer<C.MessageFrame> messageFrameValuePtr = message.value.cast<C.MessageFrame>();
    C.MessageFrame messageFrame = messageFrameValuePtr.ref;
    C.TravelerInformation cTim = messageFrame.value.choice.TravelerInformation;

    TravelerInformation tim = TravelerInformation.fromC(cTim);

    return tim;
  }

  PersonalSafetyMessage parsePSM(Pointer<Pointer<Void>> message) {
    Pointer<C.MessageFrame> messageFrameValuePtr = message.value.cast<C.MessageFrame>();
    C.MessageFrame messageFrame = messageFrameValuePtr.ref;
    C.PersonalSafetyMessage cPsm = messageFrame.value.choice.PersonalSafetyMessage;

    PersonalSafetyMessage psm = PersonalSafetyMessage.fromC(cPsm);

    return psm;
  }

  SensorDataSharingMessage parseSdsm(Pointer<Pointer<Void>> message) {
    Pointer<C.MessageFrame> messageFrameValuePtr = message.value.cast<C.MessageFrame>();
    C.MessageFrame messageFrame = messageFrameValuePtr.ref;
    C.SensorDataSharingMessage cSdsm = messageFrame.value.choice.SensorDataSharingMessage;

    SensorDataSharingMessage sdsm = SensorDataSharingMessage.fromC(cSdsm);

    return sdsm;
  }

  TollAdvertisementMessage parseTam(Pointer<Pointer<Void>> message) {
    Pointer<C.MessageFrame> messageFrameValuePtr = message.value.cast<C.MessageFrame>();
    C.MessageFrame messageFrame = messageFrameValuePtr.ref;
    C.TollAdvertisementMessage cTam = messageFrame.value.choice.TollAdvertisementMessage;
    TollAdvertisementMessage tam = TollAdvertisementMessage.fromC(cTam);
    return tam;
  }

  TollUsageMessage parseTum(Pointer<Pointer<Void>> message) {
    Pointer<C.MessageFrame> messageFrameValuePtr = message.value.cast<C.MessageFrame>();
    C.MessageFrame messageFrame = messageFrameValuePtr.ref;
    C.TollUsageMessage cTum = messageFrame.value.choice.TollUsageMessage;
    TollUsageMessage tum = TollUsageMessage.fromC(cTum);
    tum.encryptedTumData.tumData = decodeTumData(tum.encryptedTumData.encryptedTumData);
    return tum;
  }

  TumData parseTumData(Pointer<Pointer<Void>> message) {
    Pointer<C.TumData> tumDataValuePtr = message.value.cast<C.TumData>();
    C.TumData c_tumData = tumDataValuePtr.ref;
    TumData tumData = TumData.fromC(c_tumData);
    return tumData;
  }

  TollUsageAckMessage parseTumAck(Pointer<Pointer<Void>> message) {
    Pointer<C.MessageFrame> messageFrameValuePtr = message.value.cast<C.MessageFrame>();
    C.MessageFrame messageFrame = messageFrameValuePtr.ref;
    C.TollUsageAckMessage cTumAck = messageFrame.value.choice.TollUsageAckMessage;
    TollUsageAckMessage tumAck = TollUsageAckMessage.fromC(cTumAck);
    return tumAck;
  }

  BasicSafetyMessage decodeBsm(String asn1) {
    Pointer<Pointer<Void>> decoded = decode(asn1);

    BasicSafetyMessage bsm = parseBSM(decoded);

    cleanupDecoded(decoded);

    return bsm;
  }

  MapData decodeMap(String asn1) {
    Pointer<Pointer<Void>> decoded = decode(asn1);

    MapData map = parseMap(decoded);

    cleanupDecoded(decoded);

    return map;
  }

  Spat decodeSpat(String asn1) {
    Pointer<Pointer<Void>> decoded = decode(asn1);

    Spat spat = parseSpat(decoded);

    cleanupDecoded(decoded);

    return spat;
  }

  TravelerInformation decodeTim(String asn1) {
    Pointer<Pointer<Void>> decoded = decode(asn1);

    TravelerInformation tim = parseTim(decoded);

    cleanupDecoded(decoded);

    return tim;
  }

  PersonalSafetyMessage decodePsm(String asn1) {
    Pointer<Pointer<Void>> decoded = decode(asn1);

    PersonalSafetyMessage psm = parsePSM(decoded);

    cleanupDecoded(decoded);

    return psm;
  }

  SensorDataSharingMessage decodeSdsm(String asn1) {
    Pointer<Pointer<Void>> decoded = decode(asn1);

    SensorDataSharingMessage sdsm = parseSdsm(decoded);

    cleanupDecoded(decoded);

    return sdsm;
  }

  TollAdvertisementMessage decodeTam(String asn1) {
    Pointer<Pointer<Void>> decoded = decode(asn1);

    TollAdvertisementMessage tam = parseTam(decoded);

    cleanupDecoded(decoded);

    return tam;
  }

  TollUsageMessage decodeTum(String asn1) {
    Pointer<Pointer<Void>> decoded = decode(asn1);
    TollUsageMessage tum = parseTum(decoded);
    cleanupDecoded(decoded);

    return tum;
  }

  TollUsageAckMessage decodeTumAck(String asn1) {
    Pointer<Pointer<Void>> decoded = decode(asn1);

    TollUsageAckMessage tumAck = parseTumAck(decoded);

    cleanupDecoded(decoded);

    return tumAck;
  }

  TumData decodeTumData(String asn1) {
    Pointer<Pointer<Void>> decoded = c_decodeTumData(asn1);
    TumData tumData = parseTumData(decoded);
    cleanupDecoded(decoded);
    return tumData;
  }

  void cleanupDecoded(Pointer<Pointer<Void>> decoded) {
    calloc.free(decoded.value);
    calloc.free(decoded);
  }

  Pointer<Pointer<Void>> decode(String hexInput) {

    Pointer<C.MessageFrame> structPtr = calloc<C.MessageFrame>();

    Pointer<Pointer<Void>> ptrToPtr = calloc<Pointer<Void>>();
    ptrToPtr.value = structPtr.cast<Void>();

    try {
      Pointer<C.asn_codec_ctx_s> optCodecCtxPtr = calloc<C.asn_codec_ctx_s>();
      optCodecCtxPtr.ref.max_stack_size = 0;

      Pointer<C.asn_TYPE_descriptor_s> typeDescriptorPtr = calloc<C.asn_TYPE_descriptor_s>();
      typeDescriptorPtr.ref = _bindings.asn_DEF_MessageFrame;


      Uint8List byteList = hexToBytes(hexInput);

      Pointer<Uint8> dataPtr = malloc.allocate<Uint8>(byteList.length);
    
      Uint8List dataBuffer = dataPtr.asTypedList(byteList.length);
      dataBuffer.setAll(0, byteList);

      Pointer<Void> bufferPtr = dataPtr.cast<Void>();

      int size = hexInput.length ~/ 2;

      C.asn_dec_rval_s rval = _bindings.uper_decode(optCodecCtxPtr, typeDescriptorPtr, ptrToPtr, bufferPtr, size, 0, 0);

      if (rval.code != 0) {
        loggingService.showWarning("DECODE: Failed to Decode Message ${hexInput}");
      }

      calloc.free(optCodecCtxPtr);
      calloc.free(typeDescriptorPtr);
      calloc.free(dataPtr);
    } catch (e) {
      // No specified type, handles all
      loggingService.showError("Unknown Failure during decoding: $e, $hexInput");
    }

    return ptrToPtr;
  }

  Pointer<Pointer<Void>> c_decodeTumData(String hexInput) {

    Pointer<C.TumData> structPtr = calloc<C.TumData>();

    Pointer<Pointer<Void>> ptrToPtr = calloc<Pointer<Void>>();
    ptrToPtr.value = structPtr.cast<Void>();

    try {
      Pointer<C.asn_codec_ctx_s> optCodecCtxPtr = calloc<C.asn_codec_ctx_s>();
      optCodecCtxPtr.ref.max_stack_size = 0;

      Pointer<C.asn_TYPE_descriptor_s> typeDescriptorPtr = calloc<C.asn_TYPE_descriptor_s>();
      typeDescriptorPtr.ref = _bindings.asn_DEF_TumData;

      Uint8List byteList = hexToBytes(hexInput);

      Pointer<Uint8> dataPtr = malloc.allocate<Uint8>(byteList.length);
    
      Uint8List dataBuffer = dataPtr.asTypedList(byteList.length);
      dataBuffer.setAll(0, byteList);

      Pointer<Void> bufferPtr = dataPtr.cast<Void>();

      int size = hexInput.length ~/ 2;

      C.asn_dec_rval_s rval = _bindings.uper_decode(optCodecCtxPtr, typeDescriptorPtr, ptrToPtr, bufferPtr, size, 0, 0);

      if (rval.code != 0) {
        loggingService.showWarning("Failed to Decode Message ${hexInput}");
      }

      calloc.free(optCodecCtxPtr);
      calloc.free(typeDescriptorPtr);
      calloc.free(dataPtr);
    } catch (e) {
      // No specified type, handles all
      loggingService.showError("Exception during decode: $e");
    }

    return ptrToPtr;
  }


  String encode(Pointer<Pointer<Void>> structPtr, {int encodeBufferSize = 1024}) {
    encodeBufferSize = this.encodeBufferSize;

    // Setup Required Parameter Pointers
    Pointer<C.asn_codec_ctx_s> optCodecCtxPtr = calloc<C.asn_codec_ctx_s>();
    optCodecCtxPtr.ref.max_stack_size = 0;

    Pointer<C.asn_TYPE_descriptor_s> typeDescriptorPtr = calloc<C.asn_TYPE_descriptor_s>();
    typeDescriptorPtr.ref = _bindings.asn_DEF_MessageFrame;
    Pointer<Uint8> buffer = calloc<Uint8>(encodeBufferSize);
    // Encode Data To Buffer
    C.asn_enc_rval_t rval = _bindings.asn_encode_to_buffer(
        optCodecCtxPtr,
        C.asn_transfer_syntax.ATS_UNALIGNED_BASIC_PER,
        typeDescriptorPtr,
        structPtr.value,
        buffer.cast<Void>(),
        encodeBufferSize);
    if (rval.encoded < 0) {
      return "";
    }
    // Convert Encoded Data to Hexadecimal Bytes
    Uint8List encodedBinary = buffer.asTypedList(rval.encoded);
    String hexData = bytesToHex(encodedBinary);

    // Cleanup Pointer Allocations
    calloc.free(optCodecCtxPtr);
    calloc.free(typeDescriptorPtr);
    calloc.free(buffer);
    return hexData;
  }

  String encodeTumData(Pointer<Pointer<Void>> structPtr, {int encodeBufferSize = 1024}) {
    encodeBufferSize = this.encodeBufferSize;

    // Setup Required Parameter Pointers
    Pointer<C.asn_codec_ctx_s> optCodecCtxPtr = calloc<C.asn_codec_ctx_s>();
    optCodecCtxPtr.ref.max_stack_size = 0;

    Pointer<C.asn_TYPE_descriptor_s> typeDescriptorPtr = calloc<C.asn_TYPE_descriptor_s>();
    typeDescriptorPtr.ref = _bindings.asn_DEF_TumData; 
    Pointer<Uint8> buffer = calloc<Uint8>(encodeBufferSize);

    // Encode Data To Buffer
    C.asn_enc_rval_t rval = _bindings.asn_encode_to_buffer(
        optCodecCtxPtr,
        C.asn_transfer_syntax.ATS_UNALIGNED_BASIC_PER,
        typeDescriptorPtr,
        structPtr.value,
        buffer.cast<Void>(),
        encodeBufferSize);

    
    if (rval.encoded < 0) {
      loggingService.showError("Failed to encode TumData: $e");
      return "";
    }

    // Convert Encoded Data to Hexadecimal Bytes
    Uint8List encodedBinary = buffer.asTypedList(rval.encoded);
    String hexData = bytesToHex(encodedBinary);

    // Cleanup Pointer Allocations
    calloc.free(optCodecCtxPtr);
    calloc.free(typeDescriptorPtr);
    calloc.free(buffer);
    return hexData;
  }

  // Hex to Bytes function makes sure to properly join characters when joining. This is different from UTF8.encode() which treats each character as an ascii code.
  // For example Hex to Bytes converts F0 to 11110000
  // UTF.encode() converts F0 to 0100011000110000
  static Uint8List hexToBytes(String hex) {
    if (hex.length % 2 != 0) {
      throw const FormatException('Invalid hexadecimal string');
    }
    final length = hex.length ~/ 2;
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      final hexByte = hex.substring(i * 2, i * 2 + 2);
      final byte = int.parse(hexByte, radix: 16);
      bytes[i] = byte;
    }
    return bytes;
  }

  // Bytes to Hex Function makes
  static String bytesToHex(List<int> bytes) {
    final StringBuffer buffer = StringBuffer();
    for (int byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString().toUpperCase(); // Convert to uppercase if needed
  }
}