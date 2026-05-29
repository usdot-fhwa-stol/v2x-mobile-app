import 'dart:math';

import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyBaseURI = 'baseuri';
  static const _keyVzMode = "vzMode";
  static const _keyDeviceID = "deviceid";
  static const _keyNotificationsEnabled = "notificationsEnabled";
  static const _keyReadMessages = "readMessages";
  static const _keyDemoMode = "demoMode";
  static const _keyDeveloperMode = "developerMode";
  static const _keySoundEffectsEnabled = "soundEffectsEnabled";
  static const _keyGPSUsername = 'gpsUsername';
  static const _keyGPSPassword = 'gpsPassword';
  static const _keyGPSIP = 'gpsIP';
  static const _keyGPSType = 'gpsType';
  static const _keyOBUIP = 'obuIP';
  static const _keyPathToFollow = 'pathToFollow';
  static const _keyStaticGPSLatitude = 'staticGPSLatitude';
  static const _keyStaticGPSLongitude = 'staticGPSLongitude';
  static const _keyManualRegistrationMode = "manualRegistrationMode";
  static const _keyRegistrationLatitude = "registrationLatitude";
  static const _keyRegistrationLongitude = "registrationLongitude";
  static const _keyBroadcastRate = "broadcastRate";
  static const _keyISSMqttBrokerUrl = "issMqttBrokerUrl";

  static const _keyS3Accesskey = "s3AccessKey";
  static const _keyS3SecretKey = "s3SecretKey";
  static const _keyS3BucketName = "s3BucketName";
  static const _keyS3Region = "s3Region";
  static const _keyS3DestDir = "s3DestDir";

  static const _keyPC5BrokerUrl = "pc5BrokerUrl";
  static const _keyEnablePC5 = "enablePC5";

  static const _keyEnableIssSigning = "enableIssSigning";
  static const _keyIssScmsToken = "issScmsToken";

  static const _keyEnableIssMqtt = "enableIssMqtt";
  static const _keyEnableEtxMqtt = "enableEtxMqtt";

  static const _keyTollingEnabled = "tollingEnabled";
  static const _keyShowTims = "showTims";

  static const _keyDisableTUMRetry = "disableTUMRetry";

  static final _startBaseURI = dotenv.env['API_ENDPOINT']!;
  static final _startISSMqttBrokerUrl = dotenv.env['ISS_MQTT_BROKER'] ?? "";
  static final _startDeviceID = "";

  static final _startVzMode = false;
  static final _startNotificationsEnabled = false;
  static final _startReadMessages = false;
  static final _startDemoMode = false;
  static final _startDeveloperMode = false;
  static final _startEnableSoundEffects = false;
  static final _startEnablePC5 = false;
  static final _startEnableIssMqtt = true;
  static final _startEnableEtxMqtt = true;
  static final _startIssScmsSigningEnabled = dotenv.env['ISS_SCMS_TOKEN'] != null ? true : false;
  static final _startBroadcastRate = dotenv.env["BROADCAST_RATE"] != null ? min(10, max(1, int.tryParse(dotenv.env['BROADCAST_RATE']!)??10)) : 10;

  static final _startGPSType = dotenv.env['GPS_TYPE'] ?? '';
  static final _startStaticGPSLatitude = dotenv.env['STATIC_GPS_LATITUDE'] ?? '0.0';
  static final _startStaticGPSLongitude = dotenv.env['STATIC_GPS_LONGITUDE'] ?? '0.0';
  static final _startGPSUsername = dotenv.env['GPS_USERNAME'] ?? '';
  static final _startGPSPassword = dotenv.env['GPS_PASSWORD'] ?? '';
  static final _startGPSIP = dotenv.env['GPS_IP'] ?? '';
  static final _startOBUIP = dotenv.env['OBU_IP'] ?? '';
  static final _startPathToFollow = '';

  static final _startTollingEnabled = dotenv.env['TOLLING_ENABLED'] != null ? (dotenv.env['TOLLING_ENABLED']!.toLowerCase() == 'true') : true;
  static final _startShowTims = dotenv.env['SHOW_TIMS'] != null ? (dotenv.env['SHOW_TIMS']!.toLowerCase() == 'true') : true;

  static final _startDisableTUMRetry = dotenv.env['DISABLE_TUM_RETRY'] != null ? (dotenv.env['DISABLE_TUM_RETRY']!.toLowerCase() == 'true') : false;

  static final _startS3AccessKey = dotenv.env['S3_ACCESS_KEY'] ?? "";
  static final _startS3SecretKey = dotenv.env['S3_SECRET_KEY'] ?? "";
  static final _startS3BucketName = dotenv.env['S3_BUCKET_NAME'] ?? "";
  static final _startS3Region = dotenv.env['S3_REGION'] ?? "";
  static final _startS3DestDir = dotenv.env['S3_DESTINATION'] ?? "";

  static final _pc5BrokerUrl = dotenv.env['PC5_MQTT_BROKER'] ?? "";
  static final _issScmsToken = dotenv.env['ISS_SCMS_TOKEN'] ?? "";

  Future<String> getBaseURI() async => await _storage.read(key: _keyBaseURI) ?? _startBaseURI;
  Future<String> getDeviceID() async => await _storage.read(key: _keyDeviceID) ?? _startDeviceID;
  Future<String> getPC5BrokerUrl() async => await _storage.read(key: _keyPC5BrokerUrl) ?? _pc5BrokerUrl;
  Future<String> getIssScmsToken() async => await _storage.read(key: _keyIssScmsToken) ?? _issScmsToken;
  Future<String> getISSMqttBrokerUrl() async => await _storage.read(key: _keyISSMqttBrokerUrl) ?? _startISSMqttBrokerUrl;
  Future<bool> getVZMode() async => (await _storage.read(key: _keyVzMode) ?? _startVzMode.toString()) == "true";
  Future<bool> getNotificationsEnabled() async => (await _storage.read(key: _keyNotificationsEnabled)?? _startNotificationsEnabled.toString()) == "true";
  Future<bool> getReadMessages() async => (await _storage.read(key: _keyReadMessages)?? _startReadMessages.toString()) == "true";
  Future<bool> getDemoMode() async => (await _storage.read(key: _keyDemoMode) ?? _startDemoMode.toString()) == "true";
  Future<bool> getDeveloperMode() async => (await _storage.read(key: _keyDeveloperMode), _startDeveloperMode) == "true";
  Future<bool> getSoundEffectsEnabled() async => (await _storage.read(key: _keySoundEffectsEnabled)?? _startEnableSoundEffects.toString()) == "true";
  Future<bool> getPC5Enabled() async => (await _storage.read(key: _keyEnablePC5)??_startEnablePC5.toString()) == "true";
  Future<bool> getISSMqttEnabled() async => (await _storage.read(key: _keyEnableIssMqtt)??_startEnableIssMqtt.toString()) == "true";
  Future<bool> getEtxMqttEnabled() async => (await _storage.read(key: _keyEnableEtxMqtt)?? _startEnableEtxMqtt.toString()) == "true";
  Future<bool> getIssScmsSigningEnabled() async => (await _storage.read(key: _keyEnableIssSigning)?? _startIssScmsSigningEnabled.toString()) == "true";
  Future<String> getGPSUsername() async => (await _storage.read(key: _keyGPSUsername)) ?? _startGPSUsername;
  Future<String> getGPSPassword() async => (await _storage.read(key: _keyGPSPassword)) ?? _startGPSPassword;
  Future<String> getGPSIP() async => (await _storage.read(key: _keyGPSIP)) ?? _startGPSIP;
  Future<String> getOBUIP() async => (await _storage.read(key: _keyOBUIP)) ?? _startOBUIP;
  Future<String> getPathToFollow() async => (await _storage.read(key: _keyPathToFollow)) ?? _startPathToFollow;
  Future<double> getStaticGPSLatitude() async => double.tryParse(await _storage.read(key: _keyStaticGPSLatitude) ?? _startStaticGPSLatitude) ?? 0.0;
  Future<double> getStaticGPSLongitude() async => double.tryParse(await _storage.read(key: _keyStaticGPSLongitude) ?? _startStaticGPSLongitude) ?? 0.0;
  Future<String> getGPSType() async => (await _storage.read(key: _keyGPSType)) ?? _startGPSType;
  Future<bool> getManualRegistrationMode() async =>
      (await _storage.read(key: _keyManualRegistrationMode)) == 'true';
  Future<double> getRegistrationLatitude() async =>
      double.tryParse(await _storage.read(key: _keyRegistrationLatitude) ?? "0.0") ?? 0.0;
  Future<double> getRegistrationLongitude() async =>
      double.tryParse(await _storage.read(key: _keyRegistrationLongitude) ?? "0.0") ?? 0.0;
  Future<int> getBroadcastRate() async =>
      int.tryParse(await _storage.read(key: _keyBroadcastRate) ?? _startBroadcastRate.toString()) ?? 0;
  Future<bool> getTollingEnabled() async => (await _storage.read(key: _keyTollingEnabled) ?? _startTollingEnabled.toString()) == "true";
  Future<bool> getShowTims() async => (await _storage.read(key: _keyShowTims) ?? _startShowTims.toString()) == "true";
  Future<bool> getDisableTUMRetry() async => (await _storage.read(key: _keyDisableTUMRetry) ?? _startDisableTUMRetry.toString()) == "true";

  Future<void> setBaseURI(String baseURI) async => await _storage.write(key: _keyBaseURI, value: baseURI);
  Future<void> setDeviceID(String deviceID) async => await _storage.write(key: _keyDeviceID, value: deviceID);
  Future<void> setPC5BrokerUrl(String pc5BrokerUrl) async => await _storage.write(key: _keyPC5BrokerUrl, value: pc5BrokerUrl);
  Future<void> setISSMqttBrokerUrl(String issMqttBrokerUrl) async => await _storage.write(key: _keyISSMqttBrokerUrl, value: issMqttBrokerUrl);
  Future<void> setIssScmsToken(String issScmsToken) async => await _storage.write(key: _keyIssScmsToken, value: issScmsToken);
  Future<void> setGPSUsername(String v) => _storage.write(key: _keyGPSUsername, value: v);
  Future<void> setGPSPassword(String v) => _storage.write(key: _keyGPSPassword, value: v);
  Future<void> setGPSIP(String v) => _storage.write(key: _keyGPSIP, value: v);
  Future<void> setOBUIP(String v) => _storage.write(key: _keyOBUIP, value: v);
  Future<void> setPathToFollow(String v) => _storage.write(key: _keyPathToFollow, value: v);
  Future<void> setStaticGPSLatitude(double latitude) async => await _storage.write(key: _keyStaticGPSLatitude, value: latitude.toString());
  Future<void> setStaticGPSLongitude(double longitude) async => await _storage.write(key: _keyStaticGPSLongitude, value: longitude.toString());
  Future<void> setGPSType(GPSType gpsType) async => 
      await _storage.write(key: _keyGPSType, value: gpsType.toString().split('.').last);
  Future<void> setBroadcastRate(int broadcastRate) async => await _storage.write(key: _keyBroadcastRate, value: broadcastRate.toString());
  Future setVZMode(bool vzMode) async {
    if (vzMode) {
      await _storage.write(key: _keyVzMode, value: "true");
    } else {
      await _storage.write(key: _keyVzMode, value: "false");
    }
  }

  Future setNotificationsEnabled(bool notificationsEnabled) async {
    if (notificationsEnabled) {
      await _storage.write(key: _keyNotificationsEnabled, value: "true");
    } else {
      await _storage.write(key: _keyNotificationsEnabled, value: "false");
    }
  }

  Future setReadMessages(bool readMessages) async {
    if (readMessages) {
      await _storage.write(key: _keyReadMessages, value: "true");
    } else {
      await _storage.write(key: _keyReadMessages, value: "false");
    }
  }

  Future setDemoMode(bool demoMode) async {
    if (demoMode) {
      await _storage.write(key: _keyDemoMode, value: "true");
    } else {
      await _storage.write(key: _keyDemoMode, value: "false");
    }
  }

  Future setDeveloperMode(bool developerMode) async {
    if (developerMode) {
      await _storage.write(key: _keyDeveloperMode, value: "true");
    } else {
      await _storage.write(key: _keyDeveloperMode, value: "false");
    }
  }

  Future setSoundEffectsEnabled(bool soundEffectsEnabled) async {
    if (soundEffectsEnabled) {
      await _storage.write(key: _keySoundEffectsEnabled, value: "true");
    } else {
      await _storage.write(key: _keySoundEffectsEnabled, value: "false");
    }
  }

  Future setManualRegistrationModeEnabled(bool manualRegistrationModeEnabled) async {
    if (manualRegistrationModeEnabled) {
      await _storage.write(key: _keyManualRegistrationMode, value: "true");
    } else {
      await _storage.write(key: _keyManualRegistrationMode, value: "false");
    }
  }

  Future setRegistrationLatitude(double latitude) async {
    await _storage.write(key: _keyRegistrationLatitude, value: latitude.toString());
  }

  Future setRegistrationLongitude(double longitude) async {
    await _storage.write(key: _keyRegistrationLongitude, value: longitude.toString());
  }

  Future setPC5Enabled(bool pc5Enabled) async {
    if (pc5Enabled) {
      await _storage.write(key: _keyEnablePC5, value: "true");
    } else {
      await _storage.write(key: _keyEnablePC5, value: "false");
    }
  }

  Future setIssMqttEnabled(bool issMqttEnabled) async {
    if (issMqttEnabled) {
      await _storage.write(key: _keyEnableIssMqtt, value: "true");
    } else {
      await _storage.write(key: _keyEnableIssMqtt, value: "false");
    }
  }

  Future setEtxMqttEnabled(bool etxMqttEnabled) async {
    if (etxMqttEnabled) {
      await _storage.write(key: _keyEnableEtxMqtt, value: "true");
    } else {
      await _storage.write(key: _keyEnableEtxMqtt, value: "false");
    }
  }

  Future setIssScmsSigningEnabled(bool issScmsSigning) async {
    if (issScmsSigning) {
      await _storage.write(key: _keyEnableIssSigning, value: "true");
    } else {
      await _storage.write(key: _keyEnableIssSigning, value: "false");
    }
  }


  Future setTollingEnabled(bool tollingEnabled) async {
    if (tollingEnabled) {
      await _storage.write(key: _keyTollingEnabled, value: "true");
    } else {
      await _storage.write(key: _keyTollingEnabled, value: "false");
    }
  }

  Future setShowTims(bool showTims) async {
    if (showTims) {
      await _storage.write(key: _keyShowTims, value: "true");
    } else {
      await _storage.write(key: _keyShowTims, value: "false");
    }
  }

  Future setDisableTUMRetry(bool disableTUMRetry) async {
    if (disableTUMRetry) {
      await _storage.write(key: _keyDisableTUMRetry, value: "true");
    } else {
      await _storage.write(key: _keyDisableTUMRetry, value: "false");
    }
  }

  Future<String> getS3AccessKey() async => await _storage.read(key: _keyS3Accesskey) ?? Future.value(_startS3AccessKey);
  Future<String> getS3SecretKey() async => await _storage.read(key: _keyS3SecretKey) ?? Future.value(_startS3SecretKey);
  Future<String> getS3BucketName() async =>
      await _storage.read(key: _keyS3BucketName) ?? Future.value(_startS3BucketName);
  Future<String> getS3Region() async => await _storage.read(key: _keyS3Region) ?? Future.value(_startS3Region);
  Future<String> getS3DestDir() async => await _storage.read(key: _keyS3DestDir) ?? Future.value(_startS3DestDir);

  Future setS3AccessKey(String s3AccessKey) async => await _storage.write(key: _keyS3Accesskey, value: s3AccessKey);
  Future setS3SecretKey(String s3SecretKey) async => await _storage.write(key: _keyS3SecretKey, value: s3SecretKey);
  Future setS3BucketName(String s3BucketName) async => await _storage.write(key: _keyS3BucketName, value: s3BucketName);
  Future setS3Region(String s3Region) async => await _storage.write(key: _keyS3Region, value: s3Region);
  Future setS3DestDir(String s3DestDir) async => await _storage.write(key: _keyS3DestDir, value: s3DestDir);

}
