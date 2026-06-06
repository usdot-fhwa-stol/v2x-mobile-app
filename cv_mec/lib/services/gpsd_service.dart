import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class GPSDService extends GetxService {
  final Logger _logger = Logger();
  final StreamController<Position> locationStream = StreamController<Position>.broadcast();
  static const Duration _reconnectDelay = Duration(seconds: 3);

  Socket? _socket;
  Timer? _reconnectTimer;
  String? _host;
  int? _port;
  bool _isConnecting = false;
  bool _shouldReconnect = false;

  void connectToGPSD(String host, int port) {
    _host = host;
    _port = port;
    _shouldReconnect = true;
    _connect();
  }

  Future<void> _connect() async {
    if (_isConnecting) return;
    if (_socket != null) return;
    if (_host == null || _port == null) return;

    _isConnecting = true;
    try {
      final socket = await Socket.connect(_host!, _port!);
      _socket = socket;
      _reconnectTimer?.cancel();

      // Send GPSD WATCH command
      socket.write('?WATCH={"enable":true,"json":true};\n');


      // Listen for incoming GPS data
      socket.listen((data) {

        // HTTP Socket Data comes in as a stream, not as individual records. 
        // In the event that the data array contains more than 1 JSON object, only parse the last one.
        String textData = String.fromCharCodes(data);
        int startIndex = textData.lastIndexOf("{");
        int endIndex = textData.lastIndexOf("}");

        String lastRecord = textData.substring(startIndex, endIndex + 1);
        textData = textData.replaceAll("\r",'');
        try{
          Map<String,dynamic> jsonData = json.decode(lastRecord);

          if(jsonData.containsKey("lat")){ // Sometimes the GPS forwards a control packet that doesn't contain any other data
            locationStream.sink.add(Position(
            latitude: jsonData["lat"],
            longitude: jsonData["lon"],
            timestamp: DateTime.tryParse(jsonData["time"]) ?? DateTime.now(),
            accuracy: jsonData["eph"], // Estimated Position Error Horizontal
            altitude: jsonData["altHAE"], // Altitude Height Above Ellipsoid
            speed: jsonData["speed"], // Speed in m/s
            heading: jsonData["track"], 
            altitudeAccuracy: jsonData["epv"], // Estimated Position Error Vertical
            headingAccuracy: jsonData["epc"], // Estimated Course Error
            speedAccuracy: jsonData["eps"], // Estimated Speed Error
            ));
          }
            
        }catch (e) {
          _logger.e("Error parsing GPSD data: $e $textData");
        }
        
      }, onDone: () {
        _logger.w('GPSD socket closed. Scheduling reconnect.');
        _handleDisconnect();
      }, onError: (Object error) {
        _logger.e('GPSD socket error: $error');
        _handleDisconnect();
      }, cancelOnError: true);

    } catch (e) {
      _logger.e('Error connecting to GPSD: $e');
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  void _handleDisconnect() {
    _socket?.destroy();
    _socket = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;
    if (_reconnectTimer?.isActive ?? false) return;

    _reconnectTimer = Timer(_reconnectDelay, () {
      _connect();
    });
  }

  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _socket?.close();
    _socket?.destroy();
    _socket = null;
  }

  @override
  void onClose() {
    disconnect();
    locationStream.close();
    super.onClose();
  }
}
