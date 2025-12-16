# CV_MEC

This folder contains the source code for building out the CV_MEC mobile application. The Mobile application is built using flutter and currently supports both Android and IOS. If you are just trying to get a copy of this application for testing, please consider downloading the app from the google play store instead.

## Getting Started

This project is a starting point for a Flutter application. If you have not yet setup a development environment for flutter please read below for the required programs and recommended installation strategies. After setting up an environment perform the following

### Make sure flutter is setup correctly

To Start run:

```
flutter doctor
```

### Flutter version compatibility

As of November 2025, the CV-MEC application has been updated to build with Java 21 and Android Ladybug. It requires the following to build properly

Flutter
- Flutter 3.35
- Dart 3.9.2

Android
- Java 21
- Gradle 8

IOS
- Swift 6
- Xcode 26

### Setup ENV file

This application requires multiple environment variables in order to connect to the partner API. Before building the application, copy the sample.env file to .env and provide values for the following variables.

```
cp sample.env .env
```

| Variable              | Purpose                                                           | Default Value | Required | Changeable in App|
| :-------------------- | :---------------------------------------------------------------- | :------------ | -------- | -------- |
| NOAA_GEOMAG_API_TOKEN | Allow the App to query current magnetic offsets                   | zNEw7         | Yes      | No |
| MAPBOX_ACCESS_TOKEN   | Required for Rendering MAP tiles. Acquired from MapBox account    |               | Yes      | No |
| API_ENDPOINT          | Location of the CV-MEC partner API.                               |               | Yes      | Yes |
| USERNAME              | Username for the app to login to the partner API with             |               | Yes      | Yes |
| PASSWORD              | Password for the app to login to the partner API with             |               | Yes      | Yes |
| S3_ACCESS_KEY         | An AWS IAM access key for connecting to an S3 Bucket              |               | No       | No |
| S3_SECRET_KEY         | An AWS IAM secret Key for connecting to an S3 Bucket              |               | No       | No |
| S3_BUCKET_NAME        | The Name of the S3 Bucket to offload log files to                 |               | No       | No |
| S3_REGION             | The AWS region hosting the S3 Bucket and IAM credentials          |               | No       | No |
| S3_DESTINATION        | A subfolder within the Bucket to Place Log files                  |               | No       | No |
| PC5_MQTT_BROKER       | Ettifos OBU Server location. Should be formatted as mqtt://<hostname>:1883 | | No | Yes |
| GPS_TYPE              | Specifies the default GPS type to use within the app, valid values: mobile, obu, cradle | | No | Yes |
| GPS_USERNAME | If using a remote GPS (Cradlepoint), username to use when connecting | | No | Yes |
| GPS_PASSWORD | If using a remote GPS (Cradlepoint), password to use when connecting | | No | Yes |
| GPS_IP | If using a remote GPS (Cradlepoint), the IP address of the GPSD server | | No | Yes |
| OBU_IP | If using an OBU GPS (Ettifos), the IP address of the OBU | | No |  Yes |
| ISS_SCMS_TOKEN | Token for SCMS if signing is enabled. Will automatically enable signing if set | | No | Yes |
| BROADCAST_RATE | Number of messages to broadcast each second. Value must be between 1 and 10 (inclusive) | 10 | No | Yes |


The NOAA_GEOMAG_API_TOKEN included in the sample.env file is currently set to the publically available token specified on the NOAA site. This doesn't need to be changed at this time. For more information on this service please see the NOAA site here:
https://www.ncei.noaa.gov/maps/historical-declination/



### Download Dependencies

```
flutter pub clean
flutter pub get
```

*For IOS please reference the [Additional Instructions for IOS](#building-on-ios)

### Run the app

```
flutter run
```

## Development Environment (Windows)

Video tutorial for all described steps: https://www.youtube.com/playlist?list=PL__UlMMmv_rzDm5i-_HXiQ5YoQKsyurfA

You will need the following software packages:

- Flutter
- Android Studio
- VS Code

### Flutter

[Flutter Download](https://docs.flutter.dev/get-started/install/windows)

Must be installed and added to system path
You can test your installation by running the following command in powershell:

```
flutter
```

It should print a large page of white text. If it fails, it will print red text, likely starting with: flutter : The term 'flutter' is not recognized as the name of a cmdlet, function, script file, or operable program.
this means that you did not add it to your system path correctly, or you just need to close and restart powershell

### Android Studio

[Android Studio Download](https://developer.android.com/studio/install)

Must be installed, and you must be able to use the AVD manager to [launch/manage emulated android devices](https://developer.android.com/studio/run/emulator)

### VS Code

[VS Code Download](https://code.visualstudio.com/download)

You must install VS code, and add the [flutter extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter#:~:text=This%20VS%20Code%20extension%20adds,menu%20for%20full%20debugging%20functionality.)

### Flutter FFI and Native Sources

Note, the required binding files from this procedure have already been generated and are stored in the github repository. Users interested in only building the application do not need to perform these steps. Users who need to update the ASN.1 bindings will need to perform these steps.

This application utilizes the same ASN.1 C compiler used by the JPO-ODE and other connected vehicle applications. This is done by taking the pre-generated ASN.1 C code and calling it using the Flutter foreign function interface. The pre generated ASN.1 tar file can be downloaded [here](https://github.com/usdot-jpo-ode/asn1_codec/tree/develop/asn1c_combined/generated-files). Binding against the FFI This process can be done manually, or by using the included dockerfile to automatically build out these sources. For simplicity, it is recommended to use the docker builder for this procedure, as this process has many dependencies. To generate the required build files run the following

```
cd asn1_plugin
docker build --target=ffi --output type=local,dest=lib,source=generated_bindings.dart --output type=local,dest=src/,source=generated-files/2024 .
```


### Building on IOS
In addition to the steps required to build the base project there are a number of additional steps necessary for building the CV-MEC application. First perform the standard package installation (same for both Android and IOS)
```
cd cv_mec
flutter pub get
```

This project uses cocoapods for external package management for ios. Running `flutter pub get` only sets up the external dependencies. It doesn't fully install them. To install these complete perform the following
```
cd cv_mec/ios
pod install
```

This step will download all of the dependent cocoapods and install them in the IOS project. 

*Cleaning Package*
To clean the IOS build system make sure to perform the following
```
cd cv_mec
flutter clean
cd cv_mec/ios
pod deintegrate
```

Additionally, the IOS SCMS package stores additional dependencies locally. Delete the cached versions by removing the cv_mec/package/iss_scms/ios/Frameworks folder

