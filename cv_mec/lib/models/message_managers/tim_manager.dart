import 'package:asn1_plugin/j2735/2024/common/heading_slice.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_data_frame.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_information.dart';
import 'package:cv_mec/models/geometry_direction.dart';
import 'package:cv_mec/models/data_frame_geometry.dart';
import 'package:cv_mec/models/itis_code.dart';
import 'package:cv_mec/models/itis_parser.dart';
import 'package:cv_mec/services/asn_service.dart';
import 'package:cv_mec/services/geometry_service.dart';
import 'package:uuid/uuid.dart';

class TimManager {
  Map<String, TravelerInformation> storedTims =
      <String, TravelerInformation>{}; // Store all Tims that have been received

  Map<TravelerDataFrame, DataFrameGeometry> geometryMap = <TravelerDataFrame, DataFrameGeometry>{};
  Map<TravelerDataFrame, String> asn1Map = <TravelerDataFrame, String>{};

  GeometryService geometryService = GeometryService();

  ItisParser itisParser = ItisParser();

  final uuid = const Uuid();

  void addOrUpdate(TravelerInformation tim, String asn1) {
    if (tim.packetID != null) {
      String packetID = ASNService.bytesToHex(tim.packetID!.uniqueMSGID);

      if (storedTims.containsKey(packetID)) {
        if (isMessageUpdate(tim, packetID)) {
          removeTim(packetID);

          Map<TravelerDataFrame, DataFrameGeometry> newGeometryEntries = geometryService.getTimPolyRegion(tim);

          geometryMap.addAll(newGeometryEntries);

          for (TravelerDataFrame frame in newGeometryEntries.keys) {
            asn1Map[frame] = asn1;
          }
        } else {
          // Don't do anything message is not an update
        }
      } else {
        storedTims[packetID] = tim;
        Map<TravelerDataFrame, DataFrameGeometry> newGeometryEntries = geometryService.getTimPolyRegion(tim);
        geometryMap.addAll(newGeometryEntries);

        for (TravelerDataFrame frame in newGeometryEntries.keys) {
          asn1Map[frame] = asn1;
        }
      }
    } else {
      // Protect the App from overflowing and crashing if someone is spamming TIM messages without a msgID.
      if (storedTims.length > 1000) {
        // Delete the first Tim with a random key.
        for (String key in storedTims.keys) {
          if (key.length > 9) {
            removeTim(key);
            break;
          }
        }
      }

      Map<TravelerDataFrame, DataFrameGeometry> newGeometryEntries = geometryService.getTimPolyRegion(tim);

      geometryMap.addAll(newGeometryEntries);

      // If there is no way to uniquely identify the TIM message, add a random key
      storedTims[uuid.v4()] = tim;
    }
  }

  void removeTim(String timKey) {
    if (storedTims.containsKey(timKey)) {
      TravelerInformation tim = storedTims[timKey]!;
      for (int i = 0; i < tim.dataFrames.travelerDataFrameList.length; i++) {
        TravelerDataFrame travelerDataFrame = tim.dataFrames.travelerDataFrameList[i];

        if (geometryMap.containsKey(travelerDataFrame)) {
          geometryMap.remove(travelerDataFrame);
        }

        if (asn1Map.containsKey(travelerDataFrame)) {
          asn1Map.remove(travelerDataFrame);
        }
      }
      storedTims.remove(timKey);
    }
  }

  List<TravelerDataFrame> getNewActiveTims(double longitude, double latitude, double heading,
      [bool ignoreHeading = false, bool ignoreTimeWindow = false]) {
    List<TravelerDataFrame> newActiveDataFrames = [];

    for (String key in storedTims.keys) {
      TravelerInformation tim = storedTims[key]!;
      for (TravelerDataFrame dataFrame in tim.dataFrames.travelerDataFrameList) {
        if (geometryMap.containsKey(dataFrame)) {
          DataFrameGeometry dataFrameGeometry = geometryMap[dataFrame]!;
          bool anyActiveZone = false;

          if (isDataFrameTimeActive(dataFrame) || ignoreTimeWindow) {
            for (GeometryDirection geometry in dataFrameGeometry.geometry) {
              if (geometryService.isPointInPolygon(geometry.geometry, longitude, latitude)) {
                if (ignoreHeading ||
                    (geometry.direction != null && isDirectionInHeadingSlice(heading, geometry.direction!))) {
                  anyActiveZone = true;
                }
              } else {
                dataFrameGeometry.active = false;
                dataFrameGeometry.shown =
                    false; // Reset message being shown when the user leaves the specified zone. They can receive the message again if they enter in a valid direction.
              }
            }

            if (anyActiveZone) {
              dataFrameGeometry.active = true;
              if (!dataFrameGeometry.shown) {
                newActiveDataFrames.add(dataFrame);
                dataFrameGeometry.shown = true;
              }
            } else {
              dataFrameGeometry.active = false;
            }
          }
        }
      }
    }
    return newActiveDataFrames;
  }

  List<DataFrameGeometry> getActiveTimGeometry([bool ignoreTimeWindow = false]) {
    List<DataFrameGeometry> activeDataFrames = [];
    for (String key in storedTims.keys) {
      TravelerInformation tim = storedTims[key]!;
      for (TravelerDataFrame dataFrame in tim.dataFrames.travelerDataFrameList) {
        if (isDataFrameTimeActive(dataFrame) || ignoreTimeWindow) {
          if (geometryMap.containsKey(dataFrame)) {
            DataFrameGeometry dataFrameGeometry = geometryMap[dataFrame]!;
            activeDataFrames.add(dataFrameGeometry);
          }
        }
      }
    }

    return activeDataFrames;
  }

