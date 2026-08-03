import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cv_mec/models/augmented_position.dart';
import 'package:cv_mec/models/gps_status.dart';
import 'package:cv_mec/models/gps_type.dart';
import 'package:cv_mec/services/logging_service.dart';
import 'package:get/get.dart';

class GPSDService extends GetxService {
  LoggingService loggingService = Get.find<LoggingService>();
  final StreamController<AugmentedPosition> locationStream = StreamController<AugmentedPosition>.broadcast();
  Socket? _socket;
  StreamSubscription<String>? _gpsdLineSubscription;
  Timer? _reconnectTimer;
  String? _lastHost;
  int? _lastPort;
  bool _shouldReconnect = false;
  bool _isConnecting = false;
  int _reconnectAttempt = 0;
  int _connectionEpoch = 0;

  Map<String, dynamic> parseHostAndPort(String input) {
    final parts = input.split(':');
    if (parts.length >= 2) {
      final host = parts[0];
      final port = int.tryParse(parts[1]);
      if (port != null) {
        return {'host': host, 'port': port};
      }else{
        loggingService.showError("Invalid port number in GPSD connection string: $input. Will use default port 2947 instead.");
        return {'host': host, 'port': 2947};
      }
    }else if(parts.length == 1){
      final host = parts[0];
      return {'host': host, 'port': 2947};
    } 
    return {'host': input, 'port': 2947};
  }

  void connectToGPSD(String host, int port) async {
    _lastHost = host;
    _lastPort = port;
    _shouldReconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    loggingService.addToAppLog("Connecting to GPSD at $host:$port");
    await _connect();
  }

  Future<void> disconnectFromGPSD() async {
    _shouldReconnect = false;
    _reconnectAttempt = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _connectionEpoch += 1;
    await _gpsdLineSubscription?.cancel();
    _gpsdLineSubscription = null;
    await _socket?.close();
    _socket = null;
  }

  Future<void> _connect() async {
    if (_isConnecting || _lastHost == null || _lastPort == null) {
      return;
    }

    _isConnecting = true;
    final int epoch = ++_connectionEpoch;

    try {
      loggingService.addToAppLog("Attempting to connect to GPSD at $_lastHost:$_lastPort");
      await _gpsdLineSubscription?.cancel();
      await _socket?.close();
      _gpsdLineSubscription = null;
      _socket = null;

      final socket = await Socket.connect(_lastHost!, _lastPort!);
      if (epoch != _connectionEpoch) {
        await socket.close();
        return;
      }
      _socket = socket;
      _reconnectAttempt = 0;

      // Send GPSD WATCH command
      _socket!.write('?WATCH={"enable":true,"json":true};\n');

      // GPSD sends newline-delimited JSON objects. Decode by line to avoid
      // parsing partial TCP chunks or losing records when multiple objects
      // arrive in one packet.
      _gpsdLineSubscription = _socket!
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true))
          .transform(const LineSplitter())
          .listen(_handleGpsdLine, onError: (Object e) {
        if (epoch != _connectionEpoch) {
          return;
        }
        loggingService.showError("Error reading GPSD stream: $e");
        _handleUnexpectedClose();
      }, onDone: () {
        if (epoch != _connectionEpoch) {
          return;
        }
        loggingService.showWarning("GPSD socket closed");
        _handleUnexpectedClose();
      });

    } catch (e) {
      if (epoch == _connectionEpoch) {
        loggingService.showError("Error connecting to GPSD: $e");
        _scheduleReconnect();
      }
    } finally {
      _isConnecting = false;
    }
  }

  void _handleUnexpectedClose() {
    _gpsdLineSubscription = null;
    _socket = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect || _lastHost == null || _lastPort == null) {
      return;
    }
    if (_reconnectTimer?.isActive ?? false) {
      return;
    }

    _reconnectAttempt += 1;
    final int exponent = min(_reconnectAttempt - 1, 5);
    final int delaySeconds = min(30, 1 << exponent);
    final Duration delay = Duration(seconds: delaySeconds);

    loggingService.showWarning(
      "GPSD reconnect attempt $_reconnectAttempt scheduled in ${delay.inSeconds}s",
    );

    _reconnectTimer = Timer(delay, () async {
      _reconnectTimer = null;
      await _connect();
    });
  }

  void _handleGpsdLine(String rawLine) {
    final line = rawLine.trim();
    if (line.isEmpty) {
      return;
    }

    dynamic decoded;
    try {
      decoded = json.decode(line);
    } catch (e) {
      loggingService.showWarning("Skipping malformed GPSD JSON line: $e | $line");
      return;
    }

    if (decoded is! Map<String, dynamic>) {
      return;
    }

    final messageClass = decoded['class'];
    if (messageClass != 'TPV') {
      return;
    }

    final latitude = _asDouble(decoded['lat']);
    final longitude = _asDouble(decoded['lon']);
    if (latitude == null || longitude == null) {
      // TPV without a fix is common; ignore until a valid fix arrives.
      return;
    }

    locationStream.sink.add(AugmentedPosition(
      latitude: latitude,
      longitude: longitude,
      timestamp: _parseTime(decoded['time']) ?? DateTime.now(),
      accuracy: _asDouble(decoded['eph']) ?? 0,
      altitude: _asDouble(decoded['altHAE']) ?? _asDouble(decoded['alt']) ?? 0,
      speed: _asDouble(decoded['speed']) ?? 0,
      heading: _asDouble(decoded['track']) ?? 0,
      altitudeAccuracy: _asDouble(decoded['epv']) ?? 0,
      headingAccuracy: _asDouble(decoded['epc']) ?? 0,
      speedAccuracy: _asDouble(decoded['eps']) ?? 0,
      gpsType: GPSType.obu,
      gpsStatus: GPSStatus.fromInt(_asInt(decoded['status']) ?? 0),
    ));
  }

  double? _asDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  int? _asInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  DateTime? _parseTime(dynamic value) {
    if (value is! String) {
      return null;
    }
    return DateTime.tryParse(value);
  }


  void printLongString(String longString) {
    const int chunkSize = 800;
    for (int i = 0; i < longString.length; i += chunkSize) {
      final endIndex = (i + chunkSize < longString.length) ? i + chunkSize : longString.length;
      print(longString.substring(i, endIndex));
    }
  }
}
