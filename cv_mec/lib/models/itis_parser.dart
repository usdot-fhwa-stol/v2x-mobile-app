import 'dart:core';
import 'package:asn1_plugin/j2735/2024/choice/choice_content.dart';
import 'package:asn1_plugin/j2735/2024/common/speed_limit.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_codes.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_itis_codes_and_text.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_text.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_phrase.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/exit_service.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/generic_signage.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_data_frame.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/work_zone.dart';
import 'package:cv_mec/models/itis_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ItisParser {
  final int speedLimit = 268;
  final int accident = 513;
  final int incident = 531;
  final int hazardousMaterialSpill = 550;
  final int closed = 770;
  final int leftLaneClosedAhead = 771;
  final int closedForTheSeason = 774;
  final int reducedToOneLane = 777;
  final int avalancheControlActivities = 1042;
  final int roadConstruction = 1025;
  final int herdOfAnimalsOnRoadway = 1292;
  final int rockFall = 1309;
  final int landSlide = 1310;
  final int delays = 1537;
  final int wideLoad = 2050;
  final int noTrailers = 2568;
  final int widthLimit = 2573;
  final int heightLimit = 2574;
  final int wildFire = 3084;
  final int weatherEmergency = 3201;
  final int majorEvent = 3841;
  final int noParkingSpacesAvailable = 4103;
  final int onlyAFewParkingSpacesAvailable = 4104;
  final int spacesAvailable = 4105;
  final int noParkingInformationAvailable = 4223;
  final int severeWeather = 4865;
  final int snow = 4868;
  final int winterStorm = 4871;
  final int rain = 4885;
  final int strongWinds = 5127;
  final int fog = 5378;
  final int visibilityReduced = 5383;
  final int blowingSnow = 5385;
  final int blackIce = 5908;
  final int wetPavement = 5895;
  final int ice = 5906;
  final int icyPatches = 5907;
  final int snowDrifts = 5927;
  final int gravelRoadSurface = 5933;
  final int dryPavement = 6011;
  final int dirtRoadSurface = 6016;
  final int milledRoadSurface = 6017;
  final int snowTiresOrChainsRequired = 6156;
  final int lookOutForWorkers = 6952;
  final int keepToRight = 7525;
  final int keepToLeft = 7426;
  final int reduceYourSpeed = 7443;
  final int driveCarefully = 7169;
  final int driveWithExtremeCaution = 7170;
  final int increaseNormalFollowingDistance = 7173;
  final int prepareToStop = 7186;
  final int stopAtNextSafePlace = 7188;
  final int onlyTravelIfAbsolutelyNecessary = 7189;
  final int rightLaneClosedAhead = 8196;
  final int pedestrian = 9486;
  final int fallingRocks = 12037;
  final int maxItisSmallNumber = 12799;
  final int minItisSmallNumber = 12545;
  final int crossing = 13585;

  final String imageDirectory = "assets/images/ITIS";

  // Font Packs are Bitmap versions of .ttf fonts. They can be converted here: https://ttf2fnt.com/
  final String font80Path = "assets/fonts/HighwayGothic_80.zip";
  final String font72Path = "assets/fonts/HighwayGothic_72.zip";
  final String font48Path = "assets/fonts/HighwayGothic_48.zip";
  final String font40Path = "assets/fonts/HighwayGothic_40.zip";

  late final Map<int, ItisCode> basicAdvisioryCodeMap;
  late final Map<int, ItisCode> basicWorkZoneCodeMap;
  late final Map<int, ItisCode> basicGenericSignageCodeMap;
  late final Map<int, ItisCode> basicSpeedLimitCodeMap;
  late final Map<int, ItisCode> basicExitServiceCodeMap;

  late final Map<int, ItisCode> speedAdvisoryMap;
  late final Map<int, ItisCode> speedAheadMap;
  late final Map<int, ItisCode> speedMap;

  ItisParser() {
    basicAdvisioryCodeMap = {
      accident:
          ItisCode.withImage(accident, "Accident", [ITIScodes(accident)], AssetImage("$imageDirectory/$accident.png")),
      incident:
          ItisCode.withImage(incident, "Incident", [ITIScodes(accident)], AssetImage("$imageDirectory/$incident.png")),
      hazardousMaterialSpill: ItisCode.withImage(hazardousMaterialSpill, "Hazardous Material Spill",
          [ITIScodes(hazardousMaterialSpill)], AssetImage("$imageDirectory/$hazardousMaterialSpill.png")),
      closed: ItisCode.withImage(closed, "Closed", [ITIScodes(closed)], AssetImage("$imageDirectory/$closed.png")),
      closedForTheSeason: ItisCode.withImage(closedForTheSeason, "Closed for the Season",
          [ITIScodes(closedForTheSeason)], AssetImage("$imageDirectory/$closedForTheSeason.png")),
      avalancheControlActivities: ItisCode.withImage(avalancheControlActivities, "Avalanche Control Activities",
          [ITIScodes(avalancheControlActivities)], AssetImage("$imageDirectory/$avalancheControlActivities.png")),
      accident:
          ItisCode.withImage(accident, "Accident", [ITIScodes(accident)], AssetImage("$imageDirectory/$accident.png")),
      herdOfAnimalsOnRoadway: ItisCode.withImage(herdOfAnimalsOnRoadway, "Herd of Animals on Roadway",
          [ITIScodes(herdOfAnimalsOnRoadway)], AssetImage("$imageDirectory/$herdOfAnimalsOnRoadway.png")),
      rockFall: ItisCode(
        rockFall,
        "Rock Fall",
        [ITIScodes(rockFall)],
      ),
      landSlide: ItisCode.withImage(
          landSlide, "Landslide", [ITIScodes(landSlide)], AssetImage("$imageDirectory/$landSlide.png")),
      wideLoad:
          ItisCode.withImage(wideLoad, "Wide Load", [ITIScodes(wideLoad)], AssetImage("$imageDirectory/$wideLoad.png")),
      noTrailers: ItisCode.withImage(
          noTrailers, "Wide Load", [ITIScodes(noTrailers)], AssetImage("$imageDirectory/$noTrailers.png")),
      wildFire:
          ItisCode.withImage(wildFire, "Wild Fire", [ITIScodes(wildFire)], AssetImage("$imageDirectory/$wildFire.png")),
      weatherEmergency: ItisCode.withImage(weatherEmergency, "Wild Fire", [ITIScodes(weatherEmergency)],
          AssetImage("$imageDirectory/$weatherEmergency.png")),
      majorEvent: ItisCode.withImage(
          majorEvent, "Major Event", [ITIScodes(majorEvent)], AssetImage("$imageDirectory/$majorEvent.png")),
      severeWeather: ItisCode.withImage(severeWeather, "Severe Weather", [ITIScodes(severeWeather)],
          AssetImage("$imageDirectory/$severeWeather.png")),
      snow: ItisCode.withImage(snow, "Snow", [ITIScodes(snow)], AssetImage("$imageDirectory/$snow.png")),
      winterStorm: ItisCode.withImage(
          winterStorm, "Winter Storm", [ITIScodes(winterStorm)], AssetImage("$imageDirectory/$winterStorm.png")),
      rain: ItisCode.withImage(rain, "Rain", [ITIScodes(rain)], AssetImage("$imageDirectory/$rain.png")),
      strongWinds: ItisCode.withImage(
          strongWinds, "Strong Winds", [ITIScodes(strongWinds)], AssetImage("$imageDirectory/$strongWinds.png")),
      fog: ItisCode.withImage(fog, "Fog", [ITIScodes(fog)], AssetImage("$imageDirectory/$fog.png")),
      visibilityReduced: ItisCode.withImage(visibilityReduced, "Visibility Reduced", [ITIScodes(visibilityReduced)],
          AssetImage("$imageDirectory/$visibilityReduced.png")),
      blowingSnow: ItisCode.withImage(
          blowingSnow, "Rain", [ITIScodes(blowingSnow)], AssetImage("$imageDirectory/$blowingSnow.png")),
      blackIce:
          ItisCode.withImage(blackIce, "Black Ice", [ITIScodes(blackIce)], AssetImage("$imageDirectory/$blackIce.png")),
      wetPavement: ItisCode.withImage(
          wetPavement, "Wet Pavement", [ITIScodes(wetPavement)], AssetImage("$imageDirectory/$wetPavement.png")),
      ice: ItisCode.withImage(ice, "Ice", [ITIScodes(ice)], AssetImage("$imageDirectory/$ice.png")),
      icyPatches: ItisCode.withImage(
          icyPatches, "Icy Patches", [ITIScodes(icyPatches)], AssetImage("$imageDirectory/$icyPatches.png")),
      snowDrifts: ItisCode.withImage(
          snowDrifts, "Snow Drifts", [ITIScodes(snowDrifts)], AssetImage("$imageDirectory/$snowDrifts.png")),
      dryPavement: ItisCode.withImage(
          dryPavement, "Dry Pavement", [ITIScodes(dryPavement)], AssetImage("$imageDirectory/$dryPavement.png")),
      dirtRoadSurface: ItisCode.withImage(dirtRoadSurface, "Dirt Road Surface", [ITIScodes(dirtRoadSurface)],
          AssetImage("$imageDirectory/$dirtRoadSurface.png")),
      milledRoadSurface: ItisCode.withImage(milledRoadSurface, "Milled Road Surface", [ITIScodes(milledRoadSurface)],
          AssetImage("$imageDirectory/$milledRoadSurface.png")),
      snowTiresOrChainsRequired: ItisCode.withImage(snowTiresOrChainsRequired, "Snow Tires or Chaines Required",
          [ITIScodes(snowTiresOrChainsRequired)], AssetImage("$imageDirectory/$snowTiresOrChainsRequired.png")),
      icyPatches: ItisCode.withImage(
          icyPatches, "Icy Patches", [ITIScodes(icyPatches)], AssetImage("$imageDirectory/$icyPatches.png")),
      driveCarefully: ItisCode.withImage(driveCarefully, "Drive Carefully", [ITIScodes(driveCarefully)],
          AssetImage("$imageDirectory/$driveCarefully.png")),
      driveWithExtremeCaution: ItisCode.withImage(driveWithExtremeCaution, "Drive with Extreme Caution",
          [ITIScodes(driveWithExtremeCaution)], AssetImage("$imageDirectory/$driveWithExtremeCaution.png")),
      increaseNormalFollowingDistance: ItisCode.withImage(
          increaseNormalFollowingDistance,
          "Increase Normal Following Distance",
          [ITIScodes(increaseNormalFollowingDistance)],
          AssetImage("$imageDirectory/$increaseNormalFollowingDistance.png")),
      prepareToStop: ItisCode.withImage(prepareToStop, "Prepare to Stop", [ITIScodes(prepareToStop)],
          AssetImage("$imageDirectory/$prepareToStop.png")),
      stopAtNextSafePlace: ItisCode.withImage(stopAtNextSafePlace, "Stop at Next Safe Place",
          [ITIScodes(stopAtNextSafePlace)], AssetImage("$imageDirectory/$stopAtNextSafePlace.png")),
      onlyTravelIfAbsolutelyNecessary: ItisCode.withImage(
          onlyTravelIfAbsolutelyNecessary,
          "Only travel if absolutely necessary",
          [ITIScodes(onlyTravelIfAbsolutelyNecessary)],
          AssetImage("$imageDirectory/$onlyTravelIfAbsolutelyNecessary.png")),
      fallingRocks: ItisCode.withImage(
          fallingRocks, "Falling Rocks", [ITIScodes(fallingRocks)], AssetImage("$imageDirectory/$fallingRocks.png")),
    };

    basicWorkZoneCodeMap = {
      reducedToOneLane: ItisCode.withImage(rightLaneClosedAhead, "Reduce to one Lane", [ITIScodes(reducedToOneLane)],
          AssetImage("$imageDirectory/$rightLaneClosedAhead.png")),
      roadConstruction: ItisCode.withImage(roadConstruction, "Road Construction", [ITIScodes(roadConstruction)],
          AssetImage("$imageDirectory/$roadConstruction.png")),
      gravelRoadSurface: ItisCode(
        gravelRoadSurface,
        "Gravel Road Surface",
        [ITIScodes(gravelRoadSurface)],
      ),
      lookOutForWorkers: ItisCode(
        lookOutForWorkers,
        "Look Out for Workers",
        [ITIScodes(lookOutForWorkers)],
      ),
      keepToRight: ItisCode.withImage(
          keepToRight, "Keep to Right", [ITIScodes(keepToRight)], AssetImage("$imageDirectory/$keepToRight.png")),
      keepToLeft: ItisCode.withImage(
          keepToLeft, "Keep to Left", [ITIScodes(keepToLeft)], AssetImage("$imageDirectory/$keepToLeft.png")),
    };

    basicGenericSignageCodeMap = {};

    basicSpeedLimitCodeMap = {};

    basicExitServiceCodeMap = {};

    speedAheadMap = {};
    speedAdvisoryMap = {};
    speedMap = {};
  }

  Future<ItisCode> getItisRepresentation(TravelerDataFrame frame) async {
    Choice_Content content = frame.content;
    if (content is WorkZone) {
      // Work Zone
      return parseItisAlertFromWorkZone(content);
    } else if (content is ExitService) {
      // Exit Service
      return parseItisAlertFromExitService(content);
    } else if (content is GenericSignage) {
      // Generic Signage
      return parseItisAlertFromGenericSignage(content);
    } else if (content is SpeedLimit) {
      // Speed Limit
      return parseItisAlertFromSpeedLimit(content);
    } else if (content is ITIS_ITIScodesAndText) {
      // Advisory
      return parseItisCodeFromITISCodesAndText(content);
    } else {
      return ItisCode.error("Traveler Information Frame Content is not a Known Type");
    }
  }

  Future<ItisCode> parseItisCodeFromITISCodesAndText(ITIS_ITIScodesAndText itis) async {
    if (itis.item.isNotEmpty) {
      if (itis.item.first is ITIScodes) {
        int code = (itis.item.first as ITIScodes).itisCode;
        if (basicAdvisioryCodeMap.containsKey(code)) {
          return basicAdvisioryCodeMap[code]!;
        } else if (itis.item.length >= 2 &&
            (itis.item[0] as ITIScodes).itisCode == pedestrian &&
            (itis.item[1] as ITIScodes).itisCode == crossing) {
          return ItisCode.withImage(
              pedestrian, "Pedestrian Crossing", itis.item, AssetImage("$imageDirectory/pedcrossing.png"));
        } else if (code == speedLimit) {
          if (itis.item.length == 3) {
            // Basic Speed Limit
            int speed = getSpeedFromItis((itis.item[1] as ITIScodes).itisCode);
            if (speed != -1) {
              if (speedAdvisoryMap.containsKey(speed)) {
                return speedAdvisoryMap[speed]!;
              }

              ImageProvider? image = await getSpeedAdvisoryImage(speed);
              if (image != null) {
                ItisCode code = ItisCode.withImage(speedLimit, "Speed Limit", itis.item, image);
                speedAdvisoryMap[speed] = code;
                return code;
              } else {
                return ItisCode(speedLimit, "Speed Limit", itis.item);
              }
            } else {
              return ItisCode.error("Received Itis Code 268 (Speed Limit), but included Speed is not a valid Speed");
            }
          } else {
            return ItisCode.error("Received ITIS Code 268 (Speed Limit), but missing additional required arguments");
          }
        } else {
          return ItisCode.unknown(code);
        }
      } else if ((itis.item[0] as ITIStext).itisText.toString() == "$pedestrian, $crossing") {
        return ItisCode.withImage(pedestrian, "Pedestrian Crossing", itis.item,
            AssetImage("$imageDirectory/pedcrossing.png")); //AssetImage("$imageDirectory/pedcrossing.png")
      } else if (itis.item.first is ITIStext) {
        return ItisCode(-1, (itis.item.first as ITIStext).itisText, itis.item);
      } else {
        return ItisCode.error("Received Advisory Tim Message with unknown Item type");
      }
    } else {
      return ItisCode.error("TIM message has no ITIS Codes");
    }
  }

  Future<ItisCode> parseItisAlertFromWorkZone(WorkZone wz) async {
    if (wz.item.isNotEmpty) {
      if (wz.item.first is ITIScodes) {
        int code = (wz.item.first as ITIScodes).itisCode;
        if (basicWorkZoneCodeMap.containsKey(code)) {
          return basicWorkZoneCodeMap[code]!;
        } else {
          if (code == 8196) {
            if (wz.item.length > 1 && wz.item[1] is ITIScodes) {
              if ((wz.item[1] as ITIScodes).itisCode == 771) {
                return ItisCode.withImage(
                    771, "Right Lane Closed Ahead", wz.item, AssetImage("$imageDirectory/$rightLaneClosedAhead.png"));
              }
            }
          } else if (code == 8195) {
            if (wz.item.length > 1 && wz.item[1] is ITIScodes) {
              if ((wz.item[1] as ITIScodes).itisCode == 771) {
                return ItisCode.withImage(
                    771, "Left Lane Closed Ahead", wz.item, AssetImage("$imageDirectory/$leftLaneClosedAhead.png"));
              }
            }
          }

          return ItisCode.unknown(code);
        }
      } else if (wz.item is ITISPhrase) {
        return ItisCode(-1, (wz.item.first as ITIStext).itisText, wz.item);
      } else {
        return ItisCode.error("Received Advisory Tim Message with unknown Item type");
      }
    } else {
      return ItisCode.error("TIM message has no ITIS Codes");
    }
  }

  Future<ItisCode> parseItisAlertFromSpeedLimit(SpeedLimit sl) async {
    if (sl.item.isNotEmpty) {
      if (sl.item.first is ITIScodes) {
        int code = (sl.item.first as ITIScodes).itisCode;
        if (basicSpeedLimitCodeMap.containsKey(code)) {
          return basicSpeedLimitCodeMap[code]!;
        } else if (code == speedLimit) {
          if (sl.item.length == 3) {
            // Basic Speed Limit
            int speed = getSpeedFromItis((sl.item[1] as ITIScodes).itisCode);
            if (speed != -1) {
              if (speedMap.containsKey(speed)) {
                return speedMap[speed]!;
              }

              ImageProvider? image = await getSpeedImage(speed);
              if (image != null) {
                ItisCode code = ItisCode.withImage(speedLimit, "Speed Limit", sl.item, image);
                speedMap[speed] = code;
                return code;
              } else {
                return ItisCode(speedLimit, "Speed Limit", sl.item);
              }
            } else {
              return ItisCode.error("Received Itis Code 268 (Speed Limit), but included Speed is not a valid Speed");
            }
          } else if (sl.item.length == 5) {
            // Reduce Speed Ahead

            int speed = getSpeedFromItis((sl.item[2] as ITIScodes).itisCode);

            if (speedAheadMap.containsKey(speed)) {
              return speedAheadMap[speed]!;
            }

            ImageProvider? image = await getSpeedAheadImage(speed);
            if (image != null) {
              ItisCode code = ItisCode.withImage(speedLimit, "Reduce Speed Ahead", sl.item, image);
              speedAheadMap[speed] = code;
              return code;
            } else {
              return ItisCode(speedLimit, "Reduce Speed Ahead", sl.item);
            }
          } else {
            return ItisCode.error("Received ITIS Code 268 (Speed Limit), but missing additional required arguments");
          }
        } else {
          return ItisCode.unknown(code);
        }
      } else if (sl.item is ITISPhrase) {
        return ItisCode(-1, (sl.item.first as ITIStext).itisText, sl.item);
      } else {
        return ItisCode.error("Received Advisory Tim Message with unknown Item type");
      }
    } else {
      return ItisCode.error("TIM message has no ITIS Codes");
    }
  }

  Future<ItisCode> parseItisAlertFromGenericSignage(GenericSignage gs) async {
    if (gs.item.isNotEmpty) {
      if (gs.item.first is ITIScodes) {
        int code = (gs.item.first as ITIScodes).itisCode;
        if (basicGenericSignageCodeMap.containsKey(code)) {
          return basicGenericSignageCodeMap[code]!;
        } else {
          return ItisCode.unknown(code);
        }
      } else if (gs.item is ITISPhrase) {
        return ItisCode(-1, (gs.item.first as ITIStext).itisText, gs.item);
      } else {
        return ItisCode.error("Received Advisory Tim Message with unknown Item type");
      }
    } else {
      return ItisCode.error("TIM message has no ITIS Codes");
    }
  }

  Future<ItisCode> parseItisAlertFromExitService(ExitService es) async {
    if (es.item.isNotEmpty) {
      if (es.item.first is ITIScodes) {
        int code = (es.item.first as ITIScodes).itisCode;
        if (basicExitServiceCodeMap.containsKey(code)) {
          return basicExitServiceCodeMap[code]!;
        } else {
          return ItisCode.unknown(code);
        }
      } else if (es.item is ITISPhrase) {
        return ItisCode(-1, (es.item.first as ITIStext).itisText, es.item);
      } else {
        return ItisCode.error("Received Advisory Tim Message with unknown Item type");
      }
    } else {
      return ItisCode.error("TIM message has no ITIS Codes");
    }
  }

  int getSpeedFromItis(int itis) {
    int speed = itis - minItisSmallNumber + 1;
    if (speed >= 0 && speed <= 255) {
      return speed;
    }
    return -1;
  }

  Future<ImageProvider?> getSpeedImage(int sl) async {
    final ByteData assetImageByteData = await rootBundle.load('$imageDirectory/$speedLimit.png');
    String assetPath = font80Path;
    if (sl >= 100) {
      assetPath = font48Path;
    }
    final ByteData assetFontByteData = await rootBundle.load(assetPath);
    final font = img.readFontZip(assetFontByteData.buffer.asUint8List());
    img.Image? baseSizeImage = img.decodeImage(assetImageByteData.buffer.asUint8List());
    if (baseSizeImage != null) {
      img.drawString(baseSizeImage, "$sl", font: font, color: img.ColorRgb8(0, 0, 0), y: 120);
      return MemoryImage(img.encodePng(baseSizeImage));
    }
    return null;
  }

  Future<ImageProvider?> getSpeedAheadImage(int sl) async {
    final ByteData assetImageByteData = await rootBundle.load('$imageDirectory/$reduceYourSpeed.png');
    String assetPath = font72Path;
    int yOffset = 200;
    if (sl >= 100) {
      yOffset = 220;
      assetPath = font40Path;
    }

    final ByteData assetFontByteData = await rootBundle.load(assetPath);
    final font = img.readFontZip(assetFontByteData.buffer.asUint8List());
    img.Image? baseSizeImage = img.decodeImage(assetImageByteData.buffer.asUint8List());
    if (baseSizeImage != null) {
      img.drawString(baseSizeImage, "$sl", font: font, color: img.ColorRgb8(0, 0, 0), y: yOffset);
      return MemoryImage(img.encodePng(baseSizeImage));
    }
    return null;
  }

  Future<ImageProvider?> getSpeedAdvisoryImage(int sl) async {
    final ByteData assetImageByteData = await rootBundle.load('$imageDirectory/268_Advisory.png');
    String assetPath = font80Path;

    if (sl >= 100) {
      assetPath = font48Path;
    }
    final ByteData assetFontByteData = await rootBundle.load(assetPath);
    final font = img.readFontZip(assetFontByteData.buffer.asUint8List());
    img.Image? baseSizeImage = img.decodeImage(assetImageByteData.buffer.asUint8List());
    if (baseSizeImage != null) {
      img.drawString(baseSizeImage, "$sl", font: font, color: img.ColorRgba8(0, 0, 0, 200), y: 30);
      return MemoryImage(img.encodePng(baseSizeImage));
    }
    return null;
  }
}
