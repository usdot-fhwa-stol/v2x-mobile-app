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
| VENDOR_ID             | Vendor ID for the partner API                                     |               | No       | No |
| S3_ACCESS_KEY         | An AWS IAM access key for connecting to an S3 Bucket              |               | No       | No |
| S3_SECRET_KEY         | An AWS IAM secret Key for connecting to an S3 Bucket              |               | No       | No |
| S3_BUCKET_NAME        | The Name of the S3 Bucket to offload log files to                 |               | No       | No |
| S3_REGION             | The AWS region hosting the S3 Bucket and IAM credentials          |               | No       | No |
| S3_DESTINATION        | A subfolder within the Bucket to Place Log files                  |               | No       | No |
| ISS_MQTT_BROKER       | ISS MQTT Broker location. Should be formatted as mqtt://<hostname>:1883 | | No | Yes |
| PC5_MQTT_BROKER       | Ettifos OBU Server location. Should be formatted as mqtt://<hostname>:1883 | | No | Yes |
| ENABLE_ISS_BROKER     | Default for if the ISS broker should be used or not               | false         | No       | Yes |
| ENABLE_ETX_BROKER     | Default for if the ETX broker should be used or not               | false         | No       | Yes |
| Enable_PC5_BROKER     | Default for if the PC5 broker should be used or not               | false         | No       | Yes |
| GPS_TYPE              | Specifies the default GPS type to use within the app. Valid values: mobile, cradle, obu, path, static, bsm, raven | | No | Yes |
| GPS_USERNAME | If using a remote GPS (Cradle), username to use when connecting | | No | Yes |
| GPS_PASSWORD | If using a remote GPS (Cradle), password to use when connecting | | No | Yes |
| GPS_IP | If using a remote GPS (Cradle), the IP address of the GPSD server | | No | Yes |
| OBU_IP | If using an OBU GPS (Ettifos), the IP address of the OBU | | No |  Yes |
| STATIC_GPS_LATITUDE | Default latitude coordinate for Static GPS mode | 0.0 | No | Yes |
| STATIC_GPS_LONGITUDE | Default longitude coordinate for Static GPS mode | 0.0 | No | Yes |
| REGISTRATION_LATITUDE | Default app registration latitude for ETX and initial map display | 38.9555 | No | No |
| REGISTRATION_LONGITUDE | Default app registration longitude for ETX and initial map display | -77.1494 | No | No |
| ISS_SCMS_TOKEN | Token for SCMS if signing is enabled. Will automatically enable signing if set | | No | Yes |
| DISABLE_TUM_RETRY | If true, disables TUM retry behavior | false | No | Yes |
| BROADCAST_RATE | Number of messages to broadcast each second. Value must be between 1 and 10 (inclusive) | 1 | No | Yes |
| USE_GPS_TIMESTAMP_FOR_SEND_TIME | If true, outbound message send time uses the latest GPS timestamp instead of timing service time | false | No | Yes |
| LOGGING_LEVEL | Minimum log level to write (`debug`, `info`, `warning`, `error`) | info | No | No |
| ENABLE_LATENCY_LOGGING | Logs the latency between receiving a message and rendering it on the map to a LATENCY_LOG csv file. Each row has a status: RENDERED (received and drawn), SUPERSEDED (replaced by a newer message for the same source before being drawn), or EXPIRED (removed before being drawn). | false | No | No |
| TOLLING_ENABLED | Enable or disable tolling features in the application | true | No | No |
| SHOW_TIMS | Show TIMS-related settings and features (alias for SHOW_TIMS_SETTINGS) | true | No | No |
| SHOW_ISS_BROKER_URL | Show the ISS broker URL setting field | false | No | No |

#### Settings Page Visibility Variables

The following variables can be set to `true` or `false` to control which settings appear in the application's settings menu:

| Variable              | Purpose                                                           | Default Value | Changeable in App|
| :-------------------- | :---------------------------------------------------------------- | :------------ | -------- |
| SHOW_BASE_URI | Show the API endpoint URI setting in the Account section | true | No |
| SHOW_DEVICE_ID | Show the device ID setting in the Account section | true | No |
| MOBILE_GPS_ALLOWED | Allow Mobile/Native device GPS as a GPS mode option | true | No |
| CRADLE_GPS_ALLOWED | Allow Cradle GPS as a GPS mode option | true | No |
| OBU_GPS_ALLOWED | Allow OBU GPS as a GPS mode option | true | No |
| PATH_GPS_ALLOWED | Allow Path GPS as a GPS mode option | true | No |
| STATIC_GPS_ALLOWED | Allow Static GPS as a GPS mode option | true | No |
| SHOW_BROADCAST_RATE | Show the message broadcast rate setting | true | No |
| SHOW_PC5_BROKER | Show the PC5 MQTT broker setting | true | No |
| SHOW_ISS_BROKER | Show the ISS MQTT broker setting | true | No |
| SHOW_ETX_BROKER | Show the ETX MQTT broker setting | true | No |
| SHOW_MANUAL_REGISTRATION | Show the manual registration setting | true | No |
| SHOW_VZ_MODE | Show Verizon-specific mode setting | true | No |
| SHOW_DEMO_MODE | Show demo mode setting | false | No |
| SHOW_SIGNING | Show message signing setting | true | No |
| SHOW_DISABLE_TUM_RETRY | Show TUM retry disable setting | true | No |
| SHOW_TOLLING_SETTINGS | Show tolling-related settings | true | No |
| SHOW_TIMS_SETTINGS | Show TIMS-related settings | true | No |
| SHOW_BSM_PSM_MESSAGE_SENDING | Show BSM/PSM message sending toggle | false | No |