  List<TravelerDataFrame> getTimsToShow(double longitude, double latitude, double heading,
      [bool ignoreHeading = false, bool ignoreTimeWindow = false]) {
    List<TravelerDataFrame> showDataFrames = [];

    print("Getting getTimsToShow $ignoreTimeWindow");

    for (String key in storedTims.keys) {
      TravelerInformation tim = storedTims[key]!;
      for (TravelerDataFrame dataFrame in tim.dataFrames.travelerDataFrameList) {
        if (geometryMap.containsKey(dataFrame)) {
          DataFrameGeometry dataFrameGeometry = geometryMap[dataFrame]!;

          if (isDataFrameTimeActive(dataFrame) || ignoreTimeWindow) {
            for (GeometryDirection geometry in dataFrameGeometry.geometry) {
              if (geometryService.isPointInPolygon(geometry.geometry, longitude, latitude)) {
                if (ignoreHeading ||
                    (geometry.direction != null && isDirectionInHeadingSlice(heading, geometry.direction!))) {
                  showDataFrames.add(dataFrame);
                  break;
                }
              }
            }
          }
        }
      }
    }
    return showDataFrames;
  }

  Future<List<ItisCode>> getItisRepresentationForDataFrames(List<TravelerDataFrame> frames) async {
    List<ItisCode> codes = [];
    for (TravelerDataFrame frame in frames) {
      codes.add(await itisParser.getItisRepresentation(frame));
    }
    return codes;
  }

  List<String> getUniqueAsnFromDataFrames(List<TravelerDataFrame> frames) {
    List<String> asn = [];
    for (TravelerDataFrame frame in frames) {
      if (asn1Map.containsKey(frame)) {
        String hex = asn1Map[frame]!;
        if (!asn.contains(hex)) {
          asn.add(hex);
        }
      }
    }
    return asn;
  }

  Future<ItisCode> getItisRepresentationForDataFrame(TravelerDataFrame frame) async {
    return await itisParser.getItisRepresentation(frame);
  }

  DateTime getTimStartTime(TravelerDataFrame dataFrame) {
    DateTime now = DateTime.now();

    int year = now.year;
    if (dataFrame.startYear != null) {
      year = dataFrame.startYear!.dYear;
    }

    DateTime startYear = DateTime(year);
    DateTime startTime = startYear.add(Duration(minutes: dataFrame.startTime.minuteOfTheYear));
    return startTime;
  }

  DateTime getTimEndTime(TravelerDataFrame dataFrame) {
    DateTime now = DateTime.now();

    int year = now.year;
    if (dataFrame.startYear != null) {
      year = dataFrame.startYear!.dYear;
    }

    DateTime startYear = DateTime(year);
    DateTime startTime = startYear.add(Duration(minutes: dataFrame.startTime.minuteOfTheYear));
    DateTime endTime = startTime.add(Duration(minutes: dataFrame.durationTime.minutesDuration));
    return endTime;
  }

  bool isMessageUpdate(TravelerInformation tim, String packetID) {
    int storedMessageCount = storedTims[packetID]!.msgCnt.msgCount;
    int newMessageCount = tim.msgCnt.msgCount;

    if (storedMessageCount < newMessageCount) {
      return true; // Base case
    } else if (storedMessageCount > 120 && newMessageCount < 5) {
      return true; // handle rollover case
    } else {
      return false; // not an update
    }
  }

  bool isDataFrameTimeActive(TravelerDataFrame dataFrame) {
    DateTime now = DateTime.now().toUtc();

    int year = now.year;
    if (dataFrame.startYear != null) {
      year = dataFrame.startYear!.dYear;
    }

    DateTime startYear = DateTime.utc(year);
    DateTime startTime = startYear.add(Duration(minutes: dataFrame.startTime.minuteOfTheYear));
    DateTime endTime = startTime.add(Duration(minutes: dataFrame.durationTime.minutesDuration));

    return startTime.isBefore(now) && endTime.isAfter(now);
  }

  bool isDirectionInHeadingSlice(double direction, HeadingSlice headingSlice) {
    // Start from North and Evaluate going eastwords (left hand)
    return direction >= 0 && direction < 22.5 && headingSlice.from000_0to022_5degrees ||
        direction >= 22.5 && direction < 45 && headingSlice.from022_5to045_0degrees ||
        direction >= 45 && direction < 67.5 && headingSlice.from045_0to067_5degrees ||
        direction >= 67.5 && direction < 90 && headingSlice.from067_5to090_0degrees ||
        direction >= 90 && direction < 112.5 && headingSlice.from090_0to112_5degrees ||
        direction >= 112.5 && direction < 135 && headingSlice.from112_5to135_0degrees ||
        direction >= 135 && direction < 157.5 && headingSlice.from135_0to157_5degrees ||
        direction >= 157.5 && direction < 180 && headingSlice.from157_5to180_0degrees ||
        direction >= 180 && direction < 202.5 && headingSlice.from180_0to202_5degrees ||
        direction >= 202.5 && direction < 225.0 && headingSlice.from202_5to225_0degrees ||
        direction >= 225.0 && direction < 247.5 && headingSlice.from225_0to247_5degrees ||
        direction >= 247.5 && direction < 270.0 && headingSlice.from247_5to270_0degrees ||
        direction >= 270.0 && direction < 292.5 && headingSlice.from270_0to292_5degrees ||
        direction >= 292.5 && direction < 315 && headingSlice.from292_5to315_0degrees ||
        direction >= 315 && direction < 337.5 && headingSlice.from315_0to337_5degrees ||
        direction >= 337.5 && direction < 360.0 && headingSlice.from337_5to360_0degrees;
  }
}
