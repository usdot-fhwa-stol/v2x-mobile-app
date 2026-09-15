
import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';

import 'dart:io';
import 'dart:ui';

import 'package:asn1_plugin/j2735/2024/traveler_information/traveler_information.dart';
import 'package:cv_mec/models/itis/itis_sequence.dart';
import 'package:flutter_carplay/flutter_carplay.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AndroidAutoController extends GetxController {
  ConnectionStatusTypes connectionStatus = ConnectionStatusTypes.unknown; 
  final FlutterAndroidAuto _flutterAndroidAuto = FlutterAndroidAuto();

  RxBool isAlertVisible = false.obs;
  RxList<AAListSection> aaListSections = <AAListSection>[].obs;
  RxList<AAGridButton> timGridButtons = <AAGridButton>[].obs;
  int timCount = 0;
  int lightCount = 120;
  Timer? _lightTimer;
  Timer? _timTimer;
  late AATabBarTemplate tabTemplate;
  late final AAGridTemplate _timGridTemplate = AAGridTemplate(
    title: 'TIM',
    tabTitle: 'TIM',
    iconUrl: 'assets/images/tims/left_lane_closed_ahead.png',
    buttons: timGridButtons,
  );
  late final AAListTemplate _lightChangeListTemplate = AAListTemplate(
    title: 'Light Change',
    tabTitle: 'Light Change',
    iconUrl: 'assets/images/Lights/traffic-light-icon-green.png',
    sections: _lightChangeSections(),
  );

  void initialize() {
    if (Platform.isAndroid) {
      setupAndroidAuto();
    }
  }

  void startLight() {
    _lightTimer ??= Timer.periodic(Duration(seconds: 5), (timer) async {
      if (lightCount <= 0) {
        lightCount = 120;
      }
      lightCount -= 5;
      await updateLightChangeList();
    });
  }

  void startTim() {
    _timTimer ??= Timer.periodic(Duration(seconds: 8), (timer) async {
      addTimTest();
    });
  }

  Future<void> setupAndroidAuto() async {
    _flutterAndroidAuto.addListenerOnConnectionChange(onConnectionChange);
    //await setInitialAndroidAutoRootTemplate();
    await switchToTabTemplate();
    startLight();
    startTim();
  }

  void onConnectionChange(ConnectionStatusTypes status) {
    // Do things when carplay/android auto state is connected, background or disconnected
    connectionStatus = status;
  }

  Future<void> setInitialAndroidAutoRootTemplate() async {
    await switchToTabTemplate();
    await _flutterAndroidAuto.forceUpdateRootTemplate();
  }

  AAListTemplate aaLocationListTemplate() {
    return AAListTemplate(
      title: 'Location Updates',
      tabTitle: "Location",
      //systemIcon: "gear",
      iconUrl: 'assets/images/tims/accident_ahead.png',
      sections: aaListSections,
    );
  }

  AAGridTemplate aaTimGridTemplate() {
    return _timGridTemplate;
  }
  
  // AAGridTemplate aaLightSwitchTemplate() {
  //   return AAGridTemplate(
  //     title: 'Light Switch',
  //     tabTitle: "Light Switch",
  //     iconUrl: 'assets/images/tims/light_switch.png',
  //     buttons: lightSwitchGridButtons,
  //   );
  // }

  Future<void> switchToListTemplate() async {
    await FlutterAndroidAuto.setRootTemplate(template: aaLocationListTemplate());
  }

  AATabBarTemplate aaTabTemplate() {
    return AATabBarTemplate(
      tabs: [
        aaTimGridTemplate(),
        _lightChangeListTemplate,
      ],
    );
  }

  Future<void> switchToTabTemplate() async {
    tabTemplate = aaTabTemplate();
    await FlutterAndroidAuto.setRootTemplate(template: tabTemplate);
  }


  AAMessageTemplate messageTemplate() {
    return AAMessageTemplate(
      title: 'Message Title',
      message: 'This is a message.',
    );
  }

  Future<void> switchToMessageTemplate() async {
    await FlutterAndroidAuto.setRootTemplate(template: messageTemplate());
  }

  Future<void> updateMessage(AAMessageTemplate template) async {
    await template.update( 
      title: 'Dinosaur',
      message: 'Princess',
    );
  }

  Future<void> showAlert(String title, String message) async {
    await FlutterAndroidAuto.showAlert(
      template: alertTemplate(title, message),
    );
    isAlertVisible.value = true;
    await addAAListSection(title, message);
    // dismiss the alert after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (isAlertVisible.value) {
        FlutterAndroidAuto.popModal();
        isAlertVisible.value = false;
      }
    });
  }

  Future<void> showTimAlert(String title, String message) async {
    await FlutterAndroidAuto.showAlert(
      template: alertTemplate(title, message),
    );
    isAlertVisible.value = true;
    await addAAListSection(title, message);
    Future.delayed(Duration(seconds: 2), () {
      if (isAlertVisible.value) {
        FlutterAndroidAuto.popModal();
        isAlertVisible.value = false;
      }
    });
  }

  AAAlertTemplate alertTemplate(String title, String message) {
    return AAAlertTemplate(
      title: title,
      message: message,
      actions: [
        AAAlertAction( 
          onPress: () {
            FlutterAndroidAuto.popModal();
            isAlertVisible.value = false;
          }, 
          title: 'Dismiss'
        )
      ],
    );
  }


  Future<void> addAAListSection(String title, String message) async {
    aaListSections.add(
      AAListSection(
        title: title,
        items: [
          AAListItem(
            image: 'assets/images/Lights/traffic-light-icon-green.png',
            title: message,
            subtitle: '',
          ),
        ],
      ),
    );
    await switchToTabTemplate();
  }

  Future<void> addTim(TravelerInformation tim) async {
    timGridButtons.add(
      AAGridButton(  
        titleVariants: ["TIM"]
      )
    );
    await switchToTabTemplate();
  }

  List<AAListSection> _lightChangeSections() {
    return [
      AAListSection(
        items: [
          AAListItem(
            title: '$lightCount seconds',
            subtitle: 'Until the traffic signal changes',
            imageUrl: 'assets/images/Lights/traffic-light-icon-green.png',
          ),
        ],
      ),
    ];
  }

  Future<void> updateLightChangeList() async {
    final sections = _lightChangeSections();
    _lightChangeListTemplate.updateSections(sections);
    await _flutterAndroidAuto.updateListTemplateSections(
      elementId: _lightChangeListTemplate.uniqueId,
      sections: sections,
    );
  }

  @override
  void onClose() {
    _lightTimer?.cancel();
    super.onClose();
  }

  Future<void> addTimTest() async {
    //showTimAlert("TIM", "New TIM");
    List<String> imageOptions = [
      'assets/images/tims/accident_ahead.png',
      'assets/images/tims/caution_high_winds.png',
      'assets/images/tims/be_prepared_to_stop.png',
      'assets/images/tims/left_lane_closed_ahead.png'
    ];

    final timButton = AAGridButton(
      titleVariants: ["TIM ${timCount++}"],
      image: imageOptions[Random().nextInt(imageOptions.length)],
    );
    timGridButtons.add(timButton);
    await FlutterAndroidAuto.updateTabBarTemplates(template: tabTemplate);

    // Remove this specific TIM after 10 seconds.
    Future.delayed(Duration(seconds: 10), () async {
      if (timGridButtons.remove(timButton)) {
        await FlutterAndroidAuto.updateTabBarTemplates(template: tabTemplate);
      }
    });
  }
}