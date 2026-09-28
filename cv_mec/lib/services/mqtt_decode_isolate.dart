import 'dart:async';
import 'dart:isolate';

import 'package:cv_mec/models/mqtt_decode_settings.dart';
import 'package:cv_mec/models/msg_types.dart';
import 'package:cv_mec/services/asn_service.dart';


class MqttDecodeIsolate {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _workerSendPort;

  int _requestId = 0;
  final Map<int, void Function(Map<String, dynamic>)> _pending = {};

  Future<void> start({required MqttDecodeSettings decodeSettings}) async {
    if (_isolate != null) {
      return;
    }

    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_mqttDecodeWorkerEntrypoint, {
      'mainSendPort': _receivePort!.sendPort,
      'decodeSettings': decodeSettings.toMap(),
    });

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
    });
  }
}

void _mqttDecodeWorkerEntrypoint(Map<String, dynamic> initialData) {
  final SendPort mainSendPort = initialData['mainSendPort'] as SendPort;
  final Map<String, dynamic> decodeSettingsMap =
      ((initialData['decodeSettings'] as Map?) ?? const <String, dynamic>{})
          .cast<String, dynamic>();
  final MqttDecodeSettings decodeSettings = MqttDecodeSettings.fromMap(decodeSettingsMap);

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

    final String hex = ASNService.bytesToHex(bytes);
    final MsgType msgType = asnService.determineHexMessageType(hex);

    String? trimmedHex;
    dynamic decoded;

    try {
      switch (msgType) {
        case MsgType.BSM:
          if (decodeSettings.enableBSM) {
            trimmedHex = asnService.trimMessageHeaders(hex, asnService.BSM_START_FLAG);
            if (trimmedHex != null) {
              decoded = asnService.decodeBsm(trimmedHex);
            }
          }
          break;
        case MsgType.PSM:
          if (decodeSettings.enablePSM) {
            trimmedHex = asnService.trimMessageHeaders(hex, asnService.PSM_START_FLAG);
            if (trimmedHex != null) {
              decoded = asnService.decodePsm(trimmedHex);
            }
          }
          break;
        case MsgType.SPAT:
          if (decodeSettings.enableSPAT) {
            trimmedHex = asnService.trimMessageHeaders(hex, asnService.SPAT_START_FLAG);
            if (trimmedHex != null) {
              decoded = asnService.decodeSpat(trimmedHex);
            }
          }
          break;
        case MsgType.MAP:
          if (decodeSettings.enableMAP) {
            trimmedHex = asnService.trimMessageHeaders(hex, asnService.MAP_START_FLAG);
            if (trimmedHex != null) {
              decoded = asnService.decodeMap(trimmedHex);
            }
          }
          break;
        case MsgType.TIM:
          if (decodeSettings.enableTIM) {
            trimmedHex = asnService.trimMessageHeaders(hex, asnService.TIM_START_FLAG);
            if (trimmedHex != null) {
              decoded = asnService.decodeTim(trimmedHex);
            }
          }
          break;
        case MsgType.SDSM:
          if (decodeSettings.enableSDSM) {
            trimmedHex = asnService.trimMessageHeaders(hex, asnService.SDSM_START_FLAG);
            if (trimmedHex != null) {
              decoded = asnService.decodeSdsm(trimmedHex);
            }
          }
          break;
        case MsgType.TAM:
          if (decodeSettings.enableTAM) {
            trimmedHex = asnService.trimMessageHeaders(hex, asnService.TAM_START_FLAG);
            if (trimmedHex != null) {
              decoded = asnService.decodeTam(trimmedHex);
            }
          }
          break;
        case MsgType.TUMACK:
          if (decodeSettings.enableTUMACK) {
            trimmedHex = asnService.trimMessageHeaders(hex, asnService.TUMACK_START_FLAG);
            if (trimmedHex != null) {
              decoded = asnService.decodeTumAck(trimmedHex);
            }
          }
          break;
        default:
          mainSendPort.send({
            'id': id,
            'msgType': msgType,
            'broker': broker,
            'topic': topic,
            'source': source,
            'recTimeMs': recTimeMs,
            'sendTimeMs': sendTimeMs,
            'hex': hex,
            'decoded': null,
            'decodedType': null,
          });
          break;
      }
    } catch (e) {
      mainSendPort.send({
        'id': id,
        'error': e.toString(),
        'msgType': msgType,
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
      'msgType': msgType,
      'broker': broker,
      'topic': topic,
      'source': source,
      'recTimeMs': recTimeMs,
      'sendTimeMs': sendTimeMs,
      'hex': trimmedHex,
      'decoded': decoded, 
    });
  });
}
