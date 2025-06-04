# CV MEC Release Notes
## Version 41 - (June 2025)
- Updated CV-MEC to use 2024 version of J2735 standard
- Added vehicle and pedestrian modes
- Added in PSM support
- Added vehicle type support for BSM's
- Added SDSM support
- Refactored received message system
- Added ability to turn on lights and sirens for specific vehicle types
- UI Overhaul


## Version 34 - 5GAA Demo (Feb 2025)
- Added MAP message decoding
- Added SPaT message decoding
- Added ability to render MAP messages on the map page
- Added ability to render SPaT messages on the map page
- Added light change countdown icon to map page
- Updated Tim message dictionary to include new message types
- Updated logging framework to include message type and message send time information
- Added capability for CV-MEC application to upload logs to S3 buckets
- Updated CV-MEC application for compatibility with version 2 of the ETX
- Refactored j2735 asn support files for compliance with dart naming schemes

## Version 23 - Interoperability Testing (Oct 2024)
- Added in ASN.1 Encoder / Decoder Module using Flutter FFI 
- Added map page to CV-MEC mobile application
- Added ability to generate and send asn.1 encoded BSM messages
- Added ability to receive receive and decode asn.1 BSM and TIM messages
- Added ability to graphically show BSM's and TIM messages on the map
- Updated Settings menu to use predefined authentication credentials

## Version 12 -  Initial Release (Aug 2024)
- Created CV-MEC mobile application for testing latency on Verizon MQTT service
- Added in MQTT testing page
- Added Settings page for configuring partner API credentials
- Added Rest Interface for retrieving partner API credentials from Verizon
- Added ability to connected to Verizon IMP V1 mqtt service
- Added ability to switch between VZ and non-VZ modes.
- Created configuration page for setting up MQTT Latency test
