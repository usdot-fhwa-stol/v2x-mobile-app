import 'dart:async';
import 'dart:isolate';

import 'package:asn1_plugin/j2735/2024/basic_safety_message/basic_safety_message.dart';
import 'package:asn1_plugin/j2735/2024/map_data/map_data.dart';
import 'package:asn1_plugin/j2735/2024/personal_safety_message/personal_safety_message.dart';
import 'package:asn1_plugin/j2735/2024/sensor_data_sharing_message/sensor_data_sharing_message.dart';
import 'package:asn1_plugin/j2735/2024/spat/spat.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_information.dart';
import 'package:asn1_plugin/j3217/2022/toll_advertisement_message/toll_advertisement_message.dart';
import 'package:asn1_plugin/j3217/2022/toll_usage_ack_message/toll_usage_ack_message.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:cv_mec/services/asn_service.dart';

class MqttDecodeIsolate {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _workerSendPort;
  int _requestId = 0;
  final Map<int, void Function(Map<String, dynamic>)> _pending = {};

  Future<void> start() async {
    if (_isolate != null) {
      return;
    }

    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_mqttDecodeWorkerEntrypoint, _receivePort!.sendPort);

    final completer = Completer<void>();
    _receivePort!.listen((dynamic message) {
      if (message is SendPort) {
        _workerSendPort = message;
        if (!completer.isCompleted) {
          completer.complete();
        }
        return;
      }

      if (message is Map<String, dynamic>) {
        final id = message['id'];
        if (id is int) {
          final callback = _pending.remove(id);
          if (callback != null) {
            callback(message);
          }
        }
      }
    });

    await completer.future;
  }

  void stop() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _workerSendPort = null;
    _receivePort?.close();
    _receivePort = null;
    _pending.clear();
  }

  Future<void> dispose() async {
    stop();
  }

  bool get isReady => _workerSendPort != null;

  void decodeMessage({
    required String? broker,
    required String topic,
    required List<int> bytes,
    required DateTime recTime,
    required DateTime? sendTime,
    required String source,
    required bool decodeTim,
    required bool decodeTam,
    required void Function(Map<String, dynamic>) onResult,
  }) {
    final sendPort = _workerSendPort;
    if (sendPort == null) {
      return;
    }

    final id = _requestId++;
    _pending[id] = onResult;

    sendPort.send({
      'id': id,
      'broker': broker,
      'topic': topic,
      'bytes': bytes,
      'recTimeMs': recTime.millisecondsSinceEpoch,
      'sendTimeMs': sendTime?.millisecondsSinceEpoch,
      'source': source,
      'decodeTim': decodeTim,
      'decodeTam': decodeTam,
    });
  }
}

void _mqttDecodeWorkerEntrypoint(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  final asnService = ASNService();

  receivePort.listen((dynamic message) {
    if (message is! Map<String, dynamic>) {
      return;
    }

    final int id = message['id'] as int;
    final String? broker = message['broker'] as String?;
    final String topic = message['topic'] as String;
    final List<int> bytes = (message['bytes'] as List<dynamic>).cast<int>();
    final int recTimeMs = message['recTimeMs'] as int;
    final int? sendTimeMs = message['sendTimeMs'] as int?;
    final String source = message['source'] as String;
    final bool decodeTim = message['decodeTim'] as bool? ?? true;
    final bool decodeTam = message['decodeTam'] as bool? ?? true;

    final String hex = ASNService.bytesToHex(bytes);
    final MsgType msgType = asnService.determineHexMessageType(hex);

    String? trimmedHex;
    dynamic decoded;

    try {
      switch (msgType) {
        case MsgType.BSM:
          trimmedHex = asnService.trimMessageHeaders(hex, asnService.BSM_START_FLAG);
          if (trimmedHex != null) {
            decoded = asnService.decodeBsm(trimmedHex);
          }
          break;
        case MsgType.PSM:
          trimmedHex = asnService.trimMessageHeaders(hex, asnService.PSM_START_FLAG);
          if (trimmedHex != null) {
            decoded = asnService.decodePsm(trimmedHex);
          }
          break;
        case MsgType.SPAT:
          trimmedHex = asnService.trimMessageHeaders(hex, asnService.SPAT_START_FLAG);
          if (trimmedHex != null) {
            decoded = asnService.decodeSpat(trimmedHex);
          }
          break;
        case MsgType.MAP:
          trimmedHex = asnService.trimMessageHeaders(hex, asnService.MAP_START_FLAG);
          if (trimmedHex != null) {
            decoded = asnService.decodeMap(trimmedHex);
          }
          break;
        case MsgType.TIM:
          if (decodeTim) {
            trimmedHex = asnService.trimMessageHeaders(hex, asnService.TIM_START_FLAG);
            if (trimmedHex != null) {
              decoded = asnService.decodeTim(trimmedHex);
            }
          }
          break;
        case MsgType.SDSM:
          trimmedHex = asnService.trimMessageHeaders(hex, asnService.SDSM_START_FLAG);
          if (trimmedHex != null) {
            decoded = asnService.decodeSdsm(trimmedHex);
          }
          break;
        case MsgType.TAM:
          if (decodeTam) {
            trimmedHex = asnService.trimMessageHeaders(hex, asnService.TAM_START_FLAG);
            if (trimmedHex != null) {
              decoded = asnService.decodeTam(trimmedHex);
            }
          }
          break;
        case MsgType.TUMACK:
          trimmedHex = asnService.trimMessageHeaders(hex, asnService.TUMACK_START_FLAG);
          if (trimmedHex != null) {
            decoded = asnService.decodeTumAck(trimmedHex);
          }
          break;
        default:
          break;
      }
    } catch (e) {
      mainSendPort.send({
        'id': id,
        'error': e.toString(),
        'msgType': msgType.name,
        'broker': broker,
        'topic': topic,
        'hex': hex,
        'source': source,
        'recTimeMs': recTimeMs,
        'sendTimeMs': sendTimeMs,
      });
      return;
    }

    mainSendPort.send({
      'id': id,
      'msgType': msgType.name,
      'broker': broker,
      'topic': topic,
      'source': source,
      'recTimeMs': recTimeMs,
      'sendTimeMs': sendTimeMs,
      'hex': hex,
      'trimmedHex': trimmedHex,
      'decoded': decoded,
      'decodedType': _decodedTypeName(decoded),
    });
  });
}

String? _decodedTypeName(dynamic decoded) {
  if (decoded is BasicSafetyMessage) {
    return 'BasicSafetyMessage';
  }
  if (decoded is PersonalSafetyMessage) {
    return 'PersonalSafetyMessage';
  }
  if (decoded is Spat) {
    return 'Spat';
  }
  if (decoded is MapData) {
    return 'MapData';
  }
  if (decoded is TravelerInformation) {
    return 'TravelerInformation';
  }
  if (decoded is SensorDataSharingMessage) {
    return 'SensorDataSharingMessage';
  }
  if (decoded is TollAdvertisementMessage) {
    return 'TollAdvertisementMessage';
  }
  if (decoded is TollUsageAckMessage) {
    return 'TollUsageAckMessage';
  }
  return null;
}
