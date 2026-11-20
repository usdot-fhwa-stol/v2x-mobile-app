# Configurable Location Source

## Overview
The V2X-Mobile-App features support for multiple different GPS sources to be used within the mobile application. GPS sources can be selected by the user in the settings menu by selecting options from the `GPS Mode` list in the settings menu. This feature is designed to help facilitate a number of different use cases and allows for the V2X-Mobile-App to be used as a common graphical interface when working alone or with a variety of external hardware. These settings are critical for Linux systems running the mobile application as these platforms do not have a built in GPS Unit. Below is a list of the supported external GPS types

### GPS Sources
- [1. Mobile](#1-mobile)
- [2. Cradle](#2-cradle)
- [3. OBU](#3-obu)
- [4. Path](#4-path)
- [5. Static](#5-static)
- [6. BSM (Basic Safety Message)](#6-bsm-basic-safety-message)
- [7. Raven](#7-raven)

## GPS Source Availability Environment Variables

The GPS sources available to users can be controlled through environment variables in the `.env` configuration file. These settings determine which GPS mode options appear in the application's settings menu and which GPS types are enabled for use. For builds targeting end user releases, it is recommended to disable most of the GPS modes before building. This helps to ensure users are not required to enter special information such as IP addresses to configure GPS sources. For builds targeting developers or research teams, it is recommended to leave all GPS modes enabled.

Each GPS source can be individually enabled or disabled using the following environment variables. At least one GPS type must be set to `true` for the application to function properly.

| Environment Variable | GPS Type | Description | Default | Related Settings | Notes |
|---|---|---|---|---|---|
| `MOBILE_GPS_ALLOWED` | Mobile | Controls whether the built-in device GPS (native phone GPS receiver) is available as a selection option | `true` | None | Not available on Linux builds; always disabled on Linux platforms |
| `CRADLE_GPS_ALLOWED` | Cradle | Controls whether the external OBU Cradle GPS via API is available as a selection option | `true` | `GPS_IP`, `GPS_USERNAME`, `GPS_PASSWORD` | Requires network connectivity and running OBU cradle device |
| `OBU_GPS_ALLOWED` | OBU | Controls whether the direct OBU integration GPS is available as a selection option | `true` | `OBU_IP` | Requires network connectivity to OBU device |
| `PATH_GPS_ALLOWED` | Path | Controls whether the recorded path playback GPS is available as a selection option | `true` | None | Requires pre-built GPS paths to be uploaded to Partner API |
| `STATIC_GPS_ALLOWED` | Static | Controls whether the fixed/static position GPS is available as a selection option | `true` | None | Useful for testing and development |
| `BSM_GPS_ALLOWED` | BSM | Controls whether a remote BSM is available as a selection option | `true` | None | Useful for testing and development |
| `RAVEN_GPS_ALLOWED` | RAVEN | Controls whether a remote BSM from a Raven device is available as a selection option | `true` | None | Useful for testing and development |

To set which GPS source should be used by default, make sure to also set the `GPS_TYPE` environment variable. Valid values are
MOBILE, CRADLE, OBU, PATH, STATIC, BSM, RAVEN

If not set the GPS will default to the first enabled value in the list [MOBILE, CRADLE, OBU, PATH, STATIC, BSM, RAVEN]


## Current GPS Sources

### 1. Mobile

**Type:** Native Device GPS

**Description:**
The Mobile GPS source uses the device's built-in GPS receiver to obtain real-time positioning data. This is the most common source for consumer mobile applications and provides standard GNSS (Global Navigation Satellite System) capabilities.

**Characteristics:**
- **Availability:** Available on most modern Android and iOS devices. This option is not supported on Linux Builds.
- **Accuracy:** Typically 5-30 meters depending on environmental conditions and receiver quality
- **Update Rate:** 1 Hz 
- **Requirements:** GPS hardware, location permissions, clear sky view

**Configuration:**
Configured through the `LocationService` class. 

**Implementation:**
- Service: `LocationService`
- Uses Geolocator plugin for cross-platform compatibility
- Streams position updates via `locationStream`

---

### 2. Cradle

**Type:** Remote GPS source from Cradlepoint Edge Routers

**Description:**
The Cradle GPS source retrieves positioning data from an external Cradelpoint router via a RESTful API. This GPS source is commonly used in vehicles where a Cradlepoint mobile router is providing cellular internet to a connected Linux system.

**Characteristics:**
- **Availability:** Requires dedicated Cradlepoint hardware and network connectivity
- **Accuracy:** Dependent on the Cradlepoints GNSS receiver (typically 1-5 meters for high-grade units)
- **Update Rate:** Measurements are typically available ~1Hz, but may drop lower depending on network latency and device throughput.
- **Requirements:** Network connectivity, running Cradlepoint device, API credentials

**Configuration:**
This GPS source can be configured by setting environment variables at build time or through the settings menu in the mobile application. 
To setup this GPS source at build time. Include the following environment variables

| Environment Variable | Purpose | Notes |
|---|---|---|
| GPS_USERNAME | Configures the Username the app should use for authenticating with the Cradlepoint router| |
| GPS_PASSWORD | Configures the Password the app should use for authenticating with the Cradlepoint router| |
| GPS_IP | Configures the IP address of the Cradlepoint router. | It is recommended to use the local IP of the router instead of its global IP if possible. This helps the App take the shortest route possible to the edge router.|

All of these values can be changed in the settings menu after the app is built. 

Configured through settings controller with:
- `cradleGPSIP`: IP address or hostname of the OBU cradle device
- `cradleGPSUsername`: Authentication username
- `cradleGPSPassword`: Authentication password

**API Details:**
The Cradle service communicates with the OBU via two endpoints:
1. **Authentication:** `POST /api/v1/auth/tokens` - Obtains access token
2. **Data Query:** `POST /api/v1/db/get` - Retrieves GNSS location and cellular data

**Data Retrieved:**
- `location.gnss.longitude` - GPS longitude
- `location.gnss.latitude` - GPS latitude
- `location.gnss.altitude` - GPS altitude
- `location.gnss.speed` - Vehicle speed
- `location.gnss.heading` - Vehicle heading/bearing
- `net.interface.cellular[c1].technology.current` - Cellular network type
- `net.interface.cellular[c1].snr` - Signal-to-noise ratio

**Implementation:**
- Service: `RemoteGPSService`
- Uses HTTP client with certificate bypass (for development environments)
- Streams position updates at configurable intervals (default 1 second)

---

### 3. OBU

**Type:** Direct OBU Integration

**Description:**
The OBU GPS source provides direct integration with an OBU (On-Board Unit) device using GPSD protocol. GPSD is a daemon that acts as a bridge between multiple GNSS receivers and client applications. Note - This GPS source is called OBU because it was originally designed for use when connecting to Ettifos OBU units. However, this feature will allow for connecting to any number of generic GPS sources if they are running a compatible GPSD service interface.

**Characteristics:**
- **Availability:** Requires GPSD daemon running on OBU or connected device
- **Accuracy:** Dependent on OBU's GNSS receiver (typically 1-10 meters)
- **Update Rate:** Between 1 and 10Hz depending on source Update Rate.
- **Requirements:** GPSD daemon running, network/serial connection to GPSD

**Configuration:**
This GPS source can be configured by setting environment variables at build time or through the settings menu in the mobile application. 
To setup this GPS source at build time. Include the following environment variables
| Environment Variable | Purpose | Notes |
|---|---|---|
| OBU_IP | Configures the IP and port to use for connecting with the Ettifos OBU or GPSD source|  |

Configured through settings with connection string:
- Format: `hostname:port` or just `hostname` (defaults to port 2947)
- Example: `192.168.1.100:2947` or `localhost`

**Features:**
- Automatic reconnection with retry logic
- Connection state tracking and logging
- Error handling for malformed data
- Support for multiple GPSD output formats

**Implementation:**
- Service: `GPSDService`
- TCP socket connection to GPSD daemon
- Streams position updates via broadcast stream
- Automatic reconnection on failure

---

### 4. Path

**Type:** Simulated Route Following

**Description:**
The Path GPS source simulates vehicle movement along predefined routes retrieved from an API. This is a testing and demonstration feature that allows the app to replay recorded vehicle paths or follow predetermined routes. 

**Characteristics:**
- **Availability:** Requires API endpoint serving path data
- **Accuracy:** Determined by recorded path precision
- **Update Rate:** Variable depending on timestamps in GPS path (follows recorded timestamps)
- **Requirements:** API service, path data stored in backend

**Features:**
- Loads predefined routes from API (`PathResponse`)
- Follows route waypoints with timing from recorded data
- Calculates heading based on movement direction
- Estimates speed based on distance and time
- Automatically loops when reaching end of route - Note this may cause vehicles to jump large distances if the path is not a clean loop

**Implementation:**
- Service: `PathService`
- Uses `GeometryService` for distance calculations
- Async generator yields `AugmentedPosition` objects
- Minimum delay of 10ms between points (even if recorded timestamp is shorter)

---

### 5. Static

**Type:** Fixed Location

**Description:**
The Static GPS source provides a fixed, non-changing position. This is useful for testing location-based features without requiring actual device movement or external services.

**Characteristics:**
- **Availability:** Always available
- **Accuracy:** Perfect (no variance)
- **Update Rate:** Fixed GPS updates at 1 Hz
- **Requirements:** None


**Configuration:**
The static GPS type allows the user to enter a fixed GPS coordinate to simulate a vehicle at. 

| Environment Variable | Purpose | Notes |
|---|---|---|
| STATIC_GPS_LATITUDE | Latitude to simulate device at | Must be between -90 and 90 |
| STATIC_GPS_LONGITUDE | Longitude to simulate device at | Must be between -180 and 180 |

Users can also change these variables in the settings menu.


**Implementation:**
- Service: `LocationService` (with `mocked: false`)
- Coordinates defined at initialization
- No updates after initialization
- Uses mock location service internally

---

## Upcoming GPS Sources

### 6. BSM (Basic Safety Message)

**Type:** V2X Vehicle-to-Everything Communication

**Description:**
The BSM source will extract position information from SAE J2735 Basic Safety Messages (BSM) received over V2X communications. This allows positioning based on other vehicles' self-reported locations. The purpose of this system is to allow for other V2X-Mobile-Devices to "follow along" with another device already available in a vehicle. 

**Usage Notes**
- It is recommended that users disable their own BSM broadcast when using this GPS mode. 
- This system will only be able to follow BSM's that are forwarding data to this device. When used on Geo-routed brokers (NMI, ETX) this means that the remote device must start nearby to the host device in order for the host to receive BSM's from the remote.
- It is recommended that the remote device uses a static BSM ID to avoid losing a connection when the remote device rotates its BSM ID
- It is recommended to use a non-geo-routed MQTT system for delivering remote BSM messages to the host device. This will help prevent issues where the two devices may not start in the same place, or where the devices become separated causing the flow of BSM messages to stop.


**Characteristics:**
- **Availability:** Requires other devices broadcasting BSM's on the network
- **Accuracy:** Variable depending on source vehicle accuracy
- **Update Rate:** Variable depending on source vehicle accuracy
- **Requirements:** Other device broadcasting valid J2735 BSM messages on the network.

**Configuration:**
The BSM GPS type allows the user to enter a BSM ID to attempt to follow.

| Environment Variable | Purpose | Notes |
|---|---|---|
| BSM_GPS_ID | BSM ID of the BSMs to follow | |
| BSM_GPS_DEFAULT_LATITUDE | The default position to use if the device has not yet seen the remote BSM | This value is shared between the Raven and BSM data sources |
| BSM_GPS_DEFAULT_LONGITUDE | The default position to use if the device has not yet seen the remote BSM | This value is shared between the Raven and BSM data sources |

These settings can also be changed in the settings menu.

**Implementation:**
- Service: `BSMLocationService` 
- Updates will be tied to receiving updates from the remote device
- If no new BSM updates are received, the device will use the remote devices last known BSM to continue to its operations
- The device is treating the remote BSM as a GPS source - not as its own BSM. The device will not rebroadcast the remote BSM as if it were its own. Instead the device will extract the GPS and speed information from the remote BSM and use that as if it were a GPS source. If the user leaves BSM Broadcasting enabled, the device will send out its own BSM with its own ID and vehicle information.
- The device will have a starting position defined by the BSM_GPS_DEFAULT_LATITUDE and BSM_GPS_DEFAULT_LONGITUDE settings. If the device is moved from this coordinate (by following a remote BSM) it will stay at its remote coordinate unless the user initiates a position reset.

---

### 7. Raven

**Type:** External Location Service Integration

**Description:**
The Raven source will allow for the V2X-Mobile-Device to follow a remote Raven Connected Smart Dashcam. This GPS mode is an extension on the BSM GPS source mode and functions by following BSM messages sent by the provided raven device. The key difference between this operating mode and the BSM operating mode is that this operating mode allows the user to enter a raven device ID instead of a BSM ID. The app then internally remaps the raven UUID to a BSM device ID based upon metadata broadcast by Raven from another topic.

**Characteristics:**
- **Availability:** Requires other devices broadcasting BSM's on the network
- **Accuracy:** Variable depending on source vehicle accuracy
- **Update Rate:** Variable depending on source vehicle accuracy
- **Requirements:** Other device broadcasting valid J2735 BSM messages on the network.

**Configuration:**
The RAVEN GPS type allows the user to enter a RAVEN UUID to attempt to follow.

| Environment Variable | Purpose | Notes |
|---|---|---|
| RAVEN_GPS_UUID | Raven UUID of the Raven to follow | |
| BSM_GPS_DEFAULT_LATITUDE | The default position to use if the device has not yet seen the remote BSM | This value is shared between the Raven and BSM data sources |
| BSM_GPS_DEFAULT_LONGITUDE | The default position to use if the device has not yet seen the remote BSM | This value is shared between the Raven and BSM data sources |

These settings can also be changed in the settings menu.

**Implementation:**
- Service: `RavenLocationService` 
- This GPS type is built on top of the BSM location type. Please reference details in section [6. BSM (Basic Safety Message)](#6-bsm-basic-safety-message) for additional details on how the service works internally
- This GPS type will add one additional mapping layer to the application to allow the app to convert Raven UUIDs to BSM IDs. This may introduce occasional position jumps when the raven device rotates its BSM ID. These jumps are caused by the delay between when a device rotates its ID and when the mobile app receives the updated mapping so that it can continue following. However, unlike directly following a BSM this will allow to continue following a device even after its BSM ID has been rotated.
- This GPS type will continue to work properly even if the `BSM` GPS type it builds upon is disabled.
