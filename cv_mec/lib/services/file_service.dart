import 'dart:io';
import 'dart:convert';
import 'package:cv_mec/models/archive_directory.dart';
import 'package:cv_mec/models/imp/registration.dart';
import 'package:cv_mec/models/vehicle.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class FileService extends GetxService {
  final String registrationFileName = "registration.json";
  File registrationFile = File('');

  Future<bool> checkIfRegistrationExists() async {
    String registrationPath = await _getFilePath(registrationFileName, ArchiveDirectory.DOWNLOADS);
    final file = File(registrationPath);
    return await file.exists();
  }

  Future<void> saveRegistration(Registration registration) async {
    registrationFile = await getFileForWriting(registrationFileName);
    await registrationFile.writeAsString(jsonEncode(registration.toJson()));
  }

  Future<bool> deleteRegistration() async {
    String registrationPath = await _getFilePath(registrationFileName, ArchiveDirectory.DOWNLOADS);

    if (await checkIfRegistrationExists()) {
      File file = File(registrationPath);
      file.delete();
      return true;
    }
    return false;
  }

  Future<Registration> getRegistration() async {
    String path = await _getFilePath(registrationFileName, ArchiveDirectory.DOWNLOADS);
    File file = File(path);
    String jsonData = await file.readAsString();
    Registration registration = Registration.fromJson(jsonDecode(jsonData));
    return registration;
  }

  Future<File> getFileForWriting(String filename) async {
    String path = await _getFilePath(filename, ArchiveDirectory.DOWNLOADS);
    File file = File(path);
    await file.create(recursive: true);
    return file;
  }

  Future<String> getFileApplicationDirectoryPath(String fileName) async {
    Directory directory;
    if (Platform.isAndroid) {
      directory = await getApplicationDocumentsDirectory(); //FOR ANDROID
    } else {
      directory = await getApplicationDocumentsDirectory(); //FOR iOS
    }

    // Create the file path
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    return '${directory.path}/$fileName';
  }

  Future<String> _getDocsDir() async {
    Directory directory;
    if (Platform.isAndroid) {
      directory = await getApplicationDocumentsDirectory(); //FOR ANDROID
    } else {
      directory = await getApplicationDocumentsDirectory(); //FOR iOS
    }
    final path = "${directory.path}/archives";
    return path;
  }

  Future<String?> _getDownloadsDirectory() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getDownloadsDirectory(); //FOR ANDROID
    } else {
      directory = await getApplicationDocumentsDirectory(); //FOR iOS
    }

    if (directory == null) {
      return null;
    }
    final path = "${directory.path}/archives";
    return path;
  }

  Future<String> _getTempDir() async {
    //final directory = await getTemporaryDirectory();
    Directory directory;
    if (Platform.isAndroid) {
      directory = await getTemporaryDirectory();
    } else {
      directory = await getApplicationSupportDirectory(); //FOR iOS
    }
    final path = "${directory.path}/archives";
    return path;
  }

  Future<String> _getDirectory(ArchiveDirectory directory) async {
    switch (directory) {
      case ArchiveDirectory.APPLICATION_DOCUMENTS:
        return _getDocsDir();
      case ArchiveDirectory.DOWNLOADS:
        return await _getDownloadsDirectory() ?? _getDocsDir();
      case ArchiveDirectory.TEMPORARY:
        return _getTempDir();
    }
  }

  Future<String> _getFilePath(String name, ArchiveDirectory directory) async {
    String path = await _getDirectory(directory);
    return '$path/$name';
  }

  Future<List<Vehicle>> getVehicleConfigsfromFile() async {
    List<Vehicle> vehicles = [];
    String path = await _getFilePath("vehicles.json", ArchiveDirectory.DOWNLOADS);
    File file = File(path);
    if (await file.exists()) {
      String jsonData = await file.readAsString();
      List<dynamic> jsonList = jsonDecode(jsonData);
      for (var vehicleJson in jsonList) {
        Vehicle vehicle = Vehicle.fromJson(vehicleJson);
        vehicles.add(vehicle);
      }
    } else {
      // Handle the case where the file does not exist
      print("File does not exist");
    }
    return vehicles;
  }

  Future<void> saveVehicleConfigsToFile(List<Vehicle> vehicles) async {
    String path = await _getFilePath("vehicles.json", ArchiveDirectory.DOWNLOADS);
    File file = File(path);
    List<Map<String, dynamic>> jsonList = vehicles.map((vehicle) => vehicle.toJson()).toList();
    try {
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      if (e is FileSystemException) {
        // If the file doesn't exist, create it and write the data
        await file.create(recursive: true);
        await file.writeAsString(jsonEncode(jsonList));
      } else {
        rethrow; // Rethrow other exceptions
      }
    }
  }
}
