import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:asn1_plugin/j2735/2024/choice/choice_content.dart';
import 'package:asn1_plugin/j2735/2024/choice/choice_item.dart';
import 'package:asn1_plugin/j2735/2024/common/speed_limit.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_codes.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_itis_codes_and_text.dart';
import 'package:asn1_plugin/j2735/2024/itis/itis_text.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/exit_service.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/generic_signage.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_data_frame.dart';
import 'package:asn1_plugin/j2735/2024/traveler_information/work_zone.dart';
import 'package:cv_mec/models/archive_directory.dart';
import 'package:cv_mec/models/itis/file_system_image_resolver.dart';
import 'package:cv_mec/models/itis/itis_converter.dart';
import 'package:cv_mec/models/itis/itis_image_resolver.dart';
import 'package:cv_mec/models/itis/itis_sequence.dart';
import 'package:cv_mec/models/itis/root_bundle_image_resolver.dart';
import 'package:cv_mec/models/text_overlay.dart';
import 'package:cv_mec/models/tim_definition.dart';
import 'package:cv_mec/services/api_service.dart';
import 'package:cv_mec/services/file_service.dart';
import 'package:cv_mec/services/logging_service.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Image;

class ItisDecodingService{

  final int maxItisSmallNumber = 12799;
  final int minItisSmallNumber = 12545;
  final int minItisLargeNumber = 11531;
  final int maxItisLargeNumber = 11613;

  LoggingService loggingService = Get.find<LoggingService>();
  final String fontDirectory = "assets/fonts";

  Map<String, ItisSequence> graphicsMap = {};
  List<TimDefinition> dynamicTims = [];

  ApiService apiService = Get.find<ApiService>();
  FileService fileService = Get.find<FileService>();

  ItisImageResolver imageResolver = RootBundleImageResolver();
  
  ItisDecodingService(){
    loadTimManifest();
  }

  void loadTimManifest() async {
    String? timManifest = await apiService.getTimConfiguration();

    bool loadTimsSuccessful = false;

    if(timManifest != null){
      final Map<String, dynamic> mapManifest = jsonDecode(timManifest);
      if(mapManifest.containsKey("version")){
        String version = mapManifest['version'];
        String manifestFileName = "tim_manifest_$version.json";
        loggingService.addToAppLog("Loading TIM Manifest Version $version");
        if(!await fileService.checkIfFileExists(manifestFileName)){
          Uint8List? timFile = await apiService.getTimIcons(version);
          if(timFile != null){
            final tarData = GZipDecoder().decodeBytes(timFile);
            final archive = TarDecoder().decodeBytes(tarData);
            for(final file in archive){
              File outFile = await fileService.getFileForWriting("${file.name}", directory: ArchiveDirectory.APPLICATION_DOCUMENTS);
              await outFile.create(recursive: true);
              await outFile.writeAsBytes(file.content as List<int>);
            }
          }
          File manifestFile = await fileService.getFileForWriting(manifestFileName, directory: ArchiveDirectory.APPLICATION_DOCUMENTS);
          await manifestFile.writeAsString(timManifest);
          
        }

        loadTimsSuccessful = true;
        imageResolver = FileSystemImageResolver();
        await loadTimsFromJson(timManifest);
      }
    }

    if(!loadTimsSuccessful){
      loggingService.addToAppLog("Loading TIMs from bundled asset file");
      await loadTimsFromFile();
    }
  }


  Future<ItisSequence> getSequenceForFrame(TravelerDataFrame frame) async{
    String category;
    List<Choice_Item> items;
    if (frame.content is WorkZone) {
      category = "workZone";
      items = (frame.content as WorkZone).item;
    } else if (frame.content is ExitService) {
      category = "exitService";
      items = (frame.content as ExitService).item;
    } else if (frame.content is GenericSignage) {
      category = "genericSign";
      items = (frame.content as GenericSignage).item;
    } else if (frame.content is SpeedLimit) {
      category = "speedLimit";
      items = (frame.content as SpeedLimit).item;
    } else if (frame.content is ITIS_ITIScodesAndText) {
      category = "advisory";
      items = (frame.content as ITIS_ITIScodesAndText).item;
    } else {
      loggingService.showError("Unable to Map category for content type ${frame.content}");
      return ItisSequence([], await imageResolver.getMissing());
    }

    String key = getKeyForTimItisCodes(category, items);

    if(graphicsMap.containsKey(key)){
      return graphicsMap[key]!;
    }else{
      return await getDynamicSequence(category, items);
    }

  }

