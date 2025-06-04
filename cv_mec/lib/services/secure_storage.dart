import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyUsername = 'username';
  static const _keyPassword = 'password';
  static const _keyBaseURI = 'baseuri';
  static const _keyVendorID = 'vendorid';
  static const _keyVzMode = "vzMode";
  static const _keyDeviceID = "deviceid";
  static const _keyNotificationsEnabled = "notificationsEnabled";
  static const _keyReadMessages = "readMessages";
  static const _keyDemoMode = "demoMode";
  static const _keyDeveloperMode = "developerMode";

  static const _keyS3Accesskey = "s3AccessKey";
  static const _keyS3SecretKey = "s3SecretKey";
  static const _keyS3BucketName = "s3BucketName";
  static const _keyS3Region = "s3Region";
  static const _keyS3DestDir = "s3DestDir";

  static final _startUsername = dotenv.env['USERNAME']!;
  static final _startPassword = dotenv.env['PASSWORD']!;
  static final _startBaseURI = dotenv.env['API_ENDPOINT']!;
  static final _startVendorID = dotenv.env['VENDOR_ID']!;
  static final _startDeviceID = "";

  static final _startS3AccessKey = dotenv.env['S3_ACCESS_KEY'] ?? "";
  static final _startS3SecretKey = dotenv.env['S3_SECRET_KEY'] ?? "";
  static final _startS3BucketName = dotenv.env['S3_BUCKET_NAME'] ?? "";
  static final _startS3Region = dotenv.env['S3_REGION'] ?? "";
  static final _startS3DestDir = dotenv.env['S3_DESTINATION'] ?? "";

  Future<String> getUsername() async => await _storage.read(key: _keyUsername) ?? Future.value(_startUsername);
  Future<String> getPassword() async => await _storage.read(key: _keyPassword) ?? Future.value(_startPassword);
  Future<String> getBaseURI() async => await _storage.read(key: _keyBaseURI) ?? Future.value(_startBaseURI);
  Future<String> getVendorID() async => await _storage.read(key: _keyVendorID) ?? Future.value(_startVendorID);
  Future<String> getDeviceID() async => await _storage.read(key: _keyDeviceID) ?? Future.value(_startDeviceID);
  Future<bool> getVZMode() async => (await _storage.read(key: _keyVzMode)) == "true";
  Future<bool> getNotificationsEnabled() async => (await _storage.read(key: _keyNotificationsEnabled)) == "true";
  Future<bool> getReadMessages() async => (await _storage.read(key: _keyReadMessages)) == "true";
  Future<bool> getDemoMode() async => (await _storage.read(key: _keyDemoMode)) == "true";
  Future<bool> getDeveloperMode() async => (await _storage.read(key: _keyDeveloperMode)) == "true";

  Future setUsername(String username) async => await _storage.write(key: _keyUsername, value: username);
  Future setPassword(String password) async => await _storage.write(key: _keyPassword, value: password);
  Future setBaseURI(String baseURI) async => await _storage.write(key: _keyBaseURI, value: baseURI);
  Future setVendorID(String vendorID) async => await _storage.write(key: _keyVendorID, value: vendorID);
  Future setDeviceID(String deviceID) async => await _storage.write(key: _keyDeviceID, value: deviceID);
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
      print("true");
    } else {
      await _storage.write(key: _keyDeveloperMode, value: "false");
      print("false");
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

  //might not need this method
  Future loadSecureStorageData() async {
    if (await _storage.read(key: _keyUsername) == null) {
      await setUsername(_startUsername);
    }
    if (await _storage.read(key: _keyPassword) == null) {
      await setPassword(_startPassword);
    }
  }

  // if adding logout functionality
  Future clear() async {
    await _storage.delete(key: _keyUsername);
    await _storage.delete(key: _keyPassword);
  }
}
