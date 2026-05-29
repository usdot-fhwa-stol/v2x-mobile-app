import 'package:iss_scms/models/expiration_information.dart';
import 'package:iss_scms/models/signing_api_state.dart';
import 'package:iss_scms/models/token_type.dart';
import 'package:iss_scms/models/validate_status.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'iss_scms_method_channel.dart';

abstract class IssScmsPlatform extends PlatformInterface {
  /// Constructs a IssScmsPlatform.
  IssScmsPlatform() : super(token: _token);

  static final Object _token = Object();

  static IssScmsPlatform _instance = MethodChannelIssScms();

  /// The default instance of [IssScmsPlatform] to use.
  ///
  /// Defaults to [MethodChannelIssScms].
  static IssScmsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IssScmsPlatform] when
  /// they register themselves.
  static set instance(IssScmsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  void init(){
    throw UnimplementedError('init() has not been implemented.');
  }

  void clearCache(int clearBeforeUnixTimeSeconds){
    throw UnimplementedError('clearCache(int clearBeforeUnixTimeSeconds) has not been implemented.');
  }

  Future<ValidateStatus> validate(List<int> bytes, bool shouldValidate) {
    throw UnimplementedError('validate(List<int> bytes, bool shouldValidate) has not been implemented.');
  }

  void getDeviceCerts(String token, TokenType type, String deviceId){
    throw UnimplementedError('getDeviceCerts(List<int> bytes, bool shouldValidate) has not been implemented.');
  }

  Future<SigningApiState> getState(){
    throw UnimplementedError('getState() has not been implemented.');
  }

  Future<List<int>?> sign(int psid, List<int> bytes, int? jIndex, bool? digestSigner){
    throw UnimplementedError('sign(List<int> bytes, bool shouldValidate, int? jIndex, bool? digestSigner) has not been implemented.');
  }

  Future<ExpirationInformation> getExpirationInfo(){
    throw UnimplementedError('ExpirationInformation(List<int> bytes, bool shouldValidate, int? jIndex, bool? digestSigner) has not been implemented.');
  }

  void topOffCerts(String token, TokenType tokenType, String deviceId){
    throw UnimplementedError('topOffCerts(String token, TokenType tokenType, String deviceId) has not been implemented.');
  }
}