  Future<ItisSequence> getDynamicSequence(String category, List<Choice_Item> items) async {
    for(TimDefinition def in dynamicTims){

      if(doesTimMatchSequence(def, category, items)){
        List<String> populateValues = getValuesForSequence(def, items);
        String key = getKeyForTimItisCodes(def.type, items);
        graphicsMap[key] = ItisSequence(items, await createDynamicImage(def, populateValues));
        return graphicsMap[key]!;
      }
    }
    loggingService.showError("Unable to find Matching TIM definition for message $category ${ItisConverter.getItisListAsString(items)} ${ItisConverter.getItisListAsCodeString(items)}");
    return ItisSequence(items, await imageResolver.getMissing());
  }


  List<String> getValuesForSequence(TimDefinition definition, List<Choice_Item> items){
    List<String> values = [];

    String codeString = "";
    for(Choice_Item code in items){
      if(code is ITIScodes){
        codeString = "$codeString ${code.itisCode}";
      }
    }

    for(int i=0; i< definition.codes.length; i++){
      if(definition.codes[i] == "#"){
        if(items[i] is ITIScodes){
          values.add(getIntFromItis((items[i] as ITIScodes).itisCode).toString());
        }else{
          values.add((items[i] as ITIStext).itisText);
        }
      }
    }
    return values;
  }

  Future<Map<String, ItisSequence>> loadTimsFromFile() async {
    final String jsonString = await rootBundle.loadString('assets/tims.json');
    return loadTimsFromJson(jsonString);
  }


  
  // Loads all Predefined TIM messages from tims.json into the system
  Future<Map<String, ItisSequence>> loadTimsFromJson(String jsonString) async {
    
    final Map<String, dynamic> json = jsonDecode(jsonString);

    Map<String,ItisSequence> codes = {};

    var timsList = json['tims'] as List;
    List<TimDefinition> tims = timsList.map((t) => TimDefinition.fromJson(t)).toList();
    for(TimDefinition def in tims){

      // Pre-Cache all of the static TIMs into memory to improve performance.
      if(isStringSequenceStatic(def.codes)){
        String key = getKeyForTimDefinition(def.type, def.codes);

        if(graphicsMap.containsKey(key)){
          loggingService.showWarning("Key $key has already been loaded into graphics map. Duplicate entries in TIM JSON file. The first option will be used.");
        }else{
          ImageProvider image = await imageResolver.getImage(def.graphic);
          graphicsMap[key] = ItisSequence.fromText(def.codes, image);
        }
      }else{
        // Dynamic TIMs will be generated and cached as needed. Keep a short list of TIM message definitions to match.
        dynamicTims.add(def);
      }
    }
    return codes;
  }

  bool isStringSequenceStatic(List<String> sequence){
    for(String elem in sequence){
      if (elem == "#" || elem == "*" || (elem.isNotEmpty && elem[0] == '[')) {
        return false;
      }
    }
    return true;
  }

  Future<ImageProvider<Object>> createDynamicImage(TimDefinition definition, List<String> values) async{
    try{
      
      Image.Image? baseSizeImage = await imageResolver.getDecodedImage(definition.graphic);
      if (baseSizeImage != null) {
        for(int i =0; i< definition.overlays.length; i++){
          TextOverlay overlay = definition.overlays[i];
          
          Image.BitmapFont font;

          int value = int.tryParse(values[i])??-1;

          if (value >= 100) {
            font = await getFont(overlay.minorFontSize);
          }else{
            font = await getFont(overlay.majorFontSize);
          }

          Image.drawString(baseSizeImage, values[i], font: font, color: Image.ColorRgba8(0, 0, 0, 200), x:overlay.xPos, y: overlay.yPos);
        }
        return MemoryImage(Image.encodePng(baseSizeImage));
      }else{
        loggingService.showError("Unable to Load Base Image when creating dynamic Image.");
        return imageResolver.getMissing();
      }
    }on Exception catch(e){
      loggingService.showError("Generic Exception in creating Dynamic Image $e");
      return imageResolver.getMissing();
    }
  }

