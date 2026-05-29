import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:iss_scms/models/signing_api_state.dart';
import 'package:iss_scms/models/token_type.dart';
import 'package:iss_scms/models/validate_status.dart';

import 'iss_scms_platform_interface.dart';

/// An implementation of [IssScmsPlatform] that uses method channels.
class MethodChannelIssScms extends IssScmsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('iss_scms');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  void init(){
    try{
      methodChannel.invokeMethod<bool>('init');
    } on Exception catch(e){
      print(e);
    }
    
  }

  @override
  Future<List<int>?> sign(int psid, List<int> tbsOer, int? jIndex, bool? digestSigner) async{
    try{
      final signed = await methodChannel.invokeMethod<List<int>?>('sign', {'psid': psid, 'tbsOer': tbsOer, 'jIndex': null, 'digestSigner': null});
      return signed;
    } on Exception catch(e){
      print(e);
      return null;
    }
    
  }

  @override
  void getDeviceCerts(String token, TokenType tokenType, String deviceId){
    try{
      methodChannel.invokeMethod<List<int>?>('getDeviceCerts', {'token': token, 'tokenType': tokenType.index, 'deviceId': deviceId});
    } on PlatformException catch(e){
      print(e);
    }
  }

  @override
  Future<SigningApiState> getState() async {
    try{
      String? signingApiState = await methodChannel.invokeMethod<String?>('getState');
      return enumFromString(signingApiState, SigningApiState.values, SigningApiState.NEED_CERTS);
    } catch(e){
      print(e);
      return SigningApiState.NEED_INIT;
    }
  }

  @override
  Future<ValidateStatus> validate(List<int> bytes, bool shouldValidate) async{
    try{
      
      final Uint8List byteList = Uint8List.fromList(bytes);
      String? valid = await methodChannel.invokeMethod<String?>('validate', {'message': byteList, 'shouldValidate': shouldValidate});
      return enumFromString(valid, ValidateStatus.values, ValidateStatus.FAILURE);
    } catch(e){
      print(e);
      return ValidateStatus.FAILURE;
    }
    
  }

  @override
  void topOffCerts(String token, TokenType tokenType, String deviceId){
    try{
      methodChannel.invokeMethod<List<int>?>('topOffCerts', {'token': token, 'tokenType': tokenType.index, 'deviceId': deviceId});
    } catch(e){
      print(e);
    }
  }

  T enumFromString<T extends Enum>(String? value, List<T> values, T def) {
    try {
      return values.firstWhere((e) => e.name == value);
    } catch (_) {
      return def; // return null if no match
    }
  }
}