#### Branding and Colors Variables

The following variables can be used to customize the application's branding and color scheme. Colors should be provided as hex values in ARGB format (e.g., `0xFF000000` for black).

| Variable              | Purpose                                                           | Default Value | Changeable in App|
| :-------------------- | :---------------------------------------------------------------- | :------------ | -------- |
| APP_NAME | Custom application name displayed in the UI | CV_MEC | No |
| LOGO_PATH | Path to custom logo image asset | assets/images/v2x_logo.png | No |
| APP_ICON_PATH | Path to custom app icon asset | assets/images/app_icon.png | No |
| LOAD_PAGE_PATH | Path to custom loading/splash page image | assets/images/load_page.png | No |
| LIGHT_BACKGROUND_COLOR | Light theme background color (ARGB hex format) | 0xFFF0F3F7 | No |
| DARK_BACKGROUND_COLOR | Dark theme background color (ARGB hex format) | 0xFF010E1F | No |
| PRIMARY_COLOR | Light theme primary color (ARGB hex format) | 0xFF0F2F76 | No |
| DARK_PRIMARY_COLOR | Dark theme primary color (ARGB hex format) | 0xFF0F2F76 | No |
| SELECTED_COLOR | Light theme selected/accent color (ARGB hex format) | 0xFF2D4A8A | No |
| DARK_SELECTED_COLOR | Dark theme selected/accent color (ARGB hex format) | 0xFF2D4A8A | No |
| DISABLED_COLOR | Light theme disabled state color (ARGB hex format) | 0xFF868686 | No |
| DARK_DISABLED_COLOR | Dark theme disabled state color (ARGB hex format) | 0xFF333333 | No |
| TEXT_PRIMARY_COLOR | Light theme primary text color (ARGB hex format) | 0xFF000000 | No |
| DARK_TEXT_PRIMARY_COLOR | Dark theme primary text color (ARGB hex format) | 0xFFFFFFFF | No |
| LIGHT_GREY | Light theme grey color (ARGB hex format) | 0xFFD1D7E0 | No |
| MEDIUM_GREY | Medium grey color (ARGB hex format) | 0xFF909EB0 | No |
| DARK_GREY | Dark grey color (ARGB hex format) | 0xFF4B5D75 | No |

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

## Changing App Name and Branding

### 1. Add Assets
- Go to `assets/images/Custom` or create a new directory under `assets/images`
- Add a `logo.png` (500x500px) `app_icon.png` (500x500px) and `load_page.png` (900x1800px).
- If you use a directory under assets/images that isn't 'Custom' or 'Default',   add the asset to the `pubspec.yaml`:
  ```yaml
  assets:
    - assets/images/[directory name]/
  ```

### 2. Edit .env
- Set the colors, app name, and asset references (logo_path and load_page_path)  in the `.env` file.

| Variable                 | Purpose                                                          | Default Value                       | Required |
| :----------------------- | :--------------------------------------------------------------- | :---------------------------------- | :------- |
| APP_NAME                 | Sets the name of the application.                                | V2X Mobile App                      | No       |
| LOGO_PATH                | Sets the path where the app logo is located                      | assets/images/Default/logo.png      | No       |
| APP_ICON_PATH            | Sets the path where the app icon image is located                | assets/images/Defaulst/app_icon.png | No       |
| LOAD_PAGE_PATH           | Sets the path where the load page image is located               | assets/images/Default/load_page.png | No       |
| LIGHT_BACKGROUND_COLOR   | Sets the app background color when the app is in light mode      | 0xFFF0F3F7                          | No       |
| DARK_BACKGROUND_COLOR    | Sets the app background color when the app is in dark mode       | 0xFF010E1F                          | No       |
| PRIMARY_COLOR            | Color used for the appbar and buttons in light mode              | 0xFF0F2F76                          | No       |
| DARK_PRIMARY_COLOR       | Color used for the appbar and buttons in dark mode               | 0xFF0F2F76                          | No       |
| SELECTED_COLOR           | Color used when a widget is tapped in light mode                 | 0xFF2D4A8A                          | No       |
| DARK_SELECTED_COLOR      | Color used when a widget is tapped in dark mode                  | 0xFF2D4A8A                          | No       |
| DISABLED_COLOR           | Color used when a widget is disabled/inactive in light mode      | 0xFF868686                          | No       |
| DARK_DISABLED_COLOR      | Color used when a widget is disables/inactive in dark mode       | 0xFF333333                          | No       |
| TEXT_PRIMARY_COLOR       | Color used for text when the text is over a light background     | 0xFF000000                          | No       |
| DARK_TEXT_PRIMARY_COLOR  | Color used for text when the text is over a dark background      | 0xFFFFFFFF                          | No       |
| LIGHT_GREY               | Light grey color used for cards and as a secondary widget color  | 0xFFD1D7E0                          | No       |
| MEDIUM_GREY              | Medium grey color used for cards and as a secondary widget color | 0xFF909EB0                          | No       |
| DARK_GREY                | Dark grey color used for cards and as a secondary widget color   | 0xFF4B5D75                          | No       |


### 3. Run update_branding script
- In the cv_mec directory, run `dart run update_branding.dart`

### 4. Change the application name for deployment
- For varying deployments, change the applicationId in `android/app/build.gradle` and the CFBundleDisplay Name in 'ios/Runner/Info.plist'