  Future<ImageProvider> getImage(String imagePath) async {
    try{
      Image.Image? image = await Image.decodePngFile("${await fileService.getDirectory(ArchiveDirectory.APPLICATION_DOCUMENTS)}/$imagePath");
      if(image != null){
        return MemoryImage(Image.encodePng(image));
      }else{
        return imageResolver.getMissing();
      }
      
    } on Exception catch(e){
      loggingService.showError("Unable to Load Image from Path $imagePath");
      return imageResolver.getMissing();
    }
  }

  Future<Image.BitmapFont> getFont(int size) async {
    // Currently all fonts must be preloaded statically. Only Fonts between size 8 and 80 in increments of 4 have been loaded. 
    // Force font to be an increment of 4
    size = size - (size %4);
    
    //Force font to be between 8 and 80 inclusive
    if(size >= 80){
      size = 80;
    }else if(size <= 8){
      size = 8;
    }

    final ByteData assetFontByteData = await rootBundle.load("$fontDirectory/HighwayGothic_$size.zip");
    return Image.readFontZip(assetFontByteData.buffer.asUint8List());
  }

  String getKeyForTimDefinition(String category, List<String> itisCodes){
    String key = "${category}";
    for(String code in itisCodes){
      key = "${key}_${code}";
    }
    return key;
  }

  String getKeyForTimItisCodes(String category, List<Choice_Item> itisCodes){
    String key = "${category}";
    for(Choice_Item code in itisCodes){
      String codeString = ItisConverter.getItisMessageAsCodeString(code);
      key = "${key}_${codeString}";
    }
    return key;
  }

  String getCategory(Choice_Content content){
    if (content is WorkZone) {
      // Work Zone
      return "workZone";
    } else if (content is ExitService) {
      // Exit Service
      return "exitService";
    } else if (content is GenericSignage) {
      // Generic Signage
      return "genericSign";
    } else if (content is SpeedLimit) {
      // Speed Limit
      return "speedLimit";
    } else if (content is ITIS_ITIScodesAndText) {
      // Advisory
      return "advisory";
    } else {
      loggingService.showError("Unable to Map category for content type $content");
      return "";
    }
  }

  bool doesTimMatchSequence(TimDefinition def, String category, List<Choice_Item> codes){
    if(category != def.type){
      return false;
    }

    if(def.codes.length != codes.length){
      return false;
    }

    for(int i=0; i< def.codes.length; i++){
      // Perform Numeric Comparison
      if(!doesCodeMatchSymbol(def.codes[i], codes[i])){
        return false;
      }
    }


    return true;
  }

  bool doesCodeMatchSymbol(String symbol, Choice_Item item){
    if (item is ITIScodes) {
      int code = item.itisCode;
      if(symbol == '*'){
        return true;
      }else if(symbol.length > 0 && symbol[0] == '['){
        List<int> numbers = (jsonDecode(symbol) as List).map((e) => int.tryParse(e.toString()) ?? 0).toList();
        return numbers.contains(code);
      }else if(symbol == "#" && isItisNumber(code)){
        return true;
      }else{
        return symbol == code.toString();
      }
    } else if (item is ITIStext) {
      String text = item.itisText;
      return symbol == text.toString();
    }
    return false;

  }

  
  int getIntFromItis(int itis) {
    int value = itis - minItisSmallNumber + 1;
    if (value >= 0 && value <= 255) {
      return value;
    }else if(itis >= 11531 && value <= 11613){
      if(ItisConverter.codeLookup.containsKey(itis)){
        return int.tryParse(ItisConverter.codeLookup[itis]!)??0;
      }
    }
    return -1;
  }

  bool isItisNumber(int itis){
    if ((itis >= minItisSmallNumber && itis <= maxItisSmallNumber) || (itis >= minItisLargeNumber && itis < maxItisLargeNumber)) {
      return true;
    }
    return false;
  }

}

